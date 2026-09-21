import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pedido_model.dart';
import '../models/pedido_detalle_model.dart';

class PedidosRepository {
  final _supabase = Supabase.instance.client;

  Future<int> crearPedido(String mesa, double total, List<PedidoDetalleModel> detalles) async {
    try {
      // 1. Insertar el pedido principal y obtener su ID
      final pedidoResponse = await _supabase.from('pedidos').insert({
        'mesa': mesa,
        'total': total,
        'estado': 'pendiente',
        'fecha': DateTime.now().toIso8601String(),
      }).select('id').single();

      final int pedidoId = pedidoResponse['id'];

      // 2. Si hay productos en la orden, asignarles el ID del pedido e insertarlos
      if (detalles.isNotEmpty) {
        final detallesAInsertar = detalles.map((detalle) {
          final json = detalle.toJson();
          json['pedido_id'] = pedidoId; 
          return json;
        }).toList();

        await _supabase.from('detalles_pedido').insert(detallesAInsertar);
      }

      return pedidoId;
    } catch (e) {
      print("Error al crear el pedido: $e");
      throw Exception('Fallo al registrar la orden en la base de datos');
    }
  }
}