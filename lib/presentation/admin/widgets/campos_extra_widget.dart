// lib/presentation/admin/widgets/campos_extra_widget.dart
import 'package:flutter/material.dart';

class CamposExtraWidget extends StatelessWidget {
  final TextEditingController precioUnicoCtrl;

  const CamposExtraWidget({
    super.key,
    required this.precioUnicoCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 30),
        const Text('Detalles de Categoría:', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: precioUnicoCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Precio Único (Obligatorio)'),
        ),
      ],
    );
  }
}