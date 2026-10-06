import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'leyenda_mesas.dart';
import 'mesa_card.dart';

class VistaMesas extends StatefulWidget {
  const VistaMesas({super.key});

  @override
  State<VistaMesas> createState() => _VistaMesasState();
}

class _VistaMesasState extends State<VistaMesas> {
  late final Stream<List<Map<String, dynamic>>> _mesasStream;
  late final Stream<List<Map<String, dynamic>>> _pedidosStream;

  @override
  void initState() {
    super.initState();
    final supabase = Supabase.instance.client;
    _mesasStream = supabase.from('mesas').stream(primaryKey: ['id']).order('orden');

    // Escuchamos la tabla sin encadenar filtros inválidos
    _pedidosStream = supabase.from('pedidos').stream(primaryKey: ['id']);
  }

@override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;
    final columnas = ancho >= 900 ? 4 : (ancho >= 600 ? 3 : 2);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _mesasStream,
        builder: (context, mesasSnap) {
          if (mesasSnap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final mesasActivas = (mesasSnap.data ?? []).where((m) => m['activa'] == true).toList();
          if (mesasActivas.isEmpty) return const Center(child: Text('No hay mesas activas.'));

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: _pedidosStream,
            builder: (context, pedidosSnap) {
              final todosLosPedidos = pedidosSnap.data ?? [];
              
              final pedidosActivos = todosLosPedidos.where((p) {
                final estado = p['estado']?.toString().toLowerCase();
                return estado != 'pagado' && estado != 'cancelada';
              }).toList();

              // --- LÓGICA NUEVA: CALCULAR CONTADORES ---
              int countDisponible = 0;
              int countPendiente = 0;
              int countHorno = 0;
              int countLista = 0;
              int countComiendo = 0;

              for (var mesa in mesasActivas) {
                final pedido = pedidosActivos.where((p) => p['mesa_id'] == mesa['id']).firstOrNull;
                final estado = pedido?['estado']?.toString().toLowerCase() ?? 'disponible';
                
                switch (estado) {
                  case 'pendiente': countPendiente++; break;
                  case 'horno': countHorno++; break;
                  case 'lista': countLista++; break;
                  case 'comiendo': countComiendo++; break;
                  default: countDisponible++; break;
                }
              }

              return Column(
                children: [
                  // --- LEYENDA AHORA RECIBE LOS DATOS DINÁMICOS ---
                  LeyendaMesas(
                    disponibles: countDisponible,
                    pendientes: countPendiente,
                    horno: countHorno,
                    lista: countLista,
                    comiendo: countComiendo,
                  ),
                  const SizedBox(height: 20),
                  
                  // --- TU GRIDVIEW ORIGINAL ---
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columnas, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.1,
                      ),
                      itemCount: mesasActivas.length,
                      itemBuilder: (context, i) {
                        final mesa = mesasActivas[i];
                        final pedido = pedidosActivos.where((p) => p['mesa_id'] == mesa['id']).firstOrNull;
                        
                        return MesaCard(
                          mesaId: mesa['id'],
                          mesaNombre: mesa['nombre'],
                          pedidoActivo: pedido,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}