// lib/domain/entities/pedido_detalle.dart
class PedidoDetalle {
  final int? id;
  final int? pedidoId;
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final String? talla;
  final int? producto2Id;
  final String? nota;
  final double precioExtra;

  PedidoDetalle({
    this.id,
    this.pedidoId,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    this.talla,
    this.producto2Id,
    this.nota,
    this.precioExtra = 0.0,
  });
}
