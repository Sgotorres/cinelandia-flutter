// lib/data/models/pedido_model.dart

class PedidoModel {
  final int? id;
  final String mesa;
  final double total;
  final String? estado;
  final String? fecha;

  PedidoModel({
    this.id, // Opcional al crear, ya que Supabase lo genera automáticamente
    required this.mesa,
    required this.total,
    this.estado,
    this.fecha,
  });

  factory PedidoModel.fromJson(Map<String, dynamic> json) {
    return PedidoModel(
      id: json['id'],
      mesa: json['mesa'] ?? '',
      // Se asegura de convertir enteros o decimales de Supabase a double
      total: (json['total'] as num).toDouble(),
      estado: json['estado'] ?? 'pendiente',
      fecha: json['fecha'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'mesa': mesa,
      'total': total,
      if (estado != null) 'estado': estado,
      if (fecha != null) 'fecha': fecha,
    };
  }
}