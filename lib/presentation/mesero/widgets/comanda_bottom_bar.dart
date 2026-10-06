// lib/presentation/mesero/widgets/comanda_bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/pedidos_provider.dart';
import '../screens/tomar_pedido_screen.dart';

class ComandaBottomBar extends StatelessWidget {
  final int mesaId;
  final String mesaNombre;
  final int pedidoId;

  const ComandaBottomBar({
    super.key,
    required this.mesaId,
    required this.mesaNombre,
    required this.pedidoId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -10),
          )
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          label: const Text(
            'Añadir Más Productos',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            context.read<PedidosProvider>().seleccionarMesa(
                  mesaId,
                  mesaNombre,
                  pedidoId: pedidoId,
                );
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TomarPedidoScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}