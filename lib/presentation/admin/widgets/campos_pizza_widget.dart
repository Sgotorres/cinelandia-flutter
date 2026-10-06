// lib/presentation/admin/widgets/campos_pizza_widget.dart
import 'package:flutter/material.dart';

class CamposPizzaWidget extends StatelessWidget {
  final TextEditingController precioMCtrl;
  final TextEditingController precioGCtrl;
  final TextEditingController precioFCtrl;

  const CamposPizzaWidget({
    super.key,
    required this.precioMCtrl,
    required this.precioGCtrl,
    required this.precioFCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 30),
        const Text('Precios para Pizzas:', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: precioMCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Precio Mediana/Pequeña (precio_m)'),
        ),
        TextField(
          controller: precioGCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Precio Grande (precio_g)'),
        ),
        TextField(
          controller: precioFCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Precio Familiar (precio_f)'),
        ),
      ],
    );
  }
}