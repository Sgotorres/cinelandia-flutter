// lib/presentation/admin/widgets/pedido_cocina_card.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lista_articulos_pedido.dart';

class PedidoCocinaCard extends StatelessWidget {
  final Map<String, dynamic> pedido;
  final String nombreMesa;

  const PedidoCocinaCard({
    super.key,
    required this.pedido,
    required this.nombreMesa,
  });

  Future<void> _avanzarEstado(BuildContext context, int pedidoId, String estadoActual) async {
    String nuevoEstado;
    switch (estadoActual.toLowerCase()) {
      case 'pendiente': nuevoEstado = 'horno'; break;
      case 'horno': nuevoEstado = 'lista'; break;
      case 'lista': nuevoEstado = 'comiendo'; break;
      case 'comiendo': nuevoEstado = 'pagado'; break;
      default: return;
    }

    try {
      await Supabase.instance.client.from('pedidos').update({'estado': nuevoEstado}).eq('id', pedidoId);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildBotonAccion(BuildContext context, String estadoActual, int pedidoId) {
    String texto = '';
    IconData icono = Icons.help;
    Color color = Colors.grey;

    switch (estadoActual.toLowerCase()) {
      case 'pendiente': texto = 'Meter al Horno'; icono = Icons.local_fire_department; color = Colors.orange; break;
      case 'horno': texto = 'Marcar como Lista'; icono = Icons.soup_kitchen; color = Colors.blue; break;
      case 'lista': texto = 'Entregar en Mesa'; icono = Icons.room_service; color = Colors.greenAccent.shade700; break;
      case 'comiendo': texto = 'Cobrar y Liberar'; icono = Icons.payments; color = Colors.purple; break;
      default: return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        icon: Icon(icono, size: 20),
        label: Text(texto, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        onPressed: () => _avanzarEstado(context, pedidoId, estadoActual),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = pedido['estado'] ?? 'pendiente';
    final pedidoId = pedido['id'];

    Color colorBorde = Colors.grey;
    if (estado == 'pendiente') colorBorde = Colors.orange;
    else if (estado == 'horno') colorBorde = Colors.blue;
    else if (estado == 'lista') colorBorde = Colors.greenAccent.shade700;
    else if (estado == 'comiendo') colorBorde = Colors.purple;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero, // El espaciado entre tarjetas lo maneja el Wrap exterior
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorBorde, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Crucial para que crezca solo lo necesario según sus hijos
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera de la tarjeta: Mesa y Estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    nombreMesa, 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorBorde.withOpacity(0.1), 
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    estado.toUpperCase(),
                    style: TextStyle(color: colorBorde, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Pedido #$pedidoId', style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
            const Divider(height: 16),
            
            // Listado de artículos de la comanda con crecimiento dinámico
            ListaArticulosPedido(pedidoId: pedidoId),
            
            const SizedBox(height: 16),
            
            // Botón de acción al pie de la tarjeta
            _buildBotonAccion(context, estado, pedidoId),
          ],
        ),
      ),
    );
  }
}