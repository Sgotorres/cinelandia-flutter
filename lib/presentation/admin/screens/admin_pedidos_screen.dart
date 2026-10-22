// lib/presentation/admin/screens/admin_pedidos_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/di/injection.dart' as di;
import '../../../core/utils/sound_service.dart';
import '../../shared/providers/mesas_provider.dart';
import '../../mesero/providers/pedidos_provider.dart';
import '../widgets/pedido_cocina_card.dart';

class AdminPedidosScreen extends StatefulWidget {
  const AdminPedidosScreen({super.key});

  @override
  State<AdminPedidosScreen> createState() => _AdminPedidosScreenState();
}

class _AdminPedidosScreenState extends State<AdminPedidosScreen> {
  late final Stream<List<Map<String, dynamic>>> _pedidosStream;
  final Map<int, String> _estadosConocidos = {};
  bool _esCargaInicial = true;

  @override
  void initState() {
    super.initState();
    _pedidosStream =
        context.read<PedidosProvider>().obtenerPedidosActivosStream();
  }

  void _verificarNuevosPedidos(List<Map<String, dynamic>> pedidosActivos) {
    if (_esCargaInicial) {
      for (final p in pedidosActivos) {
        _estadosConocidos[p['id'] as int] =
            p['estado']?.toString().toLowerCase() ?? 'pendiente';
      }
      _esCargaInicial = false;
      return;
    }

    bool llegoPedidoNuevo = false;
    final nuevosEstados = <int, String>{};
    for (final p in pedidosActivos) {
      final id = p['id'] as int;
      final estado = p['estado']?.toString().toLowerCase() ?? 'pendiente';
      if (estado == 'pendiente' && _estadosConocidos[id] != 'pendiente') {
        llegoPedidoNuevo = true;
      }
      nuevosEstados[id] = estado;
    }
    _estadosConocidos
      ..clear()
      ..addAll(nuevosEstados);

    if (llegoPedidoNuevo) di.sl<SoundService>().tocarCampanita();
  }

  @override
  Widget build(BuildContext context) {
    final mesasCache = context.watch<MesasProvider>().mesasCache;

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

          final pedidosActivos = (snapshot.data ?? []).where((p) {
            final estado = p['estado']?.toString().toLowerCase();
            return estado != 'pagado' && estado != 'cancelada';
          }).toList();

          _verificarNuevosPedidos(pedidosActivos);

          if (pedidosActivos.isEmpty) {
            return const Center(
              child: Text(
                'No hay pedidos activos en este momento.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final cols = w >= 1200 ? 3 : (w >= 800 ? 2 : 1);
                final cardWidth = (w - (16 * (cols - 1))) / cols;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: pedidosActivos.map((pedido) {
                    final mesaId = pedido['mesa_id'] as int?;
                    final nombreMesa = mesaId != null
                        ? (mesasCache[mesaId] ?? 'Mesa $mesaId')
                        : 'Mesa Eliminada';
                    return SizedBox(
                      width: cardWidth,
                      child: PedidoCocinaCard(
                        pedido: pedido,
                        nombreMesa: nombreMesa,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
