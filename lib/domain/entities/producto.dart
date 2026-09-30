class Producto {
  final int id;
  final String nombre;
  final double? precio;
  final double? precioG;
  final double? precioF;
  final String categoria;

  Producto({
    required this.id,
    required this.nombre,
    this.precio,
    this.precioG,
    this.precioF,
    required this.categoria,
  });
}