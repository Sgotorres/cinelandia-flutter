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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;
    final esMovil = ancho < 600;

    void abrirFormularioNuevo() {
      showDialog(
        context: context,
        builder: (_) => const FormularioProductoDialog(),
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
                    'Catálogo de Productos',
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
                      'Nuevo Producto',
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
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _productosStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final productos = snapshot.data ?? [];
                return ListView.builder(
                  padding: EdgeInsets.only(top: esMovil ? 16 : 0),
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
                          _mostrarError(
                            'Error al actualizar disponibilidad: $e',
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
