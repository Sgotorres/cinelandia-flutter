// lib/presentation/mesero/screens/tomar_pedido_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/menu_provider.dart';
import '../../../providers/pedidos_provider.dart';
import '../widgets/categoria_chips.dart';
import '../widgets/producto_tile.dart';
import '../widgets/opciones_producto_modal.dart';
import '../widgets/orden_bottom_bar.dart';

class TomarPedidoScreen extends StatefulWidget {
  const TomarPedidoScreen({super.key});

  @override
  State<TomarPedidoScreen> createState() => _TomarPedidoScreenState();
}

class _TomarPedidoScreenState extends State<TomarPedidoScreen> {
  String categoriaActual = 'Pizzas'; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final menuProvider = context.read<MenuProvider>();
      if (menuProvider.productos.isEmpty) {
        menuProvider.cargarMenu();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    final pedidosProvider = context.watch<PedidosProvider>();
    
    // CAMBIO APLICADO AQUÍ: Se usa mesaNombreSeleccionada en lugar de mesaSeleccionada
    final mesa = pedidosProvider.mesaNombreSeleccionada; 
    
    final productosFiltrados = menuProvider.productosPorCategoria(categoriaActual);

    // Lógica responsiva para el catálogo de pizzas
    final screenWidth = MediaQuery.of(context).size.width;
    int columnasProductos = 2; // Teléfonos (por defecto)
    if (screenWidth >= 1200) {
      columnasProductos = 5; // Monitores grandes
    } else if (screenWidth >= 900) {
      columnasProductos = 4; // Laptops o tablets en horizontal
    } else if (screenWidth >= 600) {
      columnasProductos = 3; // Tablets pequeñas
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mesa Seleccionada', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text(mesa, style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoriaChips(
            categorias: const ['Pizzas', 'Bebidas', 'Extras'],
            categoriaSeleccionada: categoriaActual,
            onSelected: (cat) => setState(() => categoriaActual = cat),
          ),
          
          // BANNER MITAD Y MITAD - DISEÑO UI MEJORADO
          if (categoriaActual == 'Pizzas')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: pedidosProvider.modoMitadYMitad ? Colors.orange.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: pedidosProvider.modoMitadYMitad ? Colors.orange.shade300 : Colors.grey.shade200,
                    width: 1.5,
                  ),
                  boxShadow: [
                    if (pedidosProvider.modoMitadYMitad)
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    else
                      BoxShadow( // Sombra sutil cuando está apagado
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      )
                  ],
                ),
                child: Row(
                  children: [
                    // Icono circular decorativo
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: pedidosProvider.modoMitadYMitad ? Colors.orange.shade100 : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.pie_chart_outline, // Representa la mitad de una pizza
                        color: pedidosProvider.modoMitadYMitad ? Colors.orange.shade700 : Colors.grey.shade500,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Textos descriptivos y dinámicos
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modo Mitad y Mitad',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: pedidosProvider.modoMitadYMitad ? Colors.orange.shade900 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pedidosProvider.modoMitadYMitad 
                              ? (pedidosProvider.primeraMitad == null 
                                  ? 'Toca la 1ra mitad...' 
                                  : '1/2 ${pedidosProvider.primeraMitad!.nombre}. Toca la 2da...')
                              : 'Combina dos pizzas en una',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: pedidosProvider.modoMitadYMitad && pedidosProvider.primeraMitad != null 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                              color: pedidosProvider.modoMitadYMitad 
                                  ? (pedidosProvider.primeraMitad == null ? Colors.orange.shade700 : Colors.indigo) 
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Switch adaptativo para iOS y Android
                    Switch.adaptive(
                      value: pedidosProvider.modoMitadYMitad,
                      activeColor: Colors.white,
                      activeTrackColor: Colors.orange,
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: Colors.grey.shade200,
                      onChanged: (val) => pedidosProvider.toggleModoMitad(val),
                    ),
                  ],
                ),
              ),
            ),

          Expanded(
            child: menuProvider.isLoading 
                ? const Center(child: CircularProgressIndicator())
                : productosFiltrados.isEmpty 
                    ? const Center(child: Text('No hay productos en esta categoría'))
                    : GridView.builder(
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
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const OrdenBottomBar(),
    );
  }
}