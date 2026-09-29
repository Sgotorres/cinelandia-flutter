import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/comanda_detalles_modal.dart'; // Importación del nuevo modal

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
    _pedidosStream = Supabase.instance.client
        .from('pedidos')
        .stream(primaryKey: ['id'])
        .neq('estado', 'pagado')
        .neq('estado', 'cancelada')
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Comandas Activas', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _pedidosStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error de Supabase: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.indigo));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay comandas activas', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          final pedidos = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              final estado = pedido['estado'] ?? 'pendiente';
              final mesaId = pedido['mesa_id'] as int;
              final total = (pedido['total'] as num).toDouble();
              final pedidoId = pedido['id'];

              Color colorEstado = Colors.grey;
              if (estado == 'pendiente') colorEstado = Colors.orange;
              else if (estado == 'horno') colorEstado = Colors.blue;
              else if (estado == 'comiendo') colorEstado = Colors.purple;
              else if (estado == 'lista') colorEstado = Colors.greenAccent.shade700;

              return FutureBuilder<String>(
                future: _obtenerNombreMesa(mesaId),
                builder: (context, mesaSnapshot) {
                  final nombreMesa = mesaSnapshot.data ?? 'Cargando...';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: colorEstado.withOpacity(0.2),
                        child: Icon(Icons.receipt_long, color: colorEstado),
                      ),
                      title: Text(nombreMesa, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('Total: \$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: colorEstado, borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          estado.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => ComandaDetallesModal(
                            pedidoId: pedidoId,
                            mesaId: mesaId,
                            mesaNombre: nombreMesa,
                          ),
                        );
                      },
                    ),
                  );
                }
              );
            },
          );
        },
      ),
    );
  }
}