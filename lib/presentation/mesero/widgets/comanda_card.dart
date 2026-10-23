// lib/presentation/mesero/widgets/comanda_card.dart
import 'package:flutter/material.dart';

import 'comanda_detalles_modal.dart';

class ComandaCard extends StatelessWidget {
  final int pedidoId;
  final int? mesaId;
  final String nombreMesa;
  final double total;
  final String estado;

  const ComandaCard({
    super.key,
    required this.pedidoId,
    this.mesaId,
    required this.nombreMesa,
    required this.total,
    required this.estado,
  });

  // Extraemos la lógica de colores a un método privado y limpio
  Color _getColorEstado() {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'horno':
        return Colors.blue;
      case 'comiendo':
        return Colors.purple;
      case 'lista':
        return Colors.teal; // ANTES: Colors.greenAccent.shade700
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorEstado = _getColorEstado();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: colorEstado.withOpacity(0.2),
          child: Icon(Icons.receipt_long, color: colorEstado),
        ),
        title: Text(
          nombreMesa,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            'Total: \$${total.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorEstado,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            estado.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => ComandaDetallesModal(
              pedidoId: pedidoId,
              mesaId: mesaId ?? 0,
              mesaNombre: nombreMesa,
            ),
          );
        },
      ),
    );
  }
}
