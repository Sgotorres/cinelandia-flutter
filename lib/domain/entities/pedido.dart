// lib/domain/entities/pedido.dart
class Pedido {
  final int? id;
  final int mesaId;
  final String? mesaNombre;
  final double total;
  final String? estado;
  final String? fecha;

  Pedido({
    this.id,
    required this.mesaId,
    this.mesaNombre,
    required this.total,
    this.estado,
    this.fecha,
  });
}
