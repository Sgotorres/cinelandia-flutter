// lib/presentation/mesero/widgets/comanda_item_tile.dart
import 'package:flutter/material.dart';

class ComandaItemTile extends StatelessWidget {
  final String nombre;
  final int cantidad;
  final String talla;
  final double subtotal;
  final String? nota;
  final double precioExtra;
  final VoidCallback onEliminar;
  final bool isDeleting;

  const ComandaItemTile({
    super.key,
    required this.nombre,
    required this.cantidad,
    required this.talla,
    required this.subtotal,
    this.nota,
    this.precioExtra = 0.0,
    required this.onEliminar,
    required this.isDeleting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '${cantidad}x',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          nombre,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              talla != 'Única' && talla != 'null' ? 'Tamaño: $talla' : 'Unidad',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            if (nota != null && nota!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Nota: $nota',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (precioExtra > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  'Adicional: +\$${precioExtra.toStringAsFixed(2)} c/u',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\$${subtotal.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.green,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 18),
              ),
              onPressed: isDeleting ? null : onEliminar,
            ),
          ],
        ),
      ),
    );
  }
}
