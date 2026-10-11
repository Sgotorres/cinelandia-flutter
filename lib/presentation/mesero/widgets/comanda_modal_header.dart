// lib/presentation/mesero/widgets/comanda_modal_header.dart
import 'package:flutter/material.dart';

class ComandaModalHeader extends StatelessWidget {
  final int mesaId;

  const ComandaModalHeader({super.key, required this.mesaId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Indicador de arrastre (Drag Handle)
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            height: 5,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        // Título y botón de cerrar
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mesa $mesaId',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.black12),
      ],
    );
  }
}