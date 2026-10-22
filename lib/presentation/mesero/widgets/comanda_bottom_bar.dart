// lib/presentation/mesero/widgets/comanda_bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../providers/pedidos_provider.dart';

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
          ),
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
            context.push(AppRoutes.tomarPedido);
          },
        ),
      ),
    );
  }
}
