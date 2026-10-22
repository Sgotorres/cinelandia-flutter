// lib/presentation/admin/widgets/admin_usuarios_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/usuario.dart';
import '../providers/usuarios_provider.dart';
import 'formulario_usuario_dialog.dart';
import 'usuario_list_tile.dart';

class AdminUsuariosTab extends StatelessWidget {
  const AdminUsuariosTab({super.key});

  @override
  Widget build(BuildContext context) {
    final esMovil = MediaQuery.of(context).size.width < 600;
    final usuariosProvider = context.read<UsuariosProvider>();

    void abrirFormularioNuevo() {
      showDialog(
        context: context,
        builder: (_) => const FormularioUsuarioDialog(),
      );
    }

    return Scaffold(
      floatingActionButton: esMovil
          ? FloatingActionButton(
              onPressed: abrirFormularioNuevo,
              backgroundColor: Colors.indigo,
              child: const Icon(Icons.person_add, color: Colors.white),
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
                    'Gestión de Usuarios',
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
                    icon: const Icon(Icons.person_add),
                    label: const Text(
                      'Nuevo Usuario',
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
            child: StreamBuilder<List<Usuario>>(
              stream: usuariosProvider.usuariosStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final usuarios = snapshot.data ?? [];
                if (usuarios.isEmpty) {
                  return const Center(
                    child: Text('No hay usuarios registrados.'),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.only(top: esMovil ? 16 : 0),
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    final user = usuarios[index];
                    return UsuarioListTile(
                      usuario: user,
                      onDelete: () async {
                        final error = await usuariosProvider.eliminarUsuario(
                          user.id,
                        );
                        if (error != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error),
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
