import '../../domain/entities/usuario.dart';

class UsuarioModel {
  final int id;
  final String nombre;
  final String apellido;
  final String correo;
  final String rol;

  UsuarioModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.rol,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      correo: json['correo'] ?? '',
      rol: json['rol'] ?? 'mesero',
    );
  }

  Usuario toEntity() {
    return Usuario(
      id: id,
      nombre: nombre,
      apellido: apellido,
      correo: correo,
      rol: rol,
    );
  }

  factory UsuarioModel.fromEntity(Usuario entity) {
    return UsuarioModel(
      id: entity.id,
      nombre: entity.nombre,
      apellido: entity.apellido,
      correo: entity.correo,
      rol: entity.rol,
    );
  }
}
