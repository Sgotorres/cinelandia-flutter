// lib/presentation/admin/widgets/admin_mesas_tab.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'formulario_mesa_dialog.dart';
import 'mesa_list_tile.dart';

class AdminMesasTab extends StatefulWidget {
  const AdminMesasTab({super.key});

  @override
  State<AdminMesasTab> createState() => _AdminMesasTabState();
}

class _AdminMesasTabState extends State<AdminMesasTab> {
  final _supabase = Supabase.instance.client;
  late final Stream<List<Map<String, dynamic>>> _mesasStream;

  @override
  void initState() {
    super.initState();
    _mesasStream = _supabase
        .from('mesas')
        .stream(primaryKey: ['id'])
        .order('orden');
  }

  void _mostrarError(String mensaje) {
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const FormularioMesaDialog(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Mesa'),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _mesasStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          final mesas = snapshot.data ?? [];

          return ListView.builder(
            itemCount: mesas.length,
            itemBuilder: (context, index) {
              final m = mesas[index];
              return MesaListTile(
                mesa: m,
                onEdit: () => showDialog(
                  context: context,
                  builder: (_) => FormularioMesaDialog(mesa: m),
                ),
                onDelete: () async {
                  try {
                    await _supabase.from('mesas').delete().eq('id', m['id']);
                  } catch (e) {
                    _mostrarError('Error al eliminar mesa: $e');
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
