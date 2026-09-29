import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/pedidos_provider.dart';
import '../screens/tomar_pedido_screen.dart';

class MesaCard extends StatelessWidget {
  final int mesaId;
  final String mesaNombre;
  final Map<String, dynamic>? pedidoActivo;

  const MesaCard({super.key, required this.mesaId, required this.mesaNombre, this.pedidoActivo});

  Color _getColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente': return Colors.orange;
      case 'horno': return Colors.blue;
      case 'comiendo': return Colors.purple;
      case 'lista': return Colors.greenAccent.shade700;
      default: return Colors.green; // Disponible
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = pedidoActivo?['estado'] ?? 'Disponible';
    final color = _getColor(estado);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        final provider = context.read<PedidosProvider>();
        pedidoActivo != null 
            ? provider.seleccionarMesa(mesaId, mesaNombre, pedidoId: pedidoActivo!['id'])
            : provider.seleccionarMesa(mesaId, mesaNombre);

        Navigator.push(context, MaterialPageRoute(builder: (_) => const TomarPedidoScreen()));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Container(height: 6, decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(16)))),
            const Spacer(),
            Icon(Icons.restaurant, size: 32, color: estado == 'Disponible' ? Colors.grey : color),
            const SizedBox(height: 8),
            Text(mesaNombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            Text(estado.toUpperCase(), style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}