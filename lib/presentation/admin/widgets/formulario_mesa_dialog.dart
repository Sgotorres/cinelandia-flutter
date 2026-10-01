// lib/presentation/admin/widgets/formulario_mesa_dialog.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormularioMesaDialog extends StatefulWidget {
  final Map<String, dynamic>? mesa;
  const FormularioMesaDialog({super.key, this.mesa});

  @override
  State<FormularioMesaDialog> createState() => _FormularioMesaDialogState();
}

class _FormularioMesaDialogState extends State<FormularioMesaDialog> {
  late final TextEditingController nombreCtrl;
  late final TextEditingController ordenCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    nombreCtrl = TextEditingController(text: widget.mesa?['nombre'] ?? '');
    ordenCtrl = TextEditingController(
      text: widget.mesa?['orden']?.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    ordenCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _isLoading = true);
    final esEdicion = widget.mesa != null;
    final datos = {
      'nombre': nombreCtrl.text,
      'orden': int.tryParse(ordenCtrl.text) ?? 0,
      'activa': esEdicion ? widget.mesa!['activa'] : true,
    };

    try {
      if (esEdicion) {
        await Supabase.instance.client
            .from('mesas')
            .update(datos)
            .eq('id', widget.mesa!['id']);
      } else {
        await Supabase.instance.client.from('mesas').insert(datos);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.mesa != null ? 'Editar Mesa' : 'Nueva Mesa'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nombreCtrl,
            decoration: const InputDecoration(
              labelText: 'Nombre (Ej: Mesa 1, Barra)',
            ),
          ),
          TextField(
            controller: ordenCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Orden de aparición (Número)',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _guardar,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
