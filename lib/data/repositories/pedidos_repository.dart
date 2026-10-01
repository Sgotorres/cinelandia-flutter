// lib/data/repositories/pedidos_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pedido_detalle_model.dart';

class PedidosRepository {
  final SupabaseClient _supabase;

  // Inyectamos el cliente de Supabase
  PedidosRepository({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  // ... resto de tu código sin cambios

  /// Crea un nuevo pedido o añade productos a uno existente
  Future<int> crearPedido(
    int mesaId, // <-- Cambiado de String a int
    double totalNuevosProductos,
    List<PedidoDetalleModel> detalles, {
    int? pedidoIdExistente,
  }) async {
    int? pedidoIdCreado;

    try {
      int pedidoId;

      // 1. Crear nuevo pedido o actualizar el total si ya existe
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
        // Se ejecuta una ÚNICA vez para pedidos nuevos
        final pedidoResponse = await _supabase
            .from('pedidos')
            .insert({
              'mesa_id': mesaId, // <-- Cambiado de 'mesa' a 'mesa_id'
              'total': totalNuevosProductos,
              'estado': 'pendiente',
              'fecha': DateTime.now().toIso8601String(),
            })
            .select('id')
            .single();

        pedidoId = pedidoResponse['id'];
        pedidoIdCreado = pedidoId; // Guardamos referencia por seguridad
      }

      // 2. Insertar los detalles del pedido
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
      // Manejo de error con Rollback
      if (pedidoIdCreado != null) {
        try {
          await _supabase.from('pedidos').delete().eq('id', pedidoIdCreado);
        } catch (_) {}
      }
      throw Exception('Fallo al registrar la orden: $e');
    }
  }

  /// Elimina un producto de la comanda y actualiza el pedido de forma atómica
  Future<void> eliminarDetalleYActualizarPedido(
    int detalleId,
    int pedidoId,
  ) async {
    try {
      // 1. Borramos el producto específico de los detalles
      await _supabase.from('detalles_pedido').delete().eq('id', detalleId);

      // 2. Verificamos cuántos productos quedan en este pedido
      final response = await _supabase
          .from('detalles_pedido')
          .select('cantidad, precio_unitario')
          .eq('pedido_id', pedidoId);

      final itemsRestantes = List<Map<String, dynamic>>.from(response);

      if (itemsRestantes.isEmpty) {
        // 3A. Si era el último producto, cancelamos el pedido automáticamente.
        // El Stream en MeseroHomeScreen detectará esto y liberará la mesa.
        await _supabase
            .from('pedidos')
            .update({'estado': 'cancelada', 'total': 0.0})
            .eq('id', pedidoId);
      } else {
        // 3B. Si aún quedan productos, recalculamos el total de la comanda
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
    } catch (e) {
      throw Exception(
        'Error al eliminar el producto y actualizar la orden: $e',
      );
    }
  }
}
