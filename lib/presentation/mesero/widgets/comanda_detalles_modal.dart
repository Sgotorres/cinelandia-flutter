// lib/presentation/mesero/widgets/comanda_detalles_modal.dart
import 'package:flutter/material.dart';

// Componentes modulares
import 'comanda_modal_header.dart';
import 'comanda_lista_productos.dart';
import 'boton_avanzar_estado.dart';
import 'comanda_bottom_bar.dart';

class ComandaDetallesModal extends StatelessWidget {
  final int pedidoId;
  final int mesaId;
  final String mesaNombre;

  const ComandaDetallesModal({
    super.key,
    required this.pedidoId,
    required this.mesaId,
    required this.mesaNombre,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            // 1. Encabezado
            ComandaModalHeader(mesaId: mesaId),
            
            // 2. Lista de productos (Maneja su propio estado interno)
            ComandaListaProductos(pedidoId: pedidoId),
            
            // 3. Botón para avanzar estado
            BotonAvanzarEstado(pedidoId: pedidoId),
            
            // 4. Barra inferior
            ComandaBottomBar(
              mesaId: mesaId,
              mesaNombre: mesaNombre,
              pedidoId: pedidoId,
            ),
          ],
        ),
      ),
    );
  }
}