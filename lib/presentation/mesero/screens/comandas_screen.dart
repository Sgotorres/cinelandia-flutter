// lib/presentation/mesero/screens/comandas_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/comanda_card.dart';
import '../../shared/providers/mesas_provider.dart';
import '../providers/pedidos_provider.dart';

class ComandasScreen extends StatefulWidget {
  const ComandasScreen({super.key});

  @override
  State<ComandasScreen> createState() => _ComandasScreenState();
}

class _ComandasScreenState extends State<ComandasScreen> {
  late final Stream<List<Map<String, dynamic>>> _pedidosStream;

  @override
  void initState() {
    super.initState();
    _pedidosStream =
        context.read<PedidosProvider>().obtenerTodosLosPedidosStream();
  }

  @override
  Widget build(BuildContext context) {
    final mesasCache = context.watch<MesasProvider>().mesasCache;

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
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            );
          }

          final todosLosPedidos = snapshot.data ?? [];
          final pedidosActivos = todosLosPedidos.where((p) {
            final estado = p['estado']?.toString().toLowerCase();
            return estado != 'pagado' && estado != 'cancelada';
          }).toList();

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
              final mesaId = pedido['mesa_id'] as int?;
              final total = (pedido['total'] as num).toDouble();
              final pedidoId = pedido['id'];

              final nombreMesa = mesaId != null
                  ? (mesasCache[mesaId] ?? 'Mesa $mesaId')
                  : 'Mesa Eliminada';

              return ComandaCard(
                pedidoId: pedidoId,
                mesaId: mesaId,
                nombreMesa: nombreMesa,
                total: total,
                estado: estado,
              );
            },
          );
        },
      ),
    );
  }
}
