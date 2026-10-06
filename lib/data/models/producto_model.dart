class ProductoModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final double? precio; 
  final String categoria;
  final bool esRecomendado;
  final bool disponible;
  final double? precioM; // <-- NUEVO
  final double? precioG; 
  final double? precioF; 
  final String? volumen; // <-- NUEVO

  ProductoModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.precio,
    required this.categoria,
    required this.esRecomendado,
    required this.disponible,
    this.precioM, // <-- NUEVO
    this.precioG,
    this.precioF,
    this.volumen, // <-- NUEVO
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: json['precio'] != null ? (json['precio'] as num).toDouble() : null,
      categoria: json['categoria'] ?? 'General',
      esRecomendado: json['es_recomendado'] ?? false,
      disponible: json['disponible'] ?? true,
      precioM: json['precio_m'] != null ? (json['precio_m'] as num).toDouble() : null, // <-- NUEVO
      precioG: json['precio_g'] != null ? (json['precio_g'] as num).toDouble() : null,
      precioF: json['precio_f'] != null ? (json['precio_f'] as num).toDouble() : null,
      volumen: json['volumen'], // <-- NUEVO
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'categoria': categoria,
      'es_recomendado': esRecomendado,
      'disponible': disponible,
      'precio_m': precioM, // <-- NUEVO
      'precio_g': precioG,
      'precio_f': precioF,
      'volumen': volumen, // <-- NUEVO
    };
  }
}