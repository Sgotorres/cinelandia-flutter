import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Inyección de dependencias y utilidades
import '../../../core/di/injection.dart' as di;
import '../../../core/utils/result.dart';

// Repositorios y Providers
import '../../../data/repositories/pedidos_repository.dart';
import '../../../providers/menu_provider.dart';
import '../../../providers/pedidos_provider.dart'; // <-- ESTA ES LA IMPORTACIÓN QUE FALTABA

// Widgets
import 'boton_avanzar_estado.dart';
import 'comanda_bottom_bar.dart';
import 'comanda_item_tile.dart';

class ComandaDetallesModal extends StatefulWidget {
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
  State<ComandaDetallesModal> createState() => _ComandaDetallesModalState();
}

class _ComandaDetallesModalState extends State<ComandaDetallesModal> {
  late final Stream<List<Map<String, dynamic>>> _detallesStream;
  final _pedidosRepository = di.sl<PedidosRepository>(); // Usamos GetIt
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    // Lo pedimos al provider en lugar de a Supabase directamente
    _detallesStream = context.read<PedidosProvider>().detallesPedidoStream(
      widget.pedidoId,
    );
  }

  // --- LÓGICA DE ELIMINACIÓN ---
  Future<void> _eliminarProducto(int detalleId, int totalItems) async {
    if (_isDeleting) return;
    setState(() => _isDeleting = true);

    if (totalItems == 1 && mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    final result = await _pedidosRepository.eliminarDetalleYActualizarPedido(
      detalleId,
      widget.pedidoId,
    );

    if (mounted) {
      if (result is Error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((result as Error).failure.message),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isDeleting = false);
    }
  }

  // --- COMPONENTES VISUALES ---
  Widget _buildHeader() {
    return Column(
      children: [
        // Drag Handle
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            height: 5,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mesa ${widget.mesaId}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.black12),
      ],
    );
  }

  Widget _buildListadoProductos(MenuProvider menuProvider) {
    return Expanded(
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _detallesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final detalles = snapshot.data ?? [];
          if (detalles.isEmpty) return const SizedBox.shrink();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: detalles.length,
            itemBuilder: (context, index) {
              final item = detalles[index];
              final int cantidad = item['cantidad'] ?? 1;
              final double subtotal =
                  cantidad * (item['precio_unitario'] as num).toDouble();
              final String talla = item['talla'] ?? 'Única';

              String nombreP1 = 'Producto ${item['producto_id']}';
              try {
                nombreP1 = menuProvider.productos
                    .firstWhere((p) => p.id == item['producto_id'])
                    .nombre;
              } catch (_) {}

              String? nombreP2;
              if (item['producto_2_id'] != null) {
                try {
                  nombreP2 = menuProvider.productos
                      .firstWhere((p) => p.id == item['producto_2_id'])
                      .nombre;
                } catch (_) {}
              }

              final nombreAMostrar = nombreP2 != null
                  ? '1/2 $nombreP1 y 1/2 $nombreP2'
                  : nombreP1;

              return ComandaItemTile(
                nombre: nombreAMostrar,
                cantidad: cantidad,
                talla: talla,
                subtotal: subtotal,
                isDeleting: _isDeleting,
                onEliminar: () =>
                    _eliminarProducto(item['id'], detalles.length),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.read<MenuProvider>();

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            _buildHeader(),
            _buildListadoProductos(menuProvider),
            BotonAvanzarEstado(pedidoId: widget.pedidoId),
            ComandaBottomBar(
              mesaId: widget.mesaId,
              mesaNombre: widget.mesaNombre,
              pedidoId: widget.pedidoId,
            ),
          ],
        ),
      ),
    );
  }
}
