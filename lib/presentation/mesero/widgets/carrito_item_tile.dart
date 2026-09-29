// lib/presentation/mesero/widgets/carrito_item_tile.dart
import 'package:flutter/material.dart';
import '../../../data/models/pedido_detalle_model.dart';
import '../../../providers/menu_provider.dart';

class CarritoItemTile extends StatelessWidget {
  final PedidoDetalleModel item;
  final MenuProvider menuProvider;
  final VoidCallback onEliminar;

  const CarritoItemTile({
    super.key,
    required this.item,
    required this.menuProvider,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    // LÓGICA PARA NOMBRES REALES Y MITADES
    String nombreP1 = 'Producto ${item.productoId}';
    try {
      nombreP1 = menuProvider.productos.firstWhere((p) => p.id == item.productoId).nombre;
    } catch (_) {} 

    String? nombreP2;
    if (item.producto2Id != null) {
      try {
        nombreP2 = menuProvider.productos.firstWhere((p) => p.id == item.producto2Id).nombre;
      } catch (_) {}
    }

    // Construye el texto final (Ej: "1/2 Margarita y 1/2 Pepperoni")
    final nombreAMostrar = nombreP2 != null 
        ? '1/2 $nombreP1 y 1/2 $nombreP2'
        : nombreP1;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.orangeAccent,
        child: Text('${item.cantidad}x', style: const TextStyle(color: Colors.white)),
      ),
      title: Text(nombreAMostrar, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(item.talla != null && item.talla != 'Única' ? 'Tamaño: ${item.talla}' : 'Unidad'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\$${(item.precioUnitario * item.cantidad).toStringAsFixed(2)}', 
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onEliminar,
          ),
        ],
      ),
    );
  }
}