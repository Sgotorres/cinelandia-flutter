// lib/domain/usecases/tomar_pedido_usecase.dart
import '../../data/models/pedido_detalle_model.dart';
import '../../data/repositories/pedidos_repository.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';

class TomarPedidoUseCase {
  final PedidosRepository repository;

  TomarPedidoUseCase(this.repository);

  Future<Result<bool, Failure>> execute({
    required int? mesaId,
    required List<PedidoDetalleModel> carrito,
    required double total,
    int? pedidoActivoId,
  }) async {
    if (mesaId == null || carrito.isEmpty) {
      return const Error(ServerFailure('Faltan datos: Mesa o productos faltantes.'));
    }

    final result = await repository.crearPedido(
      mesaId,
      total,
      carrito,
      pedidoIdExistente: pedidoActivoId,
    );

    // Evaluamos el tipo de retorno usando Pattern Matching
    if (result is Success<int, Failure>) {
      return const Success(true);
    } else if (result is Error<int, Failure>) {
      return Error(result.failure);
    }
    
    return const Error(ServerFailure('Error desconocido al procesar el pedido'));
  }
}