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
  
  // 1. Declaramos el caché en memoria para guardar las mesas
  Map<int, String> _mesasCache = {};

  @override
  void initState() {
    super.initState();
    
    // 2. Cargamos todas las mesas UNA SOLA VEZ
    _cargarMesas();

    // SOLUCIÓN: Quitamos los filtros .neq() de la consulta de Supabase.
    // Escuchamos absolutamente todos los cambios en la tabla pedidos en tiempo real.
    _pedidosStream = Supabase.instance.client
        .from('pedidos')
        .stream(primaryKey: ['id'])
        .order('fecha', ascending: true);
  }

  // 3. Nuevo método que descarga las mesas y las guarda en el diccionario
  Future<void> _cargarMesas() async {
    try {
      final response = await Supabase.instance.client
          .from('mesas')
          .select('id, nombre');
      
      final cacheTemporal = <int, String>{};
      for (var mesa in response) {
        cacheTemporal[mesa['id'] as int] = mesa['nombre'] as String;
      }
      
      if (mounted) {
        setState(() {
          _mesasCache = cacheTemporal;
        });
      }
    } catch (e) {
      debugPrint('Error cargando mesas: $e');
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
        nuevoEstado = 'pagado'; // <-- Cambia a pagado en BD. El Stream general nos avisará del cambio.
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
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Extraemos todos los datos que llegaron del Stream
          final todosLosPedidos = snapshot.data ?? [];

          // SOLUCIÓN: Filtramos en memoria (Dart) para excluir los pagados y cancelados.
          // Como quitamos el .neq() de la consulta, ahora esta lista reaccionará al instante
          // cuando un estado cambie a "pagado", descartándolo de la UI limpia y eficientemente.
          final pedidosActivos = todosLosPedidos.where((p) {
            final estado = p['estado']?.toString().toLowerCase();
            return estado != 'pagado' && estado != 'cancelada';
          }).toList();

          // Verificamos si la lista filtrada quedó vacía
          if (pedidosActivos.isEmpty) {
            return const Center(
              child: Text(
                'No hay pedidos activos en este momento.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pedidosActivos.length, // Usamos la lista filtrada
            itemBuilder: (context, index) {
              final pedido = pedidosActivos[index]; // Usamos la lista filtrada
              final estado = pedido['estado'] ?? 'pendiente';
              final mesaId = pedido['mesa_id'] as int;
              final pedidoId = pedido['id'];

              Color colorBorde = Colors.grey;
              if (estado == 'pendiente') {
                colorBorde = Colors.orange;
              } else if (estado == 'horno') {
                colorBorde = Colors.blue;
              } else if (estado == 'lista') {
                colorBorde = Colors.greenAccent.shade700;
              } else if (estado == 'comiendo') {
                colorBorde = Colors.purple;
              }

              // 4. Leemos el nombre directamente de la memoria RAM
              final nombreMesa = _mesasCache[mesaId] ?? 'Mesa $mesaId';

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
      ),
    );
  }
}