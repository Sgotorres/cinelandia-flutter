// lib/presentation/admin/widgets/formulario_producto_dialog.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormularioProductoDialog extends StatefulWidget {
  final Map<String, dynamic>? producto;
  const FormularioProductoDialog({super.key, this.producto});

  @override
  State<FormularioProductoDialog> createState() =>
      _FormularioProductoDialogState();
}

class _FormularioProductoDialogState extends State<FormularioProductoDialog> {
  late final TextEditingController nombreCtrl;
  late final TextEditingController categoriaCtrl;
  late final TextEditingController precioGCtrl;
  late final TextEditingController precioFCtrl;
  late final TextEditingController precioUnicoCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    nombreCtrl = TextEditingController(text: p?['nombre'] ?? '');
    categoriaCtrl = TextEditingController(text: p?['categoria'] ?? 'Pizzas');
    precioGCtrl = TextEditingController(text: p?['precio_g']?.toString() ?? '');
    precioFCtrl = TextEditingController(text: p?['precio_f']?.toString() ?? '');
    precioUnicoCtrl = TextEditingController(
      text: p?['precio']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    categoriaCtrl.dispose();
    precioGCtrl.dispose();
    precioFCtrl.dispose();
    precioUnicoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _isLoading = true);
    final esEdicion = widget.producto != null;
    final datos = {
      'nombre': nombreCtrl.text,
      'categoria': categoriaCtrl.text,
      'precio_g': precioGCtrl.text.isNotEmpty
          ? double.parse(precioGCtrl.text)
          : null,
      'precio_f': precioFCtrl.text.isNotEmpty
          ? double.parse(precioFCtrl.text)
          : null,
      'precio': precioUnicoCtrl.text.isNotEmpty
          ? double.parse(precioUnicoCtrl.text)
          : null,
      'disponible': esEdicion ? widget.producto!['disponible'] : true,
    };

    try {
      if (esEdicion) {
        await Supabase.instance.client
            .from('productos')
            .update(datos)
            .eq('id', widget.producto!['id']);
      } else {
        await Supabase.instance.client.from('productos').insert(datos);
      }
      if (mounted) Navigator.pop(context);
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
      title: Text(
        widget.producto != null ? 'Editar Producto' : 'Nuevo Producto',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto',
              ),
            ),
            TextField(
              controller: categoriaCtrl,
              decoration: const InputDecoration(
                labelText: 'Categoría (Ej: Pizzas, Bebidas)',
              ),
            ),
            const Divider(height: 30),
            const Text(
              'Precios para Pizzas:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: precioGCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio Grande (precio_g)',
              ),
            ),
            TextField(
              controller: precioFCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio Familiar (precio_f)',
              ),
            ),
            const Divider(height: 30),
            const Text(
              'Precio para Otros (Bebidas/Extras):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: precioUnicoCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Precio Único'),
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
