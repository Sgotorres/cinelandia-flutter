// lib/presentation/mesero/widgets/resumen_bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // 1. Importamos go_router
import '../../../providers/pedidos_provider.dart';

class ResumenBottomBar extends StatelessWidget {
  final PedidosProvider pedidosProvider;

  const ResumenBottomBar({super.key, required this.pedidosProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                          // 2. Reemplazamos el popUntil por context.go para volver al home
                          context.go('/mesero'); 
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
    );
  }
}