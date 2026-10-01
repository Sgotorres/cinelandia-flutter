// lib/presentation/admin/widgets/admin_productos_tab.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'formulario_producto_dialog.dart';
import 'producto_list_tile.dart';

class AdminProductosTab extends StatefulWidget {
  const AdminProductosTab({super.key});

  @override
  State<AdminProductosTab> createState() => _AdminProductosTabState();
}

class _AdminProductosTabState extends State<AdminProductosTab> {
  final _supabase = Supabase.instance.client;
  late final Stream<List<Map<String, dynamic>>> _productosStream;

  @override
  void initState() {
    super.initState();
    _productosStream = _supabase
        .from('productos')
        .stream(primaryKey: ['id'])
        .order('categoria');
  }

  void _mostrarError(String mensaje) {
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const FormularioProductoDialog(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Producto'),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _productosStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          final productos = snapshot.data ?? [];

          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final p = productos[index];
              return ProductoListTile(
                producto: p,
                onEdit: () => showDialog(
                  context: context,
                  builder: (_) => FormularioProductoDialog(producto: p),
                ),
                onDelete: () async {
                  try {
                    await _supabase
                        .from('productos')
                        .delete()
                        .eq('id', p['id']);
                  } catch (e) {
                    _mostrarError('Error al eliminar producto: $e');
                  }
                },
                onToggleDisponibilidad: (nuevoValor) async {
                  try {
                    await _supabase
                        .from('productos')
                        .update({'disponible': nuevoValor})
                        .eq('id', p['id']);
                  } catch (e) {
                    _mostrarError('Error al actualizar disponibilidad: $e');
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
