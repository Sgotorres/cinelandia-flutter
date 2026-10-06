// lib/presentation/admin/widgets/lista_articulos_pedido.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../../providers/menu_provider.dart';

class ListaArticulosPedido extends StatelessWidget {
  final int pedidoId;

  const ListaArticulosPedido({super.key, required this.pedidoId});

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('detalles_pedido')
          .stream(primaryKey: ['id'])
          .eq('pedido_id', pedidoId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final detalles = snapshot.data ?? [];
        if (detalles.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Sin artículos', style: TextStyle(color: Colors.grey)),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: detalles.map((item) {
            final int cantidad = item['cantidad'] ?? 1;
            final String talla = item['talla'] ?? 'Única';

            String nombreP1 = 'Producto ${item['producto_id']}';
            try {
              nombreP1 = menuProvider.productos.firstWhere((p) => p.id == item['producto_id']).nombre;
            } catch (_) {}

            String? nombreP2;
            if (item['producto_2_id'] != null) {
              try {
                nombreP2 = menuProvider.productos.firstWhere((p) => p.id == item['producto_2_id']).nombre;
              } catch (_) {}
            }

            final nombreAMostrar = nombreP2 != null ? '1/2 $nombreP1 y 1/2 $nombreP2' : nombreP1;

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
                      border: Border.all(color: Colors.indigo.shade100)
                    ),
                    child: Text(
                      '${cantidad}x',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade900, fontSize: 15),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombreAMostrar,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                        ),
                        if (talla != 'Única' && talla != 'null')
                          Text(
                            'Tamaño: $talla',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}