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

    // Mantenemos la lógica de persistencia offline intacta
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
        // CAMBIO: Ya no consultamos ni calculamos el total aquí.
        // Solo necesitamos saber a qué pedido existente le vamos a agregar los detalles.
        pedidoId = pedidoIdExistente;
      } else {
        // CAMBIO: Si es un pedido nuevo, insertamos el 'total' inicialmente en 0.0.
        // Cuando se inserten los detalles en el siguiente paso, el Trigger de Supabase
        // disparará la suma matemática y actualizará este 0.0 al total real al instante.
        final pedidoResponse = await _supabase
            .from('pedidos')
            .insert({
              'mesa_id': mesaId,
              'total': 0.0,
              'estado': 'pendiente',
              'fecha': DateTime.now().toIso8601String(),
            })
            .select('id')
            .single();
            
        pedidoId = pedidoResponse['id'];
        pedidoIdCreado = pedidoId;
      }

      // Insertamos los detalles en bloque.
      // Aquí es donde "la magia" ocurre: el Trigger de Supabase detectará estas 
      // inserciones y actualizará el total en la tabla de pedidos de forma segura.
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
        // Rollback manual si falla la inserción de detalles en un pedido recién creado
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
      // 1. Borramos el ítem. Al hacerlo, el Trigger de Supabase se activa (por el DELETE)
      // y resta automáticamente el valor de este ítem del total del pedido.
      await _supabase.from('detalles_pedido').delete().eq('id', detalleId);
      
      // 2. Solo verificamos si la comanda se quedó sin productos para cancelarla.
      // OPTIMIZACIÓN: Usamos limit(1) y solo traemos el 'id'. No hace falta traer
      // los precios y cantidades de todo el pedido porque ya no sumamos en el frontend.
      final response = await _supabase
          .from('detalles_pedido')
          .select('id')
          .eq('pedido_id', pedidoId)
          .limit(1);

      // Si la lista está vacía, cambiamos el estado a cancelada.
      // No hace falta enviar 'total': 0.0 porque el Trigger ya lo dejó en 0.
      if (response.isEmpty) {
        await _supabase
            .from('pedidos')
            .update({'estado': 'cancelada'})
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

      // Esto volverá a llamar a crearPedido, y nuevamente el servidor se 
      // encargará de unificar los montos si hay colisiones.
      await crearPedido(pedidoMap['mesa_id'], pedidoMap['total'], detalles);
    }
  }
}