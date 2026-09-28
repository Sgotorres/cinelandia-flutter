// lib/presentation/mesero/screens/resumen_pedido_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/pedidos_provider.dart';
import '../../../providers/menu_provider.dart'; // Importante para leer los nombres de los productos

class ResumenPedidoScreen extends StatelessWidget {
  const ResumenPedidoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pedidosProvider = context.watch<PedidosProvider>();
    final menuProvider = context.read<MenuProvider>(); // Leemos el menú para extraer los nombres
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
                      final item = carrito[index];
                      
                      // --- LÓGICA PARA NOMBRES REALES Y MITADES ---
                      String nombreP1 = 'Producto ${item.productoId}';
                      try {
                        nombreP1 = menuProvider.productos.firstWhere((p) => p.id == item.productoId).nombre;
                      } catch (_) {} // Por si el producto no se encuentra por alguna razón

                      String? nombreP2;
                      if (item.producto2Id != null) {
                        try {
                          nombreP2 = menuProvider.productos.firstWhere((p) => p.id == item.producto2Id).nombre;
                        } catch (_) {}
                      }

                      // Construye el texto final (Ej: "1/2 Margarita y 1/2 Pepperoni")
                      final nombreAMostrar = nombreP2 != null 
                          ? '1/2 $nombreP1 y 1/2 $nombreP2'
                          : nombreP1;
                      // ---------------------------------------------

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orangeAccent,
                          child: Text('${item.cantidad}x', style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(nombreAMostrar, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(item.talla != null && item.talla != 'Única' ? 'Tamaño: ${item.talla}' : 'Unidad'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Mostramos el subtotal del ítem
                            Text(
                              '\$${(item.precioUnitario * item.cantidad).toStringAsFixed(2)}', 
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => pedidosProvider.removerDelCarrito(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total a pagar:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text(
                              '\$${pedidosProvider.totalPedido.toStringAsFixed(2)}', 
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: pedidosProvider.isLoading
                                ? null
                                : () async {
                                    final exito = await pedidosProvider.enviarPedido();
                                    if (exito && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('¡Pedido enviado a cocina!'), 
                                          backgroundColor: Colors.green
                                        ),
                                      );
                                      // Regresamos a la pantalla de inicio (Selección de Mesa)
                                      Navigator.of(context).popUntil((route) => route.isFirst);
                                    } else if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(pedidosProvider.errorMessage), 
                                          backgroundColor: Colors.red
                                        ),
                                      );
                                    }
                                  },
                            child: pedidosProvider.isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Enviar a Cocina', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}