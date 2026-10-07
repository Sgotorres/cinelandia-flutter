import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pedido_detalle_model.dart';

class LocalPedidosDataSource {
  static const String _queueKey = 'pedidos_offline_queue';

  // Guarda un pedido en la cola local
  Future<void> guardarPedidoOffline(
    int mesaId,
    double total,
    List<PedidoDetalleModel> detalles,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> cola = prefs.getStringList(_queueKey) ?? [];

    final pedidoData = {
      'mesa_id': mesaId,
      'total': total,
      'detalles': detalles.map((d) => d.toJson()).toList(),
      'fecha_guardado': DateTime.now().toIso8601String(),
    };

    cola.add(jsonEncode(pedidoData));
    await prefs.setStringList(_queueKey, cola);
  }

  // Obtiene los pedidos guardados y vacía la cola
  Future<List<Map<String, dynamic>>> obtenerYVaciarCola() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> cola = prefs.getStringList(_queueKey) ?? [];

    if (cola.isEmpty) return [];

    final List<Map<String, dynamic>> pedidosPendientes = cola
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();

    // Vaciamos la cola porque asumimos que se van a procesar
    await prefs.setStringList(_queueKey, []);

    return pedidosPendientes;
  }
}
