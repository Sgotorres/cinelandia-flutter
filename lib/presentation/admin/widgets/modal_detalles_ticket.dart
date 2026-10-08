import 'package:flutter/material.dart';

import 'lista_articulos_pedido.dart';

class ModalDetallesTicket extends StatelessWidget {
  final Map<String, dynamic> venta;
  final String nombreMesa;

  const ModalDetallesTicket({
    super.key,
    required this.venta,
    required this.nombreMesa,
  });

  @override
  Widget build(BuildContext context) {
    final total = (venta['total'] as num).toDouble();
    final pedidoId = venta['id'];

    // Lógica responsiva: Definir un ancho máximo según la pantalla
    final anchoPantalla = MediaQuery.of(context).size.width;
    final anchoModal = anchoPantalla > 600 ? 450.0 : anchoPantalla * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: anchoModal,
          // Evitamos que el modal ocupe toda la pantalla a lo alto
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Se ajusta al contenido
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CABECERA DEL MODAL ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombreMesa,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Ticket #$pedidoId',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),

              // --- LISTA DE PRODUCTOS VENDIDOS ---
              const Text(
                'Artículos vendidos:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              // Usamos Flexible y SingleChildScrollView para que se pueda hacer scroll
              // si la mesa pidió muchísimas cosas
              Flexible(
                child: SingleChildScrollView(
                  // ¡Reutilizamos tu widget existente que agrupa y muestra productos!
                  child: ListaArticulosPedido(pedidoId: pedidoId),
                ),
              ),

              const Divider(height: 32),

              // --- TOTAL ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Cobrado',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
