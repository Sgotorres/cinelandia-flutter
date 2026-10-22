// lib/presentation/mesero/widgets/opciones_producto_modal.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/producto.dart';
import '../providers/pedidos_provider.dart';
import 'selector_talla_cantidad.dart';

class OpcionesProductoModal extends StatefulWidget {
  final Producto producto;
  final Producto? producto2;

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
  final _notaCtrl = TextEditingController();
  final _precioExtraCtrl = TextEditingController();

  @override
  void dispose() {
    _notaCtrl.dispose();
    _precioExtraCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool esPizza = widget.producto.categoria.toLowerCase() == 'pizzas';
    final bool esMitad = widget.producto2 != null;
    final String tituloProducto = esMitad
        ? '1/2 ${widget.producto.nombre} y 1/2 ${widget.producto2!.nombre}'
        : widget.producto.nombre;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
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
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SelectorTallaCantidad(
                esPizza: esPizza,
                tallaSeleccionada: tallaSeleccionada,
                onTallaChanged: (val) =>
                    setState(() => tallaSeleccionada = val),
                cantidad: cantidad,
                onDecrementar: () {
                  if (cantidad > 1) setState(() => cantidad--);
                },
                onIncrementar: () => setState(() => cantidad++),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notaCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText:
                      'Nota especial (Ej. Adicional de tocineta en mitad)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.note_alt_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _precioExtraCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Monto a incrementar (\$)',
                  hintText: '0.00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
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
                    final double rawExtra =
                        double.tryParse(
                          _precioExtraCtrl.text.trim().replaceAll(',', '.'),
                        ) ??
                        0.0;
                    final double extra = rawExtra > 0 ? rawExtra : 0.0;
                    final String nota = _notaCtrl.text.trim();

                    context.read<PedidosProvider>().agregarAlCarrito(
                      producto1: widget.producto,
                      producto2: widget.producto2,
                      cantidad: cantidad,
                      talla: esPizza ? tallaSeleccionada : 'Única',
                      nota: nota.isNotEmpty ? nota : null,
                      precioExtra: extra,
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
        ),
      ),
    );
  }
}
