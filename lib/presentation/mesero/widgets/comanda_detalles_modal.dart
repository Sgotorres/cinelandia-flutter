import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../../providers/menu_provider.dart';
import '../../../providers/pedidos_provider.dart';
import '../../../data/repositories/pedidos_repository.dart';
import '../screens/tomar_pedido_screen.dart';

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
  final _supabase = Supabase.instance.client;
  final _pedidosRepository = PedidosRepository(); 
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _detalles = [];

  @override
  void initState() {
    super.initState();
    _cargarDetalles();
  }

  Future<void> _cargarDetalles() async {
    try {
      final response = await _supabase
          .from('detalles_pedido')
          .select('*')
          .eq('pedido_id', widget.pedidoId);

      final items = List<Map<String, dynamic>>.from(response);

      if (items.isEmpty) {
        if (mounted) {
          setState(() => _isLoading = false);
          Future.microtask(() {
            if (mounted && Navigator.canPop(context)) Navigator.pop(context);
          });
        }
        return;
      }

      if (!mounted) return;
      setState(() {
        _detalles = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _eliminarProducto(int detalleId, int index) async {
    if (_isLoading) return;

    setState(() {
      _detalles.removeAt(index);
    });

    if (_detalles.isEmpty) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context); 
      }
    }

    try {
      await _pedidosRepository.eliminarDetalleYActualizarPedido(detalleId, widget.pedidoId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red),
        );
        await _cargarDetalles();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.read<MenuProvider>();

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox( 
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Detalles - ${widget.mesaNombre}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _detalles.isEmpty
                      ? const Center(child: Text('No hay productos.'))
                      : ListView.builder(
                          itemCount: _detalles.length,
                          itemBuilder: (context, index) {
                            final item = _detalles[index];
                            final int cantidad = item['cantidad'] ?? 1;
                            final double precioUnitario = (item['precio_unitario'] as num).toDouble();
                            final double subtotal = cantidad * precioUnitario;
                            final String talla = item['talla'] ?? 'Única';

                            String nombreP1 = 'Producto ${item['producto_id']}';
                            try {
                              nombreP1 = menuProvider.productos.firstWhere((p) => p.id == item['producto_id']).nombre;
                            } catch (_) {}

                            String? nombreP2;
                            if (item['producto_2_id'] != null) {
                              try {
                                nombreP2 = menuProvider.productos.firstWhere((p) => p.id == item['producto_2_id']).nombre;
                              } catch (_) {}
                            }

                            final nombreAMostrar = nombreP2 != null
                                ? '1/2 $nombreP1 y 1/2 $nombreP2'
                                : nombreP1;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange.shade100,
                                child: Text('${cantidad}x', style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(nombreAMostrar, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(talla != 'Única' && talla != 'null' ? 'Tamaño: $talla' : 'Unidad'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('\$${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _eliminarProducto(item['id'], index), 
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                  label: const Text('Añadir Productos', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    context.read<PedidosProvider>().seleccionarMesa(
                      widget.mesaId, 
                      widget.mesaNombre, 
                      pedidoId: widget.pedidoId
                    );
                    
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TomarPedidoScreen()),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}