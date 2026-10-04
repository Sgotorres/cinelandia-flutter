// lib/presentation/admin/widgets/admin_usuarios_tab.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'formulario_usuario_dialog.dart';

class AdminUsuariosTab extends StatefulWidget {
  const AdminUsuariosTab({super.key});

  @override
  State<AdminUsuariosTab> createState() => _AdminUsuariosTabState();
}

class _AdminUsuariosTabState extends State<AdminUsuariosTab> {
  final _supabase = Supabase.instance.client;
  late final Stream<List<Map<String, dynamic>>> _usuariosStream;

  @override
  void initState() {
    super.initState();
    // Escuchamos la tabla de usuarios
    _usuariosStream = _supabase
        .from('usuarios')
        .stream(primaryKey: ['id'])
        .order('nombre');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const FormularioUsuarioDialog(),
        ),
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo Usuario'),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _usuariosStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final usuarios = snapshot.data ?? [];
          
          if (usuarios.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados.'));
          }

          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final user = usuarios[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo.shade100,
                  child: Text(
                    user['nombre'] != null ? user['nombre'][0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text('${user['nombre'] ?? ''} ${user['apellido'] ?? ''}', 
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${user['correo'] ?? ''} • ${user['rol'] ?? 'mesero'}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    // Nota: Esto borra el perfil. Para borrarlo de Auth se requiere una Edge Function.
                    await _supabase.from('usuarios').delete().eq('id', user['id']);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}