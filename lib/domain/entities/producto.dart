// lib/domain/entities/producto.dart
class Producto {
  final int id;
  final String nombre;
  final String? descripcion;
  final double? precio;
  final double? precioM; // Mediana / Pequeña
  final double? precioG; // Grande
  final double? precioF; // Familiar
  final String? volumen; // Para bebidas
  final String categoria;
  final bool esRecomendado;
  final bool disponible;

  Producto({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.precio,
    this.precioM,
    this.precioG,
    this.precioF,
    this.volumen,
    required this.categoria,
    this.esRecomendado = false,
    this.disponible = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'categoria': categoria,
      'es_recomendado': esRecomendado,
      'disponible': disponible,
      'precio_m': precioM,
      'precio_g': precioG,
      'precio_f': precioF,
      'volumen': volumen,
    };
  }
}
