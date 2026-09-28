// lib/presentation/mesero/screens/comandas_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../../providers/menu_provider.dart';
import '../../../providers/pedidos_provider.dart';
import '../../../data/repositories/pedidos_repository.dart'; 
import 'tomar_pedido_screen.dart';

class ComandasScreen extends StatefulWidget {
  const ComandasScreen({super.key});

  @override
  State<ComandasScreen> createState() => _ComandasScreenState();
}

class _ComandasScreenState extends State<ComandasScreen> {
  // Cambiamos el Stream para que traiga los datos relacionados
  late final Stream<List<Map<String, dynamic>>> _pedidosStream;

  @override
  void initState() {
    super.initState();
    // En Supabase, para traer datos relacionados en tiempo real con .stream(), 
    // a menudo es complicado. Pero si configuramos la vista correctamente o 
    // hacemos la recarga de los nombres, podemos hacerlo así.
    // La forma más segura de hacer un JOIN continuo en Flutter Supabase
    // cuando cambian los pedidos es usar un query normal en un Stream de eventos.
    
    // Escuchamos la tabla pedidos, y filtramos
    _pedidosStream = Supabase.instance.client
        .from('pedidos')
        .stream(primaryKey: ['id'])
        .neq('estado', 'pagado')
        .neq('estado', 'cancelada')
        .order('fecha', ascending: false);
  }

  // Función para obtener el nombre de la mesa basado en su ID
  Future<String> _obtenerNombreMesa(int mesaId) async {
    try {
      final response = await Supabase.instance.client
          .from('mesas')
          .select('nombre')
          .eq('id', mesaId)
          .single();
      return response['nombre'] as String;
    } catch (e) {
      return 'Mesa $mesaId'; // Fallback por si hay error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Comandas Activas', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _pedidosStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error de Supabase: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.indigo));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay comandas activas', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          final pedidos = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              final estado = pedido['estado'] ?? 'pendiente';
              
              // AHORA LEEMOS EL mesa_id, ya no 'mesa'
              final mesaId = pedido['mesa_id'] as int;
              
              final total = (pedido['total'] as num).toDouble();
              final pedidoId = pedido['id'];

              Color colorEstado = Colors.grey;
              if (estado == 'pendiente') colorEstado = Colors.orange;
              else if (estado == 'horno') colorEstado = Colors.blue;
              else if (estado == 'comiendo') colorEstado = Colors.purple;
              else if (estado == 'lista') colorEstado = Colors.greenAccent.shade700;

              return FutureBuilder<String>(
                future: _obtenerNombreMesa(mesaId), // Buscamos el nombre real
                builder: (context, mesaSnapshot) {
                  final nombreMesa = mesaSnapshot.data ?? 'Cargando...';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: colorEstado.withOpacity(0.2),
                        child: Icon(Icons.receipt_long, color: colorEstado),
                      ),
                      title: Text(nombreMesa, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('Total: \$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: colorEstado, borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          estado.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      onTap: () {
                        // Pasamos tanto el ID del pedido, el ID de la mesa y el Nombre de la mesa
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => _ComandaDetallesModal(
                            pedidoId: pedidoId,
                            mesaId: mesaId,
                            mesaNombre: nombreMesa,
                          ),
                        );
                      },
                    ),
                  );
                }
              );
            },
          );
        },
      ),
    );
  }
}

// --- MODAL DE DETALLES ---
class _ComandaDetallesModal extends StatefulWidget {
  final int pedidoId;
  final int mesaId; // Añadido
  final String mesaNombre; // Añadido

  const _ComandaDetallesModal({
    required this.pedidoId,
    required this.mesaId,
    required this.mesaNombre,
  });

  @override
  State<_ComandaDetallesModal> createState() => _ComandaDetallesModalState();
}

class _ComandaDetallesModalState extends State<_ComandaDetallesModal> {
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

  // LÓGICA OPTIMISTA: Modificamos la lista local y luego impactamos BD
  Future<void> _eliminarProducto(int detalleId, int index) async {
    if (_isLoading) return;

    // 1. ELIMINACIÓN INMEDIATA EN LA INTERFAZ (Tu idea)
    setState(() {
      _detalles.removeAt(index); // Lo borramos del objeto local al instante
    });

    // 2. Si la comanda se quedó sin nada (= 0), cerramos de golpe sin esperar a la BD
    if (_detalles.isEmpty) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context); 
      }
    }

    // 3. Ejecutamos la base de datos en segundo plano
    try {
      await _pedidosRepository.eliminarDetalleYActualizarPedido(detalleId, widget.pedidoId);
      // No necesitamos recargar porque la UI ya está actualizada y limpia
    } catch (e) {
      // Solo en caso de error de internet o BD, volvemos a descargar para arreglar la vista
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
      clipBehavior: Clip.antiAlias, // Para mantener los bordes redondeados
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
                    // AQUI PASAMOS EL ID NUMERICO Y EL NOMBRE AL PROVIDER 
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