// lib/presentation/admin/widgets/pedido_cocina_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../mesero/providers/pedidos_provider.dart';
import 'lista_articulos_pedido.dart';

class PedidoCocinaCard extends StatelessWidget {
  final Map<String, dynamic> pedido;
  final String nombreMesa;

  const PedidoCocinaCard({
    super.key,
    required this.pedido,
    required this.nombreMesa,
  });

  Future<void> _avanzarEstado(
    BuildContext context,
    int pedidoId,
    String estadoActual,
  ) async {
    final mapaSiguiente = {
      'pendiente': 'horno',
      'horno': 'lista',
      'lista': 'comiendo',
      'comiendo': 'pagado',
    };
    final nuevoEstado = mapaSiguiente[estadoActual.toLowerCase()];
    if (nuevoEstado == null) return;

    final error = await context.read<PedidosProvider>().actualizarEstado(
      pedidoId,
      nuevoEstado,
    );
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'horno':
        return Colors.blue;
      case 'lista':
        return Colors.greenAccent.shade700;
      case 'comiendo':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBotonAccion(
    BuildContext context,
    String estadoActual,
    int pedidoId,
  ) {
    final config = <String, (String, IconData)>{
      'pendiente': ('Meter al Horno', Icons.local_fire_department),
      'horno': ('Marcar como Lista', Icons.soup_kitchen),
      'lista': ('Entregar en Mesa', Icons.room_service),
      'comiendo': ('Cobrar y Liberar', Icons.payments),
    }[estadoActual.toLowerCase()];

    if (config == null) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: _colorEstado(estadoActual),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        icon: Icon(config.$2, size: 20),
        label: Text(
          config.$1,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        onPressed: () => _avanzarEstado(context, pedidoId, estadoActual),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = pedido['estado']?.toString() ?? 'pendiente';
    final pedidoId = pedido['id'] as int;
    final colorBorde = _colorEstado(estado);

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorBorde, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    nombreMesa,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorBorde.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    estado.toUpperCase(),
                    style: TextStyle(
                      color: colorBorde,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Pedido #$pedidoId',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const Divider(height: 16),
            ListaArticulosPedido(pedidoId: pedidoId),
            const SizedBox(height: 16),
            _buildBotonAccion(context, estado, pedidoId),
          ],
        ),
      ),
    );
  }
}
