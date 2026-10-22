// lib/presentation/admin/widgets/usuario_list_tile.dart
import 'package:flutter/material.dart';
import '../../../data/models/usuario_model.dart';

class UsuarioListTile extends StatelessWidget {
  final UsuarioModel usuario;
  final VoidCallback onDelete;

  const UsuarioListTile({
    super.key,
    required this.usuario,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final inicial = usuario.nombre.isNotEmpty
        ? usuario.nombre[0].toUpperCase()
        : 'U';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.indigo.shade100,
        child: Text(
          inicial,
          style: const TextStyle(
            color: Colors.indigo,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        '${usuario.nombre} ${usuario.apellido}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('${usuario.correo} • ${usuario.rol}'),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: onDelete,
      ),
    );
  }
}
