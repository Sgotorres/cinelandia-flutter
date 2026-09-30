import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cinelandia/data/models/producto_model.dart';
import 'package:cinelandia/data/repositories/menu_repository.dart';
import 'package:cinelandia/providers/menu_provider.dart';
import 'package:cinelandia/core/utils/result.dart'; 
import 'package:cinelandia/core/errors/failures.dart'; 

// 1. Creamos el Mock del Repositorio usando Mocktail
class MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  late MenuProvider menuProvider;
  late MockMenuRepository mockMenuRepository;

  // El setUp se ejecuta antes de CADA test, dejándonos un entorno limpio
  setUp(() {
    mockMenuRepository = MockMenuRepository();
    // Inyectamos el mock al provider
    menuProvider = MenuProvider(menuRepository: mockMenuRepository);
  });

  group('MenuProvider Tests -', () {
    
    test('cargarMenu debe actualizar _productos cuando es exitoso', () async {
      // Preparación (Arrange)
      final productosMock = [
        ProductoModel(
          id: 1, 
          nombre: 'Pizza Margarita', 
          categoria: 'Pizzas', 
          esRecomendado: true, 
          disponible: true, 
          precio: 10
        ),
      ];
      
      // Le decimos al mock qué responder cuando llamen a obtenerMenu()
      when(() => mockMenuRepository.obtenerMenu())
          .thenAnswer((_) async => Success(productosMock));

      // Ejecución (Act)
      final future = menuProvider.cargarMenu();
      
      // Verificamos que el estado isLoading sea true justo después de llamar a la función
      expect(menuProvider.isLoading, true);
      
      await future;

      // Validación (Assert)
      expect(menuProvider.isLoading, false); // Ya debió terminar de cargar
      expect(menuProvider.productos.length, 1); // Debe tener 1 producto
      expect(menuProvider.productos.first.nombre, 'Pizza Margarita'); // Debe ser el mock
      expect(menuProvider.errorMessage, ''); // No debe haber errores
    });

    test('cargarMenu debe actualizar errorMessage cuando falla la DB', () async {
      // Preparación (Arrange)
      when(() => mockMenuRepository.obtenerMenu())
          .thenAnswer((_) async => const Error(ServerFailure('Error en base de datos')));

      // Ejecución (Act)
      await menuProvider.cargarMenu();

      // Validación (Assert)
      expect(menuProvider.isLoading, false);
      expect(menuProvider.productos, isEmpty); // La lista debe estar vacía
      expect(menuProvider.errorMessage, 'Error en base de datos'); // El mensaje debe coincidir
    });
    
  });
}