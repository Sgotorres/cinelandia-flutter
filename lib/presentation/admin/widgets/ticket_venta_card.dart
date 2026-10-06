// lib/presentation/admin/widgets/ticket_venta_card.dart
import 'package:flutter/material.dart';

class TicketVentaCard extends StatelessWidget {
  final Map<String, dynamic> venta;
  final String nombreMesa;

  const TicketVentaCard({
    super.key,
    required this.venta,
    required this.nombreMesa,
  });

  @override
  Widget build(BuildContext context) {
    final total = (venta['total'] as num).toDouble();
    final fechaRaw = venta['fecha'] as String;
    
    // Formateo simple de hora (ej: 14:30)
    final fechaObj = DateTime.parse(fechaRaw).toLocal();
    final horaStr = '${fechaObj.hour.toString().padLeft(2, '0')}:${fechaObj.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Colors.greenAccent,
          child: Icon(
            Icons.check,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Ticket #${venta['id']} - $nombreMesa',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Cobrado a las $horaStr',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Text(
          '\$${total.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}