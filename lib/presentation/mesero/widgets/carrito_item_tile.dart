// lib/presentation/mesero/widgets/carrito_item_tile.dart
import 'package:flutter/material.dart';
import '../../../domain/entities/pedido_detalle.dart';
import '../../shared/providers/menu_provider.dart';

class CarritoItemTile extends StatelessWidget {
  final PedidoDetalle item;
  final MenuProvider menuProvider;
  final VoidCallback onEliminar;

  const CarritoItemTile({
    super.key,
    required this.item,
    required this.menuProvider,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    String nombreP1 = 'Producto ${item.productoId}';
    try {
      nombreP1 = menuProvider.productos
          .firstWhere((p) => p.id == item.productoId)
          .nombre;
    } catch (_) {}

    String? nombreP2;
    if (item.producto2Id != null) {
      try {
        nombreP2 = menuProvider.productos
            .firstWhere((p) => p.id == item.producto2Id)
            .nombre;
      } catch (_) {}
    }

    final nombreAMostrar =
        nombreP2 != null ? '1/2 $nombreP1 y 1/2 $nombreP2' : nombreP1;

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
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF2FE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '${item.cantidad}x',
              style: const TextStyle(
                color: Color(0xFF3F51B5),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
        title: Text(
          nombreAMostrar,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.talla != null &&
                        item.talla != 'Única' &&
                        item.talla != 'null'
                    ? 'Tamaño: ${item.talla}'
                    : 'Unidad',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              if (item.nota != null && item.nota!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Nota: ${item.nota}',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (item.precioExtra > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    'Adicional: +\$${item.precioExtra.toStringAsFixed(2)} c/u',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\$${(item.precioUnitario * item.cantidad).toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF2E7D32),
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onEliminar,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
