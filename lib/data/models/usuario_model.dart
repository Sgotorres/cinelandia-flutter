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
}
