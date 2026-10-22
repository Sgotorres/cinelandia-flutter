// lib/domain/entities/mesa.dart
class Mesa {
  final int id;
  final String nombre;
  final bool activa;
  final int orden;

  Mesa({
    required this.id,
    required this.nombre,
    required this.activa,
    required this.orden,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'activa': activa,
      'orden': orden,
    };
  }
}
