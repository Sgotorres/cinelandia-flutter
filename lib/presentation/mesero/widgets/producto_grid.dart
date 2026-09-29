import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/menu_provider.dart';
import '../../../providers/pedidos_provider.dart';
import 'producto_tile.dart';
import 'opciones_producto_modal.dart';

class ProductoGrid extends StatelessWidget {
  final String categoriaActual;

  const ProductoGrid({
    super.key,
    required this.categoriaActual,
  });

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    final pedidosProvider = context.watch<PedidosProvider>();
    final productosFiltrados = menuProvider.productosPorCategoria(categoriaActual);

    if (menuProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (productosFiltrados.isEmpty) {
      return const Center(child: Text('No hay productos en esta categoría'));
    }

    // Lógica responsiva
    final screenWidth = MediaQuery.of(context).size.width;
    int columnasProductos = 2; // Teléfonos (por defecto)
    if (screenWidth >= 1200) {
      columnasProductos = 5; // Monitores grandes
    } else if (screenWidth >= 900) {
      columnasProductos = 4; // Laptops o tablets en horizontal
    } else if (screenWidth >= 600) {
      columnasProductos = 3; // Tablets pequeñas
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnasProductos,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: productosFiltrados.length,
      itemBuilder: (context, index) {
        final producto = productosFiltrados[index];
        return ProductoTile(
          producto: producto,
          onTap: () {
            if (pedidosProvider.modoMitadYMitad && categoriaActual == 'Pizzas') {
              if (pedidosProvider.primeraMitad == null) {
                pedidosProvider.seleccionarPrimeraMitad(producto);
              } else {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => OpcionesProductoModal(
                    producto: pedidosProvider.primeraMitad!,
                    producto2: producto,
                  ),
                ).whenComplete(() => pedidosProvider.limpiarMitadTemporal());
              }
            } else {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => OpcionesProductoModal(producto: producto),
              );
            }
          },
        );
      },
    );
  }
}