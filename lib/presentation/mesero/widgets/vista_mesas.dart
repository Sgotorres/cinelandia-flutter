// lib/presentation/mesero/widgets/vista_mesas.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/mesas_provider.dart';
import '../providers/pedidos_provider.dart';
import '../../../domain/entities/mesa.dart';
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
  late final Stream<List<Mesa>> _mesasStream;
  late final Stream<List<Map<String, dynamic>>> _pedidosStream;

  final DetectorPizzaLista _detectorPizzaLista = DetectorPizzaLista();

  @override
  void initState() {
    super.initState();
    _mesasStream = context.read<MesasProvider>().mesasStream;
    _pedidosStream =
        context.read<PedidosProvider>().obtenerPedidosActivosStream();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<List<Mesa>>(
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

              _detectorPizzaLista.verificar(
                context,
                pedidosActivos: pedidosActivos,
                mesasActivas: mesasActivas,
              );

              final resumen = ResumenEstadoMesas.calcular(
                mesasActivas: mesasActivas,
                pedidosActivos: pedidosActivos,
              );

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
