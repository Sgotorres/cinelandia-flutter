// lib/domain/entities/producto.dart
class Producto {
  final int id;
  final String nombre;
  final double? precio;
  final double? precioM; // Mediana / Pequeña
  final double? precioG; // Grande
  final double? precioF; // Familiar
  final String? volumen; // Para bebidas
  final String categoria;

  Producto({
    required this.id,
    required this.nombre,
    this.precio,
    this.precioM,
    this.precioG,
    this.precioF,
    this.volumen,
    required this.categoria,
  });
}