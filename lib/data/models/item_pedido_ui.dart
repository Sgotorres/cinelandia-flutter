// lib/data/models/item_pedido_ui.dart

class ItemPedidoUI {
  final dynamic id; // Puede ser el ID numérico de Supabase o el índice int del carrito
  final String nombreAMostrar;
  final String subtitulo;
  final int cantidad;
  final double subtotal;

  ItemPedidoUI({
    required this.id,
    required this.nombreAMostrar,
    required this.subtitulo,
    required this.cantidad,
    required this.subtotal,
  });
}