import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cinelandia/core/errors/failures.dart';
import 'package:cinelandia/core/utils/result.dart';
import 'package:cinelandia/domain/entities/recibo.dart';
import 'package:cinelandia/domain/services/receipt_service.dart';
import 'package:cinelandia/domain/usecases/generar_recibo_usecase.dart';

class MockReceiptService extends Mock implements ReceiptService {}

class FakeRecibo extends Fake implements Recibo {}

void main() {
  late MockReceiptService mockReceiptService;
  late GenerarReciboUseCase useCase;

  setUpAll(() {
    registerFallbackValue(FakeRecibo());
    registerFallbackValue(Duration.zero);
  });

  setUp(() {
    mockReceiptService = MockReceiptService();
    useCase = GenerarReciboUseCase(mockReceiptService);
  });

  group('GenerarReciboUseCase - Recibos Digitales y QR', () {
    test('Debe retornar Error si el recibo no tiene productos', () async {
      final reciboVacio = Recibo(
        pedidoId: 10,
        mesaNombre: 'Mesa 1',
        fecha: DateTime(2026, 10, 22),
        items: const [],
        total: 0.0,
      );

      final result = await useCase.execute(recibo: reciboVacio);

      expect(result, isA<Error<ReciboGenerado, Failure>>());
      verifyZeroInteractions(mockReceiptService);
    });

    test('Debe delegar la generación al ReceiptService cuando el recibo es válido', () async {
      final reciboValido = Recibo(
        pedidoId: 10,
        mesaNombre: 'Mesa 1',
        fecha: DateTime(2026, 10, 22),
        items: const [
          ReciboItem(
            nombre: 'Margarita',
            cantidad: 2,
            talla: 'Grande',
            precioUnitario: 15.0,
          ),
        ],
        total: 30.0,
      );

      final esperado = ReciboGenerado(
        recibo: reciboValido,
        qrPayload: 'https://supabase.co/storage/v1/object/sign/recibos/ticket_10.pdf?token=xyz',
        signedUrl: 'https://supabase.co/storage/v1/object/sign/recibos/ticket_10.pdf?token=xyz',
        expiraEn: DateTime(2026, 10, 22, 14, 0),
      );

      when(
        () => mockReceiptService.generarRecibo(
          any(),
          expiracion: any(named: 'expiracion'),
        ),
      ).thenAnswer((_) async => Success(esperado));

      final result = await useCase.execute(recibo: reciboValido);

      expect(result, isA<Success<ReciboGenerado, Failure>>());
      final success = result as Success<ReciboGenerado, Failure>;
      expect(success.value.qrPayload, esperado.qrPayload);
      expect(success.value.recibo.total, 30.0);
    });
  });
}
