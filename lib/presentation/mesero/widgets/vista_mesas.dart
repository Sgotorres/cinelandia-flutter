// lib/presentation/mesero/widgets/vista_mesas.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/mesas_provider.dart';
import '../../../providers/pedidos_provider.dart';
import '../../../data/models/mesa_model.dart';
import 'leyenda_mesas.dart';
import 'mesa_card.dart';

class VistaMesas extends StatefulWidget {
  const VistaMesas({super.key});

  @override
  State<VistaMesas> createState() => _VistaMesasState();
}

class _VistaMesasState extends State<VistaMesas> {
  late final Stream<List<MesaModel>> _mesasStream;
  late final Stream<List<Map<String, dynamic>>> _pedidosStream;

  @override
  void initState() {
    super.initState();
    // Delegamos ambas consultas a los providers
    _mesasStream = context.read<MesasProvider>().mesasStream;
    _pedidosStream = context
        .read<PedidosProvider>()
        .obtenerPedidosActivosStream();
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;
    final columnas = ancho >= 900 ? 4 : (ancho >= 600 ? 3 : 2);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<List<MesaModel>>(
        stream: _mesasStream,
        builder: (context, mesasSnap) {
          if (mesasSnap.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          final mesasActivas = (mesasSnap.data ?? [])
              .where((m) => m.activa == true)
              .toList();
          if (mesasActivas.isEmpty)
            return const Center(child: Text('No hay mesas activas.'));

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: _pedidosStream,
            builder: (context, pedidosSnap) {
              // Limpieza de memoria: asegura descartar pedidos pagados instantáneamente
              final pedidosRaw = pedidosSnap.data ?? [];
              final pedidosActivos = pedidosRaw.where((p) {
                final e = p['estado']?.toString().toLowerCase();
                return e != 'pagado' && e != 'cancelada';
              }).toList();

              int countDisponible = 0,
                  countPendiente = 0,
                  countHorno = 0,
                  countLista = 0,
                  countComiendo = 0;

              // La iteración usa la lista limpia en memoria
              for (var mesa in mesasActivas) {
                final pedido = pedidosActivos
                    .where((p) => p['mesa_id'] == mesa.id)
                    .firstOrNull;
                final estado =
                    pedido?['estado']?.toString().toLowerCase() ?? 'disponible';

                switch (estado) {
                  case 'pendiente':
                    countPendiente++;
                    break;
                  case 'horno':
                    countHorno++;
                    break;
                  case 'lista':
                    countLista++;
                    break;
                  case 'comiendo':
                    countComiendo++;
                    break;
                  default:
                    countDisponible++;
                    break;
                }
              }

              return Column(
                children: [
                  LeyendaMesas(
                    disponibles: countDisponible,
                    pendientes: countPendiente,
                    horno: countHorno,
                    lista: countLista,
                    comiendo: countComiendo,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columnas,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: mesasActivas.length,
                      itemBuilder: (context, i) {
                        final mesa = mesasActivas[i];
                        final pedido = pedidosActivos
                            .where((p) => p['mesa_id'] == mesa.id)
                            .firstOrNull;

                        return MesaCard(
                          mesaId: mesa.id,
                          mesaNombre: mesa.nombre,
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
