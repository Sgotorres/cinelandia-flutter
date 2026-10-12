// lib/presentation/admin/screens/admin_pedidos_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import '../widgets/pedido_cocina_card.dart';
import '../../../providers/mesas_provider.dart';

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

          // Usamos SingleChildScrollView y un Wrap para que las tarjetas crezcan
          // orgánicamente según sus productos y se acomoden en la pantalla.
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculamos cuántas columnas caben según el ancho de la pantalla
                double anchoPantalla = constraints.maxWidth;
                int columnas = 1;
                if (anchoPantalla >= 1200) {
                  columnas = 3;
                } else if (anchoPantalla >= 800) {
                  columnas = 2;
                }

                double anchoTarjeta = (anchoPantalla - (16 * (columnas - 1))) / columnas;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: pedidosActivos.map((pedido) {
                    final mesaId = pedido['mesa_id'] as int?;
                    final nombreMesa = mesaId != null
                        ? (mesasCache[mesaId] ?? 'Mesa $mesaId')
                        : 'Mesa Eliminada';

                    return SizedBox(
                      width: anchoTarjeta,
                      child: PedidoCocinaCard(pedido: pedido, nombreMesa: nombreMesa),
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