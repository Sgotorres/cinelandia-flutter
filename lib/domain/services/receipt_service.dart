// lib/domain/services/receipt_service.dart
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../entities/recibo.dart';

/// Abstracción limpia para generación y emisión de recibos.
/// Permite intercambiar o combinar fácilmente la emisión digital (PDF + QR)
/// con impresoras térmicas físicas (ESC/POS por Bluetooth o Red LAN) en el futuro.
abstract class ReceiptService {
  Future<Result<ReciboGenerado, Failure>> generarRecibo(
    Recibo recibo, {
    Duration expiracion = const Duration(minutes: 45),
  });
}
