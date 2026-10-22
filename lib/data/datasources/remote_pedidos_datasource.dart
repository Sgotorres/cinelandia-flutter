// lib/data/datasources/remote_pedidos_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/exceptions.dart';
import '../models/pedido_detalle_model.dart';

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
        await _supabase
            .from('pedidos')
            .update({'estado': 'pendiente'})
            .eq('id', pedidoId);
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
        .map((data) => data.isEmpty ? 'pendiente' : data.first['estado'] ?? 'pendiente');
  }

  Stream<List<Map<String, dynamic>>> obtenerPedidosActivosStream() {
    return _supabase
        .from('pedidos')
        .stream(primaryKey: ['id'])
        .order('fecha', ascending: true);
  }
}
