// lib/presentation/admin/screens/admin_caja_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/stats_tile.dart';

class AdminCajaScreen extends StatefulWidget {
  const AdminCajaScreen({super.key});

  @override
  State<AdminCajaScreen> createState() => _AdminCajaScreenState();
}

class _AdminCajaScreenState extends State<AdminCajaScreen> {
  late final Stream<List<Map<String, dynamic>>> _ventasStream;

  @override
  void initState() {
    super.initState();
    // Traemos SOLO los pedidos que ya fueron cobrados (estado 'pagado')
    // Los ordenamos de forma descendente para ver el más reciente primero
    _ventasStream = Supabase.instance.client
        .from('pedidos')
        .stream(primaryKey: ['id'])
        .eq('estado', 'pagado')
        .order('fecha', ascending: false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _ventasStream,
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final ventas = snapshot.data ?? [];

          // Calculamos las métricas dinámicamente
          double ingresosTotales = 0.0;
          for (var venta in ventas) {
            ingresosTotales += (venta['total'] as num).toDouble();
          }

          return Column(
            children: [
              // PANEL DE MÉTRICAS SUPERIOR
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    StatsTile(
                      title: 'Ingresos',
                      value: '\$${ingresosTotales.toStringAsFixed(2)}',
                      icon: Icons.attach_money,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 12),
                    StatsTile(
                      title: 'Completados',
                      value: '${ventas.length}',
                      icon: Icons.receipt_long,
                      color: Colors.indigo,
                    ),
                  ],
                ),
              ),

              // HISTORIAL DE TICKETS PAGADOS
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Historial de tickets',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ventas.isEmpty
                    ? const Center(
                        child: Text(
                          'Aún no hay ventas registradas.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: ventas.length,
                        itemBuilder: (context, index) {
                          final venta = ventas[index];
                          final mesaId = venta['mesa_id'] as int;
                          final total = (venta['total'] as num).toDouble();
                          final fechaRaw = venta['fecha'] as String;

                          // Formateo simple de hora (ej: 14:30)
                          final fechaObj = DateTime.parse(fechaRaw).toLocal();
                          final horaStr =
                              '${fechaObj.hour.toString().padLeft(2, '0')}:${fechaObj.minute.toString().padLeft(2, '0')}';

                          return FutureBuilder<String>(
                            future: _obtenerNombreMesa(mesaId),
                            builder: (context, mesaSnap) {
                              final nombreMesa = mesaSnap.data ?? 'Cargando...';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.greenAccent,
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    'Ticket #${venta['id']} - $nombreMesa',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Cobrado a las $horaStr',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  trailing: Text(
                                    '\$${total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
