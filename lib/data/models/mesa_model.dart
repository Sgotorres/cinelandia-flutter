class MesaModel {
  final int id;
  final String nombre;
  final bool activa;
  final int orden;

  MesaModel({
    required this.id,
    required this.nombre,
    required this.activa,
    required this.orden,
  });

  factory MesaModel.fromJson(Map<String, dynamic> json) {
    return MesaModel(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      activa: json['activa'] ?? true,
      orden: json['orden'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'activa': activa,
      'orden': orden,
    };
  }
}