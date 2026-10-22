// lib/presentation/admin/widgets/formulario_producto_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/menu_provider.dart';
import 'campos_bebida_widget.dart';
import 'campos_extra_widget.dart';
import 'campos_pizza_widget.dart';

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
  late final TextEditingController precioMCtrl;
  late final TextEditingController volumenCtrl;

  bool _isLoading = false;
  final List<String> categoriasValidas = ['Pizzas', 'Bebidas', 'Extras'];

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    nombreCtrl = TextEditingController(text: p?['nombre'] ?? '');
    String catInicial = p?['categoria'] ?? 'Pizzas';
    if (!categoriasValidas.contains(catInicial)) catInicial = 'Pizzas';
    categoriaCtrl = TextEditingController(text: catInicial);
    precioGCtrl = TextEditingController(text: p?['precio_g']?.toString() ?? '');
    precioFCtrl = TextEditingController(text: p?['precio_f']?.toString() ?? '');
    precioUnicoCtrl = TextEditingController(text: p?['precio']?.toString() ?? '');
    precioMCtrl = TextEditingController(text: p?['precio_m']?.toString() ?? '');
    volumenCtrl = TextEditingController(text: p?['volumen'] ?? '');
  }

  @override
  void dispose() {
    for (final c in [nombreCtrl, categoriaCtrl, precioGCtrl, precioFCtrl, precioUnicoCtrl, precioMCtrl, volumenCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _parseNum(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  Future<void> _guardar() async {
    setState(() => _isLoading = true);
    final esEdicion = widget.producto != null;
    final datos = {
      'nombre': nombreCtrl.text.trim(),
      'categoria': categoriaCtrl.text,
      'precio_g': _parseNum(precioGCtrl),
      'precio_f': _parseNum(precioFCtrl),
      'precio': _parseNum(precioUnicoCtrl),
      'precio_m': _parseNum(precioMCtrl),
      'volumen': volumenCtrl.text.trim().isNotEmpty ? volumenCtrl.text.trim() : null,
      'disponible': esEdicion ? widget.producto!['disponible'] : true,
    };

    final error = await context.read<MenuProvider>().guardarProducto(
      id: esEdicion ? widget.producto!['id'] as int : null,
      datos: datos,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);
    if (error == null) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildCamposDinamicos() {
    final cat = categoriaCtrl.text.toLowerCase().trim();
    if (cat == 'pizzas') {
      return CamposPizzaWidget(precioMCtrl: precioMCtrl, precioGCtrl: precioGCtrl, precioFCtrl: precioFCtrl);
    } else if (cat == 'bebidas') {
      return CamposBebidaWidget(volumenCtrl: volumenCtrl, precioUnicoCtrl: precioUnicoCtrl);
    }
    return CamposExtraWidget(precioUnicoCtrl: precioUnicoCtrl);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.producto != null ? 'Editar Producto' : 'Nuevo Producto'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre del producto')),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: categoriaCtrl.text,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: categoriasValidas.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => val != null ? setState(() => categoriaCtrl.text = val) : null,
            ),
            _buildCamposDinamicos(),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _isLoading ? null : _guardar,
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
