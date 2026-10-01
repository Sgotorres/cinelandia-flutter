// lib/presentation/admin/widgets/mesa_list_tile.dart
import 'package:flutter/material.dart';

class MesaListTile extends StatelessWidget {
  final Map<String, dynamic> mesa;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MesaListTile({
    super.key,
    required this.mesa,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.indigoAccent,
        child: Icon(Icons.chair_alt, color: Colors.white),
      ),
      title: Text(
        mesa['nombre'] ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('Orden de vista: ${mesa['orden']}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
