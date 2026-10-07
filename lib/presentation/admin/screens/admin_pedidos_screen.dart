// lib/presentation/admin/screens/admin_pedidos_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import '../widgets/pedido_cocina_card.dart';
import '../../../providers/mesas_provider.dart'; // <-- Importación del nuevo provider

class AdminPedidosScreen extends StatefulWidget {
  const AdminPedidosScreen({super.key});

  @override
  State<AdminPedidosScreen> createState() => _AdminPedidosScreenState();
}

class _AdminPedidosScreenState extends State<AdminPedidosScreen> {
  late final Stream<List<Map<String, dynamic>>> _pedidosStream;

  @override
  void initState() {
    super.initState();

    _pedidosStream = Supabase.instance.client
        .from('pedidos')
        .stream(primaryKey: ['id'])
        .order('fecha', ascending: true);
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el Provider para obtener los nombres de las mesas
    final mesasCache = context.watch<MesasProvider>().mesasCache;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _pedidosStream,
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          final todosLosPedidos = snapshot.data ?? [];
          final pedidosActivos = todosLosPedidos.where((p) {
            final estado = p['estado']?.toString().toLowerCase();
            return estado != 'pagado' && estado != 'cancelada';
          }).toList();

          if (pedidosActivos.isEmpty) {
            return const Center(
              child: Text(
                'No hay pedidos activos en este momento.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pedidosActivos.length,
            itemBuilder: (context, index) {
              final pedido = pedidosActivos[index];

              // 1. Permitimos valores nulos
              final mesaId = pedido['mesa_id'] as int?;

              // 2. Manejamos el caso de la mesa eliminada
              final nombreMesa = mesaId != null
                  ? (mesasCache[mesaId] ?? 'Mesa $mesaId')
                  : 'Mesa Eliminada';

              return PedidoCocinaCard(pedido: pedido, nombreMesa: nombreMesa);
            },
          );
        },
      ),
    );
  }
}
