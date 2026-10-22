class PedidoDetalleModel {
  final int? id;
  final int? pedidoId;
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final String? talla;
  final int? producto2Id;
  final String? nota;
  final double precioExtra;

  PedidoDetalleModel({
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
      nota: json['nota'],
      precioExtra: json['precio_extra'] != null
          ? (json['precio_extra'] as num).toDouble()
          : 0.0,
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
      if (nota != null && nota!.isNotEmpty) 'nota': nota,
      if (precioExtra > 0) 'precio_extra': precioExtra,
    };
  }
}
