// lib/presentation/mesero/widgets/categoria_chips.dart
import 'package:flutter/material.dart';

class CategoriaChips extends StatelessWidget {
  final List<String> categorias;
  final String categoriaSeleccionada;
  final ValueChanged<String> onSelected;

  const CategoriaChips({
    super.key,
    required this.categorias,
    required this.categoriaSeleccionada,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categorias.map((cat) {
            final isSelected = categoriaSeleccionada == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                selectedColor: Colors.redAccent,
                onSelected: (selected) {
                  if (selected) onSelected(cat);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}