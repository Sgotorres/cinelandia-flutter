// lib/data/datasources/remote_pedidos_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pedido_detalle_model.dart';
import '../../core/errors/exceptions.dart';

class RemotePedidosDataSource {
  final SupabaseClient _supabase;

  RemotePedidosDataSource({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  Future<int> crearPedido(
    int mesaId,
    List<PedidoDetalleModel> detalles, {
    int? pedidoIdExistente,
  }) async {
    int? pedidoIdCreado;

    try {
      int pedidoId;
      if (pedidoIdExistente != null) {
        pedidoId = pedidoIdExistente;
      } else {
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

      if (detalles.isNotEmpty) {
        final detallesAInsertar = detalles.map((detalle) {
          final json = detalle.toJson();
          json['pedido_id'] = pedidoId;
          return json;
        }).toList();

        await _supabase.from('detalles_pedido').insert(detallesAInsertar);
      }

      return pedidoId;
    } catch (e) {
      if (pedidoIdCreado != null) {
        try {
          await _supabase.from('pedidos').delete().eq('id', pedidoIdCreado);
        } catch (_) {}
      }
      // El DataSource lanza Excepciones, no Failures
      throw ServerException('Fallo al registrar la orden: $e');
    }
  }

  Future<void> eliminarDetalleYActualizarPedido(
    int detalleId,
    int pedidoId,
  ) async {
    try {
      await _supabase.from('detalles_pedido').delete().eq('id', detalleId);

      final response = await _supabase
          .from('detalles_pedido')
          .select('id')
          .eq('pedido_id', pedidoId)
          .limit(1);

      if (response.isEmpty) {
        await _supabase
            .from('pedidos')
            .update({'estado': 'cancelada'})
            .eq('id', pedidoId);
      }
    } catch (e) {
      throw ServerException('Error al eliminar el producto: $e');
    }
  }

  Future<void> actualizarEstadoPedido(int pedidoId, String nuevoEstado) async {
    try {
      await _supabase
          .from('pedidos')
          .update({'estado': nuevoEstado})
          .eq('id', pedidoId);
    } catch (e) {
      throw ServerException('Error al actualizar estado: $e');
    }
  }

  // --- STREAMS ORIGINALES ---

  Stream<List<Map<String, dynamic>>> obtenerTodosLosPedidosStream() {
    return _supabase
        .from('pedidos')
        .stream(primaryKey: ['id'])
        .order('fecha', ascending: false);
  }

  Stream<List<Map<String, dynamic>>> obtenerDetallesPedidoStream(int pedidoId) {
    return _supabase
        .from('detalles_pedido')
        .stream(primaryKey: ['id'])
        .eq('pedido_id', pedidoId);
  }

  Stream<String> obtenerEstadoPedidoStream(int pedidoId) {
    return _supabase
        .from('pedidos')
        .stream(primaryKey: ['id'])
        .eq('id', pedidoId)
        .map(
          (data) =>
              data.isEmpty ? 'pendiente' : data.first['estado'] ?? 'pendiente',
        );
  }

  // --- NUEVAS OPTIMIZACIONES DE RENDIMIENTO ---

  /// Llamada al RPC para delegar los cálculos estadísticos a la base de datos
  /// Ideal para el panel de administración
  Future<Map<String, dynamic>> obtenerEstadisticasMesas() async {
    try {
      final response = await _supabase.rpc('obtener_estadisticas_mesas');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ServerException('Error al obtener estadísticas de mesas: $e');
    }
  }

  // lib/data/datasources/remote_pedidos_datasource.dart
  // (Mantén el resto del archivo igual y solo reemplaza esta función al final)

  /// Stream optimizado. Quitamos el filtro .neq() del servidor porque causaba
  /// bugs de sincronización en tiempo real con Supabase.
  /// Ahora el filtrado lo hace la UI de forma segura.
  Stream<List<Map<String, dynamic>>> obtenerPedidosActivosStream() {
    return _supabase
        .from('pedidos')
        .stream(primaryKey: ['id'])
        // ELIMINAMOS los .neq('estado', 'pagado') que congelaban la mesa
        .order('fecha', ascending: true);
  }
}
