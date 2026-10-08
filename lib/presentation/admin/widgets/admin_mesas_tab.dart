import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/mesas_provider.dart';
import '../../../data/models/mesa_model.dart';
import 'formulario_mesa_dialog.dart';

// Eliminamos la importación de supabase_flutter

class AdminMesasTab extends StatelessWidget {
  const AdminMesasTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;
    final esMovil = ancho < 600;

    // Accedemos a nuestro Provider inyectado
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
            // Ahora escuchamos objetos MesaModel puros, no Map<String, dynamic>
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
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.indigoAccent,
                        child: Icon(Icons.chair_alt, color: Colors.white),
                      ),
                      title: Text(
                        m.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Orden de vista: ${m.orden}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => showDialog(
                              context: context,
                              // Tendrás que adaptar tu FormularioMesaDialog para que acepte un MesaModel o transformar esto a JSON temporalmente
                              builder: (_) =>
                                  FormularioMesaDialog(mesa: m.toJson()),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              // La UI solo llama al método del provider y muestra el resultado
                              final errorMsg = await mesasProvider.eliminarMesa(
                                m.id,
                              );
                              if (errorMsg != null && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMsg),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
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
