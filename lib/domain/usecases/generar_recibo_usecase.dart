// lib/domain/usecases/generar_recibo_usecase.dart
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../entities/recibo.dart';
import '../services/receipt_service.dart';

class GenerarReciboUseCase {
  final ReceiptService _receiptService;

  GenerarReciboUseCase(this._receiptService);

  Future<Result<ReciboGenerado, Failure>> execute({
    required Recibo recibo,
    Duration expiracion = const Duration(minutes: 45),
  }) async {
    if (recibo.items.isEmpty) {
      return const Error(
        ServerFailure('No se puede generar un recibo sin productos.'),
      );
    }
    return _receiptService.generarRecibo(recibo, expiracion: expiracion);
  }
}
