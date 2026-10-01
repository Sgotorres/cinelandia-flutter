// lib/presentation/admin/screens/admin_pedidos_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPedidosScreen extends StatefulWidget {
  const AdminPedidosScreen({super.key});

  @override
  State<AdminPedidosScreen> createState() => _AdminPedidosScreenState();
}

class _AdminPedidosScreenState extends State<AdminPedidosScreen> {
  late final Stream<List<Map<String, dynamic>>> _pedidosStream;

  @override
  void initState() {
    super.initState();
    // Esta consulta es "en vivo". Si un pedido pasa a 'pagado',
    // Supabase lo saca de este flujo automáticamente.
    _pedidosStream = Supabase.instance.client
        .from('pedidos')
        .stream(primaryKey: ['id'])
        .neq('estado', 'pagado')
        .neq('estado', 'cancelada')
        .order('fecha', ascending: true);
  }

  Future<String> _obtenerNombreMesa(int mesaId) async {
    try {
      final response = await Supabase.instance.client
          .from('mesas')
          .select('nombre')
          .eq('id', mesaId)
          .single();
      return response['nombre'] as String;
    } catch (e) {
      return 'Mesa $mesaId';
    }
  }

  Future<void> _avanzarEstado(int pedidoId, String estadoActual) async {
    String nuevoEstado;
    switch (estadoActual.toLowerCase()) {
      case 'pendiente':
        nuevoEstado = 'horno';
        break;
      case 'horno':
        nuevoEstado = 'lista';
        break;
      case 'lista':
        nuevoEstado = 'comiendo';
        break;
      case 'comiendo':
        nuevoEstado = 'pagado'; // <-- Al cambiar a esto, el Stream lo expulsa de la pantalla.
        break;
      default:
        return;
    }

    try {
      await Supabase.instance.client
          .from('pedidos')
          .update({'estado': nuevoEstado})
          .eq('id', pedidoId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildBotonAccion(String estadoActual, int pedidoId) {
    String texto = '';
    IconData icono = Icons.help;
    Color color = Colors.grey;

    switch (estadoActual.toLowerCase()) {
      case 'pendiente':
        texto = 'Meter al Horno';
        icono = Icons.local_fire_department;
        color = Colors.orange;
        break;
      case 'horno':
        texto = 'Marcar como Lista';
        icono = Icons.soup_kitchen;
        color = Colors.blue;
        break;
      case 'lista':
        texto = 'Entregar en Mesa';
        icono = Icons.room_service;
        color = Colors.greenAccent.shade700;
        break;
      case 'comiendo':
        texto = 'Cobrar y Liberar';
        icono = Icons.payments;
        color = Colors.purple;
        break;
    }

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icono, size: 20),
      label: Text(
        texto,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      onPressed: () => _avanzarEstado(pedidoId, estadoActual),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _pedidosStream,
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No hay pedidos activos en este momento.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final pedidos = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              final estado = pedido['estado'] ?? 'pendiente';
              final mesaId = pedido['mesa_id'] as int;
              final pedidoId = pedido['id'];

              Color colorBorde = Colors.grey;
              if (estado == 'pendiente')
                colorBorde = Colors.orange;
              else if (estado == 'horno')
                colorBorde = Colors.blue;
              else if (estado == 'lista')
                colorBorde = Colors.greenAccent.shade700;
              else if (estado == 'comiendo')
                colorBorde = Colors.purple;

              return FutureBuilder<String>(
                future: _obtenerNombreMesa(mesaId),
                builder: (context, mesaSnapshot) {
                  final nombreMesa = mesaSnapshot.data ?? 'Cargando...';

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colorBorde, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                nombreMesa,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorBorde.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  estado.toUpperCase(),
                                  style: TextStyle(
                                    color: colorBorde,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Text(
                            'Pedido #$pedidoId',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: _buildBotonAccion(estado, pedidoId),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
