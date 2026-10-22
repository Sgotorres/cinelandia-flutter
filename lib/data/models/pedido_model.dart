import '../../domain/entities/pedido.dart';

class PedidoModel {
  final int? id;
  final int mesaId;
  final String? mesaNombre; // Opcional, para cuando traigamos el JOIN
  final double total;
  final String? estado;
  final String? fecha;

  PedidoModel({
    this.id,
    required this.mesaId,
    this.mesaNombre,
    required this.total,
    this.estado,
    this.fecha,
  });

  factory PedidoModel.fromJson(Map<String, dynamic> json) {
    return PedidoModel(
      id: json['id'],
      mesaId: json['mesa_id'] ?? 0,
      mesaNombre: json['mesas'] != null ? json['mesas']['nombre'] : null,
      total: (json['total'] as num).toDouble(),
      estado: json['estado'] ?? 'pendiente',
      fecha: json['fecha'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'mesa_id': mesaId,
      'total': total,
      if (estado != null) 'estado': estado,
      if (fecha != null) 'fecha': fecha,
    };
  }

  Pedido toEntity() {
    return Pedido(
      id: id,
      mesaId: mesaId,
      mesaNombre: mesaNombre,
      total: total,
      estado: estado,
      fecha: fecha,
    );
  }

  factory PedidoModel.fromEntity(Pedido entity) {
    return PedidoModel(
      id: entity.id,
      mesaId: entity.mesaId,
      mesaNombre: entity.mesaNombre,
      total: entity.total,
      estado: entity.estado,
      fecha: entity.fecha,
    );
  }
}
