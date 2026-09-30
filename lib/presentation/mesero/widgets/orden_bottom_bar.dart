// lib/presentation/mesero/widgets/orden_bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // 1. Agregamos la importación de go_router
import '../../../providers/pedidos_provider.dart';
// Eliminamos la importación de ResumenPedidoScreen

class OrdenBottomBar extends StatelessWidget {
  const OrdenBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final pedidosProvider = context.watch<PedidosProvider>();
    final carrito = pedidosProvider.carrito;
    final total = pedidosProvider.totalPedido;

    // Si no hay nada en el carrito, ocultamos la barra
    if (carrito.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${carrito.length} ítems', style: const TextStyle(color: Colors.grey)),
                Text(
                  '\$${total.toStringAsFixed(2)}', 
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // 2. Reemplazamos Navigator.push por la navegación declarativa
                context.push('/mesero/resumen-pedido');
              },
              child: const Text('Ver Resumen', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}