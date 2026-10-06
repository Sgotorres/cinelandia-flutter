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
      backgroundColor: Colors.grey.shade50, // Fondo neutro
      appBar: AppBar(
        title: const Text('Resumen de la Orden', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0, // Quitamos la sombra del AppBar
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: carrito.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('El carrito está vacío', style: TextStyle(fontSize: 18, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                ],
              )
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 32),
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