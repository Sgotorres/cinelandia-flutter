// lib/presentation/admin/widgets/articulo_pedido_row.dart
import 'package:flutter/material.dart';
import '../../../providers/menu_provider.dart';

class ArticuloPedidoRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final MenuProvider menuProvider;

  const ArticuloPedidoRow({
    super.key,
    required this.item,
    required this.menuProvider,
  });

  String _buscarNombre(int? id) {
    if (id == null) return '';
    try {
      return menuProvider.productos.firstWhere((p) => p.id == id).nombre;
    } catch (_) {
      return 'Producto $id';
    }
  }

  @override
  Widget build(BuildContext context) {
    final int cantidad = item['cantidad'] ?? 1;
    final String talla = item['talla'] ?? 'Única';
    final nombreP1 = _buscarNombre(item['producto_id'] as int?);
    final p2Id = item['producto_2_id'] as int?;
    final nombreP2 = p2Id != null ? _buscarNombre(p2Id) : null;
    final nombreAMostrar =
        nombreP2 != null ? '1/2 $nombreP1 y 1/2 $nombreP2' : nombreP1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.indigo.shade100),
            ),
            child: Text(
              '${cantidad}x',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade900,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombreAMostrar,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                if (talla != 'Única' && talla != 'null')
                  Text(
                    'Tamaño: $talla',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
