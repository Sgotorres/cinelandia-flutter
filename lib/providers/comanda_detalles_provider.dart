// lib/providers/comanda_detalles_provider.dart
import 'package:flutter/material.dart';
import '../data/repositories/pedidos_repository.dart';

class ComandaDetallesProvider extends ChangeNotifier {
  final _pedidosRepository = PedidosRepository();

  Future<void> eliminarProducto(int detalleId, int pedidoId) async {
    // 1. Borrado en base de datos delegando al repositorio
    try {
      await _pedidosRepository.eliminarDetalleYActualizarPedido(detalleId, pedidoId);
    } catch (e) {
      debugPrint("Error borrando de BD: $e");
    }
  }
}