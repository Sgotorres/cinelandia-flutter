// lib/presentation/mesero/screens/mesero_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../providers/pedidos_provider.dart';
import 'tomar_pedido_screen.dart';
import 'comandas_screen.dart';

class MeseroHomeScreen extends StatefulWidget {
  const MeseroHomeScreen({super.key});

  @override
  State<MeseroHomeScreen> createState() => _MeseroHomeScreenState();
}

class _MeseroHomeScreenState extends State<MeseroHomeScreen> {
  int _selectedIndex = 0;
  
  // Streams persistentes para escuchar cambios en tiempo real en BD
  late final Stream<List<Map<String, dynamic>>> _mesasStream;
  late final Stream<List<Map<String, dynamic>>> _pedidosStream;

  @override
  void initState() {
    super.initState();
    
    // 1. Escuchamos la tabla 'mesas' para dibujarlas desde la BD
    _mesasStream = Supabase.instance.client
        .from('mesas')
        .stream(primaryKey: ['id'])
        .order('orden', ascending: true);

    // 2. Escuchamos la tabla 'pedidos' omitiendo pagados y cancelados
    _pedidosStream = Supabase.instance.client
        .from('pedidos')
        .stream(primaryKey: ['id'])
        .neq('estado', 'pagado')
        .neq('estado', 'cancelada');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildVistaMesas(context),
          const ComandasScreen(),
          const Center(
            child: Text(
              'Ajustes (En construcción)', 
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chair_alt), label: 'Mesas'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Comandas'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.indigo, 
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('C', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Sala Principal', 
            style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Pizza Planeta', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
              Row(
                children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  const Text('Activo', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black54), onPressed: () {}),
      ],
    );
  }

  Widget _buildVistaMesas(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Cálculo responsivo de columnas
    int columnas = 2;
    if (screenWidth >= 900) {
      columnas = 4;
    } else if (screenWidth >= 600) {
      columnas = 3;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estado de Mesas', 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              Row(
                children: [
                  _buildBadge('Libres', Colors.green),
                  const SizedBox(width: 4),
                  _buildBadge('Ocupadas', Colors.red),
                  const SizedBox(width: 4),
                  _buildBadge('En Espera', Colors.orange),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            // PRIMER STREAM: Carga las mesas disponibles desde la Base de Datos
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _mesasStream,
              builder: (context, mesasSnapshot) {
                if (mesasSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.indigo));
                }

                if (mesasSnapshot.hasError) {
                  return Center(
                    child: Text('Error al cargar mesas: ${mesasSnapshot.error}', style: const TextStyle(color: Colors.red)),
                  );
                }

                final rawMesas = mesasSnapshot.data ?? [];
                // Filtramos por si desde el panel de admin decidiste desactivar alguna mesa
                final mesasActivas = rawMesas.where((m) => m['activa'] == true).toList();

                if (mesasActivas.isEmpty) {
                  return const Center(child: Text('No hay mesas configuradas o activas.', style: TextStyle(fontSize: 16, color: Colors.grey)));
                }

                // SEGUNDO STREAM: Carga los pedidos activos para superponer el estado a las mesas
                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _pedidosStream,
                  builder: (context, pedidosSnapshot) {
                    if (pedidosSnapshot.hasError) {
                      return Center(
                        child: Text('Error al cargar pedidos: ${pedidosSnapshot.error}', style: const TextStyle(color: Colors.red)),
                      );
                    }

                    // Filtro de seguridad en memoria: descartamos pedidos inactivos
                    final rawPedidos = pedidosSnapshot.data ?? [];
                    final pedidosActivos = rawPedidos.where((p) {
                      final estado = p['estado']?.toString().toLowerCase();
                      return estado != 'pagado' && estado != 'cancelada';
                    }).toList();

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columnas,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: mesasActivas.length,
                      itemBuilder: (context, index) {
                        final mesa = mesasActivas[index];
                        final mesaId = mesa['id'] as int;
                        final mesaNombre = mesa['nombre'] as String;

                        // Obtenemos el pedido activo asociado a esta mesa usando mesa_id
                        final pedidosMesa = pedidosActivos.where((p) => p['mesa_id'] == mesaId).toList();
                        final pedidoActivo = pedidosMesa.isNotEmpty ? pedidosMesa.first : null;

                        String estadoMesa = 'Disponible';
                        Color colorMesa = Colors.green;

                        if (pedidoActivo != null) {
                          estadoMesa = pedidoActivo['estado'] ?? 'Ocupada';
                          if (estadoMesa == 'pendiente') colorMesa = Colors.orange;
                          else if (estadoMesa == 'horno') colorMesa = Colors.blue;
                          else if (estadoMesa == 'comiendo') colorMesa = Colors.purple;
                          else if (estadoMesa == 'lista') colorMesa = Colors.greenAccent.shade700;
                        }

                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            if (estadoMesa != 'Disponible' && pedidoActivo != null) {
                              // Si tiene pedido activo, cargamos el id numérico, el nombre y el id del pedido
                              context.read<PedidosProvider>().seleccionarMesa(mesaId, mesaNombre, pedidoId: pedidoActivo['id']);
                            } else {
                              // Si está libre, seleccionamos para crear un pedido nuevo desde cero
                              context.read<PedidosProvider>().seleccionarMesa(mesaId, mesaNombre);
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TomarPedidoScreen()),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02), 
                                  blurRadius: 8, 
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: colorMesa,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.restaurant, 
                                  size: 32, 
                                  color: estadoMesa == 'Disponible' ? Colors.grey : colorMesa,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  mesaNombre, // Mostramos el nombre dinámico desde la BD 
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                Text(
                                  estadoMesa.toUpperCase(),
                                  style: TextStyle(fontSize: 12, color: colorMesa, fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
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
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.shade50, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: color.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}