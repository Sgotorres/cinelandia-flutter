import '../../data/models/pedido_detalle_model.dart';
import '../../data/repositories/pedidos_repository.dart';

class TomarPedidoUseCase {
  final PedidosRepository repository;

  TomarPedidoUseCase(this.repository);

  Future<bool> execute({
    required int? mesaId,
    required List<PedidoDetalleModel> carrito,
    required double total,
    int? pedidoActivoId,
  }) async {
    // Lógica de negocio: Un pedido no puede ir a cocina sin mesa o sin productos
    if (mesaId == null || carrito.isEmpty) {
      throw Exception('Faltan datos para enviar el pedido: Mesa o productos faltantes.');
    }

    try {
      await repository.crearPedido(
        mesaId,
        total,
        carrito,
        pedidoIdExistente: pedidoActivoId,
      );
      return true;
    } catch (e) {
      throw Exception('Error al registrar la comanda: $e');
    }
  }
}