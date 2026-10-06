// lib/presentation/admin/widgets/formulario_producto_dialog.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Importamos nuestros nuevos sub-widgets
import 'campos_pizza_widget.dart';
import 'campos_bebida_widget.dart';
import 'campos_extra_widget.dart';

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
    
    // Validación inicial de categoría
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
    nombreCtrl.dispose();
    categoriaCtrl.dispose();
    precioGCtrl.dispose();
    precioFCtrl.dispose();
    precioUnicoCtrl.dispose();
    precioMCtrl.dispose();
    volumenCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _isLoading = true);
    final esEdicion = widget.producto != null;
    
    final datos = {
      'nombre': nombreCtrl.text,
      'categoria': categoriaCtrl.text,
      'precio_g': precioGCtrl.text.isNotEmpty ? double.parse(precioGCtrl.text) : null,
      'precio_f': precioFCtrl.text.isNotEmpty ? double.parse(precioFCtrl.text) : null,
      'precio': precioUnicoCtrl.text.isNotEmpty ? double.parse(precioUnicoCtrl.text) : null,
      'precio_m': precioMCtrl.text.isNotEmpty ? double.parse(precioMCtrl.text) : null,
      'volumen': volumenCtrl.text.isNotEmpty ? volumenCtrl.text : null,
      'disponible': esEdicion ? widget.producto!['disponible'] : true,
    };

    try {
      if (esEdicion) {
        await Supabase.instance.client.from('productos').update(datos).eq('id', widget.producto!['id']);
      } else {
        await Supabase.instance.client.from('productos').insert(datos);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Lógica para decidir qué widget secundario mostrar
  Widget _buildCamposDinamicos() {
    final cat = categoriaCtrl.text.toLowerCase().trim();
    
    if (cat == 'pizzas') {
      return CamposPizzaWidget(
        precioMCtrl: precioMCtrl,
        precioGCtrl: precioGCtrl,
        precioFCtrl: precioFCtrl,
      );
    } else if (cat == 'bebidas') {
      return CamposBebidaWidget(
        volumenCtrl: volumenCtrl,
        precioUnicoCtrl: precioUnicoCtrl,
      );
    } else {
      return CamposExtraWidget(
        precioUnicoCtrl: precioUnicoCtrl,
      );
    }
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
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre del producto'),
            ),
            const SizedBox(height: 10),
            
            // Reemplazo del TextField por un DropdownButtonFormField
            DropdownButtonFormField<String>(
              value: categoriaCtrl.text,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: categoriasValidas.map((String cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    categoriaCtrl.text = newValue;
                  });
                }
              },
            ),
            
            // Aquí llamamos a nuestra función que devuelve el widget modular
            _buildCamposDinamicos(),
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
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Guardar'),
        ),
      ],
    );
  }
}