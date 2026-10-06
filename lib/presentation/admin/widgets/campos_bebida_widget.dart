// lib/presentation/admin/widgets/campos_bebida_widget.dart
import 'package:flutter/material.dart';

class CamposBebidaWidget extends StatelessWidget {
  final TextEditingController volumenCtrl;
  final TextEditingController precioUnicoCtrl;

  const CamposBebidaWidget({
    super.key,
    required this.volumenCtrl,
    required this.precioUnicoCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 30),
        const Text('Detalles de Bebida:', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: volumenCtrl,
          decoration: const InputDecoration(labelText: 'Volumen (Ej: 400ml, 1.5L)'),
        ),
        TextField(
          controller: precioUnicoCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Precio de la bebida'),
        ),
      ],
    );
  }
}