// lib/presentation/admin/widgets/admin_productos_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/menu_provider.dart';
import 'formulario_producto_dialog.dart';
import 'producto_list_tile.dart';

// Fíjate que eliminamos la importación de supabase_flutter por completo

class AdminProductosTab extends StatelessWidget {
  const AdminProductosTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;
    final esMovil = ancho < 600;

    // Conectamos la vista con el provider
    final menuProvider = context.watch<MenuProvider>();

    void abrirFormularioNuevo() {
      showDialog(
        context: context,
        builder: (_) => const FormularioProductoDialog(),
      );
    }

    void mostrarError(String mensaje) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
        );
      }
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
            // Evaluamos el estado desde el provider
            child: menuProvider.isLoading && menuProvider.productos.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: EdgeInsets.only(top: esMovil ? 16 : 0),
                    itemCount: menuProvider.productos.length,
                    itemBuilder: (context, index) {
                      final p = menuProvider.productos[index];
                      return ProductoListTile(
                        producto: p.toJson(), // Pasamos a JSON temporalmente para que tu ProductoListTile actual funcione
                        onEdit: () => showDialog(
                          context: context,
                          builder: (_) =>
                              FormularioProductoDialog(producto: p.toJson()),
                        ),
                        onDelete: () async {
                          final error = await menuProvider.eliminarProducto(
                            p.id,
                          );
                          if (error != null) mostrarError(error);
                        },
                        onToggleDisponibilidad: (nuevoValor) async {
                          final error = await menuProvider
                              .actualizarDisponibilidad(p.id, nuevoValor);
                          if (error != null) mostrarError(error);
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
