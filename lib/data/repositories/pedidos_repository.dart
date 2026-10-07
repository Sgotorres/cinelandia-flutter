import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../datasources/local_pedidos_datasource.dart';
import '../models/pedido_detalle_model.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';

class PedidosRepository {
  final SupabaseClient _supabase;
  final LocalPedidosDataSource _localDataSource = LocalPedidosDataSource();

  PedidosRepository({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  /// Crea un nuevo pedido o añade productos a uno existente
  Future<Result<int, Failure>> crearPedido(
    int mesaId,
    double totalNuevosProductos,
    List<PedidoDetalleModel> detalles, {
    int? pedidoIdExistente,
  }) async {
    // 1. Verificamos la conexión antes de intentar enviar
    final conectividad = await Connectivity().checkConnectivity();
    final sinInternet = conectividad.contains(ConnectivityResult.none);

    if (sinInternet && pedidoIdExistente == null) {
      await _localDataSource.guardarPedidoOffline(
        mesaId,
        totalNuevosProductos,
        detalles,
      );
      return const Error(
        NetworkFailure(
          'Sin internet. La comanda se guardó y se enviará automáticamente al reconectar.',
        ),
      );
    }

    int? pedidoIdCreado;
    try {
      int pedidoId;
      if (pedidoIdExistente != null) {
        final pedidoActual = await _supabase
            .from('pedidos')
            .select('total')
            .eq('id', pedidoIdExistente)
            .single();
        final double totalActualizado =
            (pedidoActual['total'] as num).toDouble() + totalNuevosProductos;
        await _supabase
            .from('pedidos')
            .update({'total': totalActualizado})
            .eq('id', pedidoIdExistente);
        pedidoId = pedidoIdExistente;
      } else {
        final pedidoResponse = await _supabase
            .from('pedidos')
            .insert({
              'mesa_id': mesaId,
              'total': totalNuevosProductos,
              'estado': 'pendiente',
              'fecha': DateTime.now().toIso8601String(),
            })
            .select('id')
            .single();
        pedidoId = pedidoResponse['id'];
        pedidoIdCreado = pedidoId;
      }

      if (detalles.isNotEmpty) {
        final detallesAInsertar = detalles.map((detalle) {
          final json = detalle.toJson();
          json['pedido_id'] = pedidoId;
          return json;
        }).toList();
        await _supabase.from('detalles_pedido').insert(detallesAInsertar);
      }
      return Success(pedidoId);
    } catch (e) {
      if (pedidoIdCreado != null) {
        try {
          await _supabase.from('pedidos').delete().eq('id', pedidoIdCreado);
        } catch (_) {}
      }

      if (pedidoIdExistente == null) {
        await _localDataSource.guardarPedidoOffline(
          mesaId,
          totalNuevosProductos,
          detalles,
        );
        return const Error(
          NetworkFailure('Error de red. La comanda se guardó localmente.'),
        );
      }

      return Error(ServerFailure('Fallo al registrar la orden: $e'));
    }
  }

  /// Elimina un producto de la comanda y actualiza el pedido de forma atómica
  Future<Result<bool, Failure>> eliminarDetalleYActualizarPedido(
    int detalleId,
    int pedidoId,
  ) async {
    try {
      await _supabase.from('detalles_pedido').delete().eq('id', detalleId);
      final response = await _supabase
          .from('detalles_pedido')
          .select('cantidad, precio_unitario')
          .eq('pedido_id', pedidoId);

      final itemsRestantes = List<Map<String, dynamic>>.from(response);

      if (itemsRestantes.isEmpty) {
        await _supabase
            .from('pedidos')
            .update({'estado': 'cancelada', 'total': 0.0})
            .eq('id', pedidoId);
      } else {
        double nuevoTotal = 0.0;
        for (var item in itemsRestantes) {
          final int cantidad = item['cantidad'] ?? 1;
          final double precio = (item['precio_unitario'] as num).toDouble();
          nuevoTotal += (cantidad * precio);
        }
        await _supabase
            .from('pedidos')
            .update({'total': nuevoTotal})
            .eq('id', pedidoId);
      }
      return const Success(true);
    } catch (e) {
      return Error(ServerFailure('Error al eliminar el producto: $e'));
    }
  }

  // Función para sincronizar cuando vuelva el internet
  Future<void> sincronizarPedidosOffline() async {
    final pendientes = await _localDataSource.obtenerYVaciarCola();
    if (pendientes.isEmpty) return;

    for (var pedidoMap in pendientes) {
      final detallesRaw = pedidoMap['detalles'] as List<dynamic>;
      final detalles = detallesRaw
          .map((d) => PedidoDetalleModel.fromJson(d))
          .toList();

      await crearPedido(pedidoMap['mesa_id'], pedidoMap['total'], detalles);
    }
  }
}
