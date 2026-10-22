// lib/presentation/mesero/widgets/selector_talla_cantidad.dart
import 'package:flutter/material.dart';

class SelectorTallaCantidad extends StatelessWidget {
  final bool esPizza;
  final String tallaSeleccionada;
  final ValueChanged<String> onTallaChanged;
  final int cantidad;
  final VoidCallback onIncrementar;
  final VoidCallback onDecrementar;

  const SelectorTallaCantidad({
    super.key,
    required this.esPizza,
    required this.tallaSeleccionada,
    required this.onTallaChanged,
    required this.cantidad,
    required this.onIncrementar,
    required this.onDecrementar,
  });

  Widget _buildOpcionTalla(String talla) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: talla,
          groupValue: tallaSeleccionada,
          onChanged: (val) {
            if (val != null) onTallaChanged(val);
          },
        ),
        Text(talla),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (esPizza) ...[
          const Text('Tamaño:', style: TextStyle(fontSize: 18)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOpcionTalla('Mediana'),
              _buildOpcionTalla('Grande'),
              _buildOpcionTalla('Familiar'),
            ],
          ),
          const SizedBox(height: 16),
        ],
        const Text('Cantidad:', style: TextStyle(fontSize: 18)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 32),
              onPressed: onDecrementar,
            ),
            Text(
              '$cantidad',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 32),
              onPressed: onIncrementar,
            ),
          ],
        ),
      ],
    );
  }
}
