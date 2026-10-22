// lib/presentation/mesero/widgets/comanda_bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../providers/pedidos_provider.dart';
import 'modal_recibo_qr.dart';

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
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 56,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.indigo,
                  side: const BorderSide(color: Colors.indigo, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.qr_code_2, size: 22),
                label: const Text(
                  'Recibo QR',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ModalReciboQr(
                      pedidoId: pedidoId,
                      mesaNombre: mesaNombre,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: SizedBox(
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
                  'Añadir Más',
                  style: TextStyle(
                    fontSize: 15,
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
          ),
        ],
      ),
    );
  }
}
