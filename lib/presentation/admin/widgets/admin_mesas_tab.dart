// lib/presentation/admin/widgets/admin_mesas_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/mesa_model.dart';
import '../../../providers/mesas_provider.dart';
import 'formulario_mesa_dialog.dart';
import 'mesa_list_tile.dart';

class AdminMesasTab extends StatelessWidget {
  const AdminMesasTab({super.key});

  @override
  Widget build(BuildContext context) {
    final esMovil = MediaQuery.of(context).size.width < 600;
    final mesasProvider = context.read<MesasProvider>();

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
            child: StreamBuilder<List<MesaModel>>(
              stream: mesasProvider.mesasStream,
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
                      mesa: m.toJson(),
                      onEdit: () => showDialog(
                        context: context,
                        builder: (_) => FormularioMesaDialog(mesa: m.toJson()),
                      ),
                      onDelete: () async {
                        final errorMsg = await mesasProvider.eliminarMesa(m.id);
                        if (errorMsg != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMsg),
                              backgroundColor: Colors.red,
                            ),
                          );
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
