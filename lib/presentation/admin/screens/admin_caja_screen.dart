// lib/presentation/admin/screens/admin_caja_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart'; // <-- Nueva importación

import '../widgets/panel_metricas_caja.dart';
import '../widgets/header_historial_caja.dart';
import '../widgets/ticket_venta_card.dart';
import '../../../providers/mesas_provider.dart'; // <-- Importación del nuevo provider

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
    
    // Solo inicializamos el stream, ya no descargamos las mesas aquí
    _ventasStream = Supabase.instance.client
        .from('pedidos')
        .stream(primaryKey: ['id'])
        .eq('estado', 'pagado')
        .order('fecha', ascending: false);
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el provider para obtener la caché de mesas de forma global
    final mesasCache = context.watch<MesasProvider>().mesasCache;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _ventasStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final ventas = snapshot.data ?? [];

          double ingresosTotales = 0.0;
          for (var venta in ventas) {
            ingresosTotales += (venta['total'] as num).toDouble();
          }

          return Column(
            children: [
              PanelMetricasCaja(
                ingresosTotales: ingresosTotales,
                cantidadVentas: ventas.length,
              ),
              const HeaderHistorialCaja(),
              Expanded(
                child: ventas.isEmpty
                    ? const Center(
                        child: Text(
                          'Caja limpia. Esperando nuevas ventas.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: ventas.length,
                        itemBuilder: (context, index) {
                          final venta = ventas[index];
                          final mesaId = venta['mesa_id'] as int;
                          
                          // Leemos el nombre de la mesa directamente desde la caché del Provider
                          final nombreMesa =
                              mesasCache[mesaId] ?? 'Mesa $mesaId';
                              
                          return TicketVentaCard(
                            venta: venta,
                            nombreMesa: nombreMesa,
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