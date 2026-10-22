// lib/domain/entities/usuario.dart
class Usuario {
  final int id;
  final String nombre;
  final String apellido;
  final String correo;
  final String rol;

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.rol,
  });
}
