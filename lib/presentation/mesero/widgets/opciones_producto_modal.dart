// lib/presentation/mesero/widgets/opciones_producto_modal.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/producto_model.dart';
import '../../../providers/pedidos_provider.dart';

class OpcionesProductoModal extends StatefulWidget {
  final ProductoModel producto;
  final ProductoModel? producto2; // NUEVO: Producto opcional para la segunda mitad

  const OpcionesProductoModal({
    super.key, 
    required this.producto, 
    this.producto2,
  });

  @override
  State<OpcionesProductoModal> createState() => _OpcionesProductoModalState();
}

class _OpcionesProductoModalState extends State<OpcionesProductoModal> {
  int cantidad = 1;
  String tallaSeleccionada = 'Grande'; // Por defecto

  @override
  Widget build(BuildContext context) {
    // Si no tiene precios de tamaño, es una bebida o extra
    final bool esPizza = widget.producto.categoria.toLowerCase() == 'pizzas';
    final bool esMitad = widget.producto2 != null; // Verifica si es mitad y mitad

    // Crea el string combinado si existen dos productos
    final String tituloProducto = esMitad 
        ? '1/2 ${widget.producto.nombre} y 1/2 ${widget.producto2!.nombre}'
        : widget.producto.nombre;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tituloProducto, // Título dinámico (Ej: 1/2 Margarita y 1/2 Jamón)
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          if (esPizza) ...[
            const Text('Tamaño:', style: TextStyle(fontSize: 18)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Grande'),
                    value: 'Grande',
                    groupValue: tallaSeleccionada,
                    onChanged: (val) => setState(() => tallaSeleccionada = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Familiar'),
                    value: 'Familiar',
                    groupValue: tallaSeleccionada,
                    onChanged: (val) => setState(() => tallaSeleccionada = val!),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),
          const Text('Cantidad:', style: TextStyle(fontSize: 18)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 32),
                onPressed: () {
                  if (cantidad > 1) setState(() => cantidad--);
                },
              ),
              Text('$cantidad', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 32),
                onPressed: () => setState(() => cantidad++),
              ),
            ],
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                // Agregar al carrito usando el Provider
                context.read<PedidosProvider>().agregarAlCarrito(
                  producto1: widget.producto,
                  producto2: widget.producto2, // Envía el segundo producto al Provider
                  cantidad: cantidad,
                  talla: esPizza ? tallaSeleccionada : 'Única',
                );
                
                Navigator.pop(context); // Cierra el modal
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$tituloProducto agregado al pedido'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: const Text('Añadir al Pedido', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}