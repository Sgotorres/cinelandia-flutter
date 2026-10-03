// lib/presentation/mesero/screens/tomar_pedido_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/menu_provider.dart';
import '../../../providers/pedidos_provider.dart';
import '../widgets/categoria_chips.dart';
import '../widgets/orden_bottom_bar.dart';
import '../widgets/mitad_y_mitad_banner.dart';
import '../widgets/producto_grid.dart';

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
        menuProvider.escucharMenu();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Se usa mesaNombreSeleccionada desde el provider
    final mesa = context.watch<PedidosProvider>().mesaNombreSeleccionada;

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
          
          if (categoriaActual == 'Pizzas')
            const MitadYMitadBanner(),

          Expanded(
            child: ProductoGrid(
              categoriaActual: categoriaActual,
            ),
          ),
        ],
      ),
      bottomNavigationBar: const OrdenBottomBar(),
    );
  }
}