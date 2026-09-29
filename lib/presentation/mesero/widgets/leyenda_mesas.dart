import 'package:flutter/material.dart';

class LeyendaMesas extends StatelessWidget {
  const LeyendaMesas({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Estado de Mesas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        Row(
          children: [
            _Badge(texto: 'Libres', color: Colors.green),
            const SizedBox(width: 4),
            _Badge(texto: 'Ocupadas', color: Colors.red),
            const SizedBox(width: 4),
            _Badge(texto: 'En Espera', color: Colors.orange),
          ],
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String texto;
  final MaterialColor color;
  const _Badge({required this.texto, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.shade50, borderRadius: BorderRadius.circular(12)),
      child: Text(texto, style: TextStyle(color: color.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}