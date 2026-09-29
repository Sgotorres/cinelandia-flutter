import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repositories/pedidos_repository.dart';
import 'menu_provider.dart';
import '../../data/models/item_pedido_ui.dart';

// Importa el modelo ItemPedidoUI que creamos arriba

class ComandaDetallesProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final _pedidosRepository = PedidosRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ItemPedidoUI> _itemsUI = [];
  List<ItemPedidoUI> get itemsUI => _itemsUI;

  double get total => _itemsUI.fold(0, (sum, item) => sum + item.subtotal);

  Future<void> cargarDetalles(int pedidoId, MenuProvider menuProvider) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase.from('detalles_pedido').select('*').eq('pedido_id', pedidoId);
      final rawItems = List<Map<String, dynamic>>.from(response);

      _itemsUI = rawItems.map((item) {
        final int cantidad = item['cantidad'] ?? 1;
        final double precioUnitario = (item['precio_unitario'] as num).toDouble();
        final String talla = item['talla'] ?? 'Única';

        // Lógica de nombres extraída de tu código original
        String nombreP1 = 'Producto ${item['producto_id']}';
        try {
          nombreP1 = menuProvider.productos.firstWhere((p) => p.id == item['producto_id']).nombre;
        } catch (_) {}

        String? nombreP2;
        if (item['producto_2_id'] != null) {
          try {
            nombreP2 = menuProvider.productos.firstWhere((p) => p.id == item['producto_2_id']).nombre;
          } catch (_) {}
        }

        return ItemPedidoUI(
          id: item['id'], // ID de la base de datos
          nombreAMostrar: nombreP2 != null ? '1/2 $nombreP1 y 1/2 $nombreP2' : nombreP1,
          subtitulo: talla != 'Única' && talla != 'null' ? 'Tamaño: $talla' : 'Unidad',
          cantidad: cantidad,
          subtotal: cantidad * precioUnitario,
        );
      }).toList();
    } catch (e) {
      debugPrint("Error cargando detalles: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> eliminarProductoOptimista(int detalleId, int pedidoId) async {
    // 1. Borrado optimista visual
    _itemsUI.removeWhere((item) => item.id == detalleId);
    notifyListeners();

    // 2. Borrado en base de datos
    try {
      await _pedidosRepository.eliminarDetalleYActualizarPedido(detalleId, pedidoId);
    } catch (e) {
      // Manejo de errores (puedes emitir un error o recargar la lista real aquí)
      debugPrint("Error borrando de BD: $e");
    }
  }
}