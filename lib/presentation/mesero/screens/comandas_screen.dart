import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/comanda_detalles_modal.dart'; // Importación del nuevo modal

class ComandasScreen extends StatefulWidget {
  const ComandasScreen({super.key});

  @override
  State<ComandasScreen> createState() => _ComandasScreenState();
}

class _ComandasScreenState extends State<ComandasScreen> {
  late final Stream<List<Map<String, dynamic>>> _pedidosStream;
  
  // 1. Declaramos el caché en memoria para guardar las mesas
  Map<int, String> _mesasCache = {};

  @override
  void initState() {
    super.initState();
    
    // 2. Cargamos todas las mesas UNA SOLA VEZ
    _cargarMesas();
    
    // Escuchamos el stream SIN encadenar filtros '.neq' para evitar bloqueos
    _pedidosStream = Supabase.instance.client
        .from('pedidos')
        .stream(primaryKey: ['id'])
        .order('fecha', ascending: false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Comandas Activas',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _pedidosStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error de Supabase: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            );
          }

          // Aplicamos el filtrado en memoria (Dart) de los pedidos
          final todosLosPedidos = snapshot.data ?? [];
          final pedidosActivos = todosLosPedidos.where((p) {
            final estado = p['estado']?.toString().toLowerCase();
            return estado != 'pagado' && estado != 'cancelada';
          }).toList();

          // Validamos si la lista filtrada está vacía
          if (pedidosActivos.isEmpty) {
            return const Center(
              child: Text(
                'No hay comandas activas',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pedidosActivos.length, 
            itemBuilder: (context, index) {
              final pedido = pedidosActivos[index]; 
              final estado = pedido['estado'] ?? 'pendiente';
              final mesaId = pedido['mesa_id'] as int;
              final total = (pedido['total'] as num).toDouble();
              final pedidoId = pedido['id'];

              Color colorEstado = Colors.grey;
              if (estado == 'pendiente') {
                colorEstado = Colors.orange;
              } else if (estado == 'horno') {
                colorEstado = Colors.blue;
              } else if (estado == 'comiendo') {
                colorEstado = Colors.purple;
              } else if (estado == 'lista') {
                colorEstado = Colors.greenAccent.shade700;
              }

              // 4. Eliminamos el FutureBuilder. Leemos el nombre directamente de la memoria RAM
              final nombreMesa = _mesasCache[mesaId] ?? 'Mesa $mesaId';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: colorEstado.withOpacity(0.2),
                    child: Icon(Icons.receipt_long, color: colorEstado),
                  ),
                  title: Text(
                    nombreMesa,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Total: \$${total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorEstado,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      estado.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => ComandaDetallesModal(
                        pedidoId: pedidoId,
                        mesaId: mesaId,
                        mesaNombre: nombreMesa,
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}