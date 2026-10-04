// lib/presentation/admin/widgets/formulario_usuario_dialog.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FormularioUsuarioDialog extends StatefulWidget {
  const FormularioUsuarioDialog({super.key});

  @override
  State<FormularioUsuarioDialog> createState() => _FormularioUsuarioDialogState();
}

class _FormularioUsuarioDialogState extends State<FormularioUsuarioDialog> {
  final nombreCtrl = TextEditingController();
  final apellidoCtrl = TextEditingController();
  final correoCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    nombreCtrl.dispose();
    apellidoCtrl.dispose();
    correoCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarUsuario() async {
    if (nombreCtrl.text.isEmpty || correoCtrl.text.isEmpty || passwordCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Llena todos los campos (Mínimo 6 caracteres en contraseña)')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Instancia temporal para no cerrar la sesión del Administrador
      final tempClient = SupabaseClient(
        dotenv.env['SUPABASE_URL']!,
        dotenv.env['SUPABASE_ANON_KEY']!,
        authOptions: const AuthClientOptions(
          authFlowType: AuthFlowType.implicit, // <--- Esta línea soluciona el error
        ),
      );;

      // 2. Registrar en Supabase Auth
      await tempClient.auth.signUp(
        email: correoCtrl.text.trim(),
        password: passwordCtrl.text,
      );

      // 3. Guardar el perfil en tu tabla 'usuarios' usando el cliente principal
      await Supabase.instance.client.from('usuarios').insert({
        'nombre': nombreCtrl.text.trim(),
        'apellido': apellidoCtrl.text.trim(),
        'correo': correoCtrl.text.trim(),
        'rol': 'mesero', // Forzamos el rol para los nuevos usuarios
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario creado exitosamente'), backgroundColor: Colors.green),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de Auth: ${e.message}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear Nuevo Mesero'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: apellidoCtrl,
              decoration: const InputDecoration(labelText: 'Apellido'),
            ),
            TextField(
              controller: correoCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Correo electrónico'),
            ),
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña temporal (mín. 6 chars)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _guardarUsuario,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Crear Usuario', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}