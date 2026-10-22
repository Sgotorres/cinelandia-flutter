// lib/presentation/admin/widgets/lista_articulos_pedido.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/menu_provider.dart';
import '../../../providers/pedidos_provider.dart';
import 'articulo_pedido_row.dart';

class ListaArticulosPedido extends StatefulWidget {
  final int pedidoId;
  const ListaArticulosPedido({super.key, required this.pedidoId});

  @override
  State<ListaArticulosPedido> createState() => _ListaArticulosPedidoState();
}

class _ListaArticulosPedidoState extends State<ListaArticulosPedido> {
  late final Stream<List<Map<String, dynamic>>> _detallesStream;

  @override
  void initState() {
    super.initState();
    _detallesStream = context.read<PedidosProvider>().detallesPedidoStream(
      widget.pedidoId,
    );
  }

  List<Map<String, dynamic>> _agruparItems(List<Map<String, dynamic>> raw) {
    final Map<String, Map<String, dynamic>> agrupados = {};
    for (var item in raw) {
      final p1 = item['producto_id'];
      final p2 = item['producto_2_id'] ?? 'null';
      final talla = item['talla'] ?? 'Única';
      final key = '${p1}_${p2}_$talla';

      if (agrupados.containsKey(key)) {
        agrupados[key]!['cantidad'] =
            (agrupados[key]!['cantidad'] as int) + (item['cantidad'] as int);
      } else {
        agrupados[key] = Map<String, dynamic>.from(item);
      }
    }
    return agrupados.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _detallesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final detallesRaw = snapshot.data ?? [];
        if (detallesRaw.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Sin artículos', style: TextStyle(color: Colors.grey)),
          );
        }

        final detalles = _agruparItems(detallesRaw);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: detalles
              .map(
                (item) => ArticuloPedidoRow(
                  item: item,
                  menuProvider: menuProvider,
                ),
              )
              .toList(),
        );
      },
    );
  }
}
