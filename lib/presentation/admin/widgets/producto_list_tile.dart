// lib/presentation/admin/widgets/producto_list_tile.dart
import 'package:flutter/material.dart';

class ProductoListTile extends StatelessWidget {
  final Map<String, dynamic> producto;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleDisponibilidad;

  const ProductoListTile({
    super.key,
    required this.producto,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleDisponibilidad,
  });

  @override
  Widget build(BuildContext context) {
    final bool disponible = producto['disponible'] ?? true;

    String precioInfo = '';
    if (producto['precio_g'] != null || producto['precio_f'] != null) {
      precioInfo =
          'G: \$${producto['precio_g'] ?? '-'} | F: \$${producto['precio_f'] ?? '-'}';
    } else if (producto['precio'] != null) {
      precioInfo = 'Precio: \$${producto['precio']}';
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: disponible
            ? Colors.green.shade100
            : Colors.red.shade100,
        child: Icon(
          Icons.fastfood,
          color: disponible ? Colors.green : Colors.red,
        ),
      ),
      title: Text(
        producto['nombre'] ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('${producto['categoria']} • $precioInfo'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: disponible,
            activeColor: Colors.green,
            onChanged: (val) => onToggleDisponibilidad(val),
          ),
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
