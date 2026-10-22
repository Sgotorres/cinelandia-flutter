// lib/domain/entities/recibo.dart
class ReciboItem {
  final String nombre;
  final int cantidad;
  final String talla;
  final double precioUnitario;
  final double precioExtra;
  final String? nota;

  const ReciboItem({
    required this.nombre,
    required this.cantidad,
    required this.talla,
    required this.precioUnitario,
    this.precioExtra = 0.0,
    this.nota,
  });

  double get subtotal => cantidad * precioUnitario;
}

class Recibo {
  final int pedidoId;
  final String mesaNombre;
  final DateTime fecha;
  final List<ReciboItem> items;
  final double total;

  const Recibo({
    required this.pedidoId,
    required this.mesaNombre,
    required this.fecha,
    required this.items,
    required this.total,
  });
}

class ReciboGenerado {
  final Recibo recibo;
  final String qrPayload;
  final String? signedUrl;
  final DateTime expiraEn;

  const ReciboGenerado({
    required this.recibo,
    required this.qrPayload,
    this.signedUrl,
    required this.expiraEn,
  });
}
