// lib/presentation/mesero/widgets/opciones_producto_modal.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/producto_model.dart';
import '../../../providers/pedidos_provider.dart';
import 'selector_talla_cantidad.dart';

class OpcionesProductoModal extends StatefulWidget {
  final ProductoModel producto;
  final ProductoModel? producto2;

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
  String tallaSeleccionada = 'Mediana';

  @override
  Widget build(BuildContext context) {
    final bool esPizza = widget.producto.categoria.toLowerCase() == 'pizzas';
    final bool esMitad = widget.producto2 != null;
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
            tituloProducto,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SelectorTallaCantidad(
            esPizza: esPizza,
            tallaSeleccionada: tallaSeleccionada,
            onTallaChanged: (val) => setState(() => tallaSeleccionada = val),
            cantidad: cantidad,
            onDecrementar: () {
              if (cantidad > 1) setState(() => cantidad--);
            },
            onIncrementar: () => setState(() => cantidad++),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                context.read<PedidosProvider>().agregarAlCarrito(
                  producto1: widget.producto,
                  producto2: widget.producto2,
                  cantidad: cantidad,
                  talla: esPizza ? tallaSeleccionada : 'Única',
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$tituloProducto agregado al pedido'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: const Text(
                'Añadir al Pedido',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
