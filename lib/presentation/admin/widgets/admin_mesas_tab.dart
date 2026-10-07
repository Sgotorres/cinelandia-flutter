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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;
    final esMovil = ancho < 600;

    void abrirFormularioNuevo() {
      showDialog(
        context: context,
        builder: (_) => const FormularioMesaDialog(),
      );
    }

    return Scaffold(
      floatingActionButton: esMovil
          ? FloatingActionButton(
              onPressed: abrirFormularioNuevo,
              backgroundColor: Colors.indigo,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: Column(
        children: [
          if (!esMovil)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Gestión de Mesas',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: abrirFormularioNuevo,
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Nueva Mesa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _mesasStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final mesas = snapshot.data ?? [];
                return ListView.builder(
                  padding: EdgeInsets.only(top: esMovil ? 16 : 0),
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
                          await _supabase
                              .from('mesas')
                              .delete()
                              .eq('id', m['id']);
                        } catch (e) {
                          _mostrarError('Error al eliminar mesa: $e');
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
