class PedidoDetalleModel {
  final int? id;
  final int? pedidoId;
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final String? talla;
  final int? producto2Id;

  PedidoDetalleModel({
    this.id,
    this.pedidoId,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    this.talla,
    this.producto2Id,
  });

  // Ideal para cuando necesites leer los pedidos desde Supabase
  factory PedidoDetalleModel.fromJson(Map<String, dynamic> json) {
    return PedidoDetalleModel(
      id: json['id'],
      pedidoId: json['pedido_id'],
      productoId: json['producto_id'],
      cantidad: json['cantidad'],
      precioUnitario: (json['precio_unitario'] as num).toDouble(),
      talla: json['talla'],
      producto2Id: json['producto_2_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (pedidoId != null) 'pedido_id': pedidoId,
      'producto_id': productoId,
      if (producto2Id != null) 'producto_2_id': producto2Id, // Evita enviar nulls innecesarios
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      if (talla != null) 'talla': talla,
    };
  }
}