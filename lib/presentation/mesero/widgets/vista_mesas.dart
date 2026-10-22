// lib/presentation/mesero/widgets/vista_mesas.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/mesas_provider.dart';
import '../../../providers/pedidos_provider.dart';
import '../../../data/models/mesa_model.dart';
import 'leyenda_mesas.dart';
import 'mesas_grid.dart';
import 'detector_pizza_lista.dart';
import 'resumen_estado_mesas.dart';

class VistaMesas extends StatefulWidget {
  const VistaMesas({super.key});

  @override
  State<VistaMesas> createState() => _VistaMesasState();
}

class _VistaMesasState extends State<VistaMesas> {
  late final Stream<List<MesaModel>> _mesasStream;
  late final Stream<List<Map<String, dynamic>>> _pedidosStream;
  
  // Instanciamos nuestro detector modular
  final DetectorPizzaLista _detectorPizzaLista = DetectorPizzaLista();

  @override
  void initState() {
    super.initState();
    _mesasStream = context.read<MesasProvider>().mesasStream;
    _pedidosStream = context.read<PedidosProvider>().obtenerPedidosActivosStream();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<List<MesaModel>>(
        stream: _mesasStream,
        builder: (context, mesasSnap) {
          if (mesasSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final mesasActivas = (mesasSnap.data ?? [])
              .where((m) => m.activa == true)
              .toList();

          if (mesasActivas.isEmpty) {
            return const Center(child: Text('No hay mesas activas.'));
          }

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: _pedidosStream,
            builder: (context, pedidosSnap) {
              final pedidosRaw = pedidosSnap.data ?? [];
              final pedidosActivos = pedidosRaw.where((p) {
                final e = p['estado']?.toString().toLowerCase();
                return e != 'pagado' && e != 'cancelada';
              }).toList();

              // 1. Vigilamos si alguna pizza pasó a 'lista' para sonar la campanita
              _detectorPizzaLista.verificar(
                context,
                pedidosActivos: pedidosActivos,
                mesasActivas: mesasActivas,
              );

              // 2. Calculamos los contadores y el mapa de pedidos en una sola línea
              final resumen = ResumenEstadoMesas.calcular(
                mesasActivas: mesasActivas,
                pedidosActivos: pedidosActivos,
              );

              // 3. Renderizamos los widgets limpios
              return Column(
                children: [
                  LeyendaMesas(
                    disponibles: resumen.disponibles,
                    pendientes: resumen.pendientes,
                    horno: resumen.horno,
                    lista: resumen.lista,
                    comiendo: resumen.comiendo,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: MesasGrid(
                      mesasActivas: mesasActivas,
                      pedidoPorMesa: resumen.pedidoPorMesa,
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