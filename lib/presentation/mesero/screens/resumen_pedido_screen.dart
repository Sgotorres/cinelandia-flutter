// lib/presentation/mesero/screens/resumen_pedido_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/pedidos_provider.dart';
import '../../../providers/menu_provider.dart';
import '../widgets/carrito_item_tile.dart';
import '../widgets/resumen_bottom_bar.dart';

class ResumenPedidoScreen extends StatelessWidget {
  const ResumenPedidoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pedidosProvider = context.watch<PedidosProvider>();
    final menuProvider = context.read<MenuProvider>();
    final carrito = pedidosProvider.carrito;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de la Orden'),
        backgroundColor: Colors.redAccent,
      ),
      body: carrito.isEmpty
          ? const Center(child: Text('El carrito está vacío', style: TextStyle(fontSize: 18)))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: carrito.length,
                    itemBuilder: (context, index) {
                      return CarritoItemTile(
                        item: carrito[index],
                        menuProvider: menuProvider,
                        onEliminar: () => pedidosProvider.removerDelCarrito(index),
                      );
                    },
                  ),
                ),
                ResumenBottomBar(pedidosProvider: pedidosProvider),
              ],
            ),
    );
  }
}