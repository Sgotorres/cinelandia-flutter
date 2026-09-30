import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cinelandia/data/repositories/pedidos_repository.dart';
import 'package:cinelandia/data/models/pedido_detalle_model.dart';

// Mocks base
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

// Subtipo exacto que espera supabase_flutter en insert()
class MockPostgrestTransformBuilder extends Mock 
    implements PostgrestTransformBuilder<List<Map<String, dynamic>>> {}

void main() {
  late PedidosRepository repository;
  late MockSupabaseClient mockSupabase;
  late MockSupabaseQueryBuilder mockQueryBuilderPedidos;
  late MockSupabaseQueryBuilder mockQueryBuilderDetalles;
  late MockPostgrestTransformBuilder mockTransformBuilder;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockQueryBuilderPedidos = MockSupabaseQueryBuilder();
    mockQueryBuilderDetalles = MockSupabaseQueryBuilder();
    mockTransformBuilder = MockPostgrestTransformBuilder();
    repository = PedidosRepository(supabaseClient: mockSupabase);

    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<Map<String, dynamic>>[]);
  });

  group('PedidosRepository Tests -', () {
    test('crearPedido inserta el pedido y sus detalles correctamente', () async {
      final detalles = [
        PedidoDetalleModel(productoId: 1, cantidad: 2, precioUnitario: 10.0),
      ];

      // 1. Mock tabla 'pedidos'
      when(() => mockSupabase.from('pedidos'))
          .thenAnswer((_) => mockQueryBuilderPedidos);

      when(() => (mockQueryBuilderPedidos.insert(any()) as dynamic))
          .thenAnswer((_) => mockTransformBuilder);

      when(() => (mockTransformBuilder.select('id') as dynamic))
          .thenAnswer((_) => mockTransformBuilder);

      when(() => (mockTransformBuilder.single() as dynamic))
          .thenAnswer((_) async => {'id': 99});

      // 2. Mock tabla 'detalles_pedido'
      when(() => mockSupabase.from('detalles_pedido'))
          .thenAnswer((_) => mockQueryBuilderDetalles);

      when(() => (mockQueryBuilderDetalles.insert(any()) as dynamic))
          .thenAnswer((_) async => []);

      // Ejecución
      final resultId = await repository.crearPedido(5, 20.0, detalles);

      // Verificaciones
      expect(resultId, 99);
      verify(() => mockSupabase.from('pedidos')).called(1);
      verify(() => mockSupabase.from('detalles_pedido')).called(1);
    });
  });
}