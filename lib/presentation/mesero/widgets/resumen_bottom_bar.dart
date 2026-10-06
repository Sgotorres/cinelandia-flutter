import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/pedidos_provider.dart';

class ResumenBottomBar extends StatelessWidget {
  final PedidosProvider pedidosProvider;

  const ResumenBottomBar({super.key, required this.pedidosProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), // Bordes superiores muy redondeados
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Total a pagar', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w600)),
                Text(
                  '\$${pedidosProvider.totalPedido.toStringAsFixed(2)}', 
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.green)
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56, // Botón más alto para mejor hit-box
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: pedidosProvider.isLoading
                    ? null
                    : () async {
                        final exito = await pedidosProvider.enviarPedido();
                        if (exito && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('¡Pedido enviado a cocina!'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating, // Notificación flotante moderna
                            ),
                          );
                          context.go('/mesero');
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(pedidosProvider.errorMessage),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                child: pedidosProvider.isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Text('Enviar a Cocina', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}