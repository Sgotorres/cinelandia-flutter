import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cinelandia/core/errors/failures.dart';
import 'package:cinelandia/core/utils/result.dart';
import 'package:cinelandia/data/repositories/pedidos_repository.dart';
import 'package:cinelandia/domain/entities/pedido_detalle.dart';
import 'package:cinelandia/domain/usecases/tomar_pedido_usecase.dart';

class MockPedidosRepository extends Mock implements PedidosRepository {}

void main() {
  late MockPedidosRepository mockRepository;
  late TomarPedidoUseCase useCase;

  setUp(() {
    mockRepository = MockPedidosRepository();
    useCase = TomarPedidoUseCase(mockRepository);
  });

  final carritoPrueba = [
    PedidoDetalle(
      productoId: 1,
      cantidad: 2,
      precioUnitario: 10.0,
      talla: 'Mediana',
    ),
  ];

  group('TomarPedidoUseCase - Validaciones y Envío de Pedidos', () {
    test('Debe retornar Error si mesaId es null', () async {
      final result = await useCase.execute(
        mesaId: null,
        carrito: carritoPrueba,
        total: 20.0,
      );

      expect(result, isA<Error<bool, Failure>>());
      final error = result as Error<bool, Failure>;
      expect(error.failure, isA<ServerFailure>());
      verifyZeroInteractions(mockRepository);
    });

    test('Debe retornar Error si el carrito está vacío', () async {
      final result = await useCase.execute(
        mesaId: 5,
        carrito: [],
        total: 0.0,
      );

      expect(result, isA<Error<bool, Failure>>());
      verifyZeroInteractions(mockRepository);
    });

    test('Debe retornar Success(true) cuando el repositorio crea el pedido exitosamente', () async {
      when(
        () => mockRepository.crearPedido(
          any(),
          any(),
          any(),
          pedidoIdExistente: any(named: 'pedidoIdExistente'),
        ),
      ).thenAnswer((_) async => const Success(101));

      final result = await useCase.execute(
        mesaId: 3,
        carrito: carritoPrueba,
        total: 20.0,
        pedidoActivoId: null,
      );

      expect(result, isA<Success<bool, Failure>>());
      expect((result as Success<bool, Failure>).value, isTrue);
      verify(
        () => mockRepository.crearPedido(
          3,
          20.0,
          carritoPrueba,
          pedidoIdExistente: null,
        ),
      ).called(1);
    });

    test('Debe propagar el Failure cuando el repositorio falla (ej. NetworkFailure o ServerFailure)', () async {
      when(
        () => mockRepository.crearPedido(
          any(),
          any(),
          any(),
          pedidoIdExistente: any(named: 'pedidoIdExistente'),
        ),
      ).thenAnswer(
        (_) async => const Error(
          NetworkFailure('Sin internet. La comanda se guardó localmente.'),
        ),
      );

      final result = await useCase.execute(
        mesaId: 3,
        carrito: carritoPrueba,
        total: 20.0,
      );

      expect(result, isA<Error<bool, Failure>>());
      final error = result as Error<bool, Failure>;
      expect(error.failure, isA<NetworkFailure>());
      expect(
        error.failure.message,
        'Sin internet. La comanda se guardó localmente.',
      );
    });
  });
}
