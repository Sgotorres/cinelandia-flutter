// lib/presentation/mesero/widgets/comanda_lista_productos.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/menu_provider.dart';
import '../../../providers/pedidos_provider.dart';
import 'comanda_item_tile.dart';

class ComandaListaProductos extends StatefulWidget {
  final int pedidoId;

  const ComandaListaProductos({super.key, required this.pedidoId});

  @override
  State<ComandaListaProductos> createState() => _ComandaListaProductosState();
}

class _ComandaListaProductosState extends State<ComandaListaProductos> {
  late final Stream<List<Map<String, dynamic>>> _detallesStream;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _detallesStream = context.read<PedidosProvider>().detallesPedidoStream(
      widget.pedidoId,
    );
  }

  Future<void> _eliminarProducto(int detalleId, int totalItems) async {
    if (_isDeleting) return;
    setState(() => _isDeleting = true);

    // Si es el último producto, cerramos el modal antes de borrar
    if (totalItems == 1 && mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    final errorMsg = await context.read<PedidosProvider>().eliminarDetalle(
      detalleId,
      widget.pedidoId,
    );

    if (mounted) {
      if (errorMsg != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
      setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos context.watch por si el menú se actualiza mientras el modal está abierto
    final menuProvider = context.watch<MenuProvider>();

    return Expanded(
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _detallesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final detalles = snapshot.data ?? [];
          if (detalles.isEmpty) return const SizedBox.shrink();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: detalles.length,
            itemBuilder: (context, index) {
              final item = detalles[index];
              final int cantidad = item['cantidad'] ?? 1;
              final double subtotal = cantidad * (item['precio_unitario'] as num).toDouble();
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

              return ComandaItemTile(
                nombre: nombreAMostrar,
                cantidad: cantidad,
                talla: talla,
                subtotal: subtotal,
                isDeleting: _isDeleting,
                onEliminar: () => _eliminarProducto(item['id'], detalles.length),
              );
            },
          );
        },
      ),
    );
  }
}