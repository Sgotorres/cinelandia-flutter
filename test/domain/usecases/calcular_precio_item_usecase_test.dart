import 'package:flutter_test/flutter_test.dart';

// Cambia "tu_proyecto" por el nombre real de tu proyecto en el pubspec.yaml si es necesario
// o usa importaciones relativas como lo hacemos aquí:
import '../../../lib/domain/entities/producto.dart';
import '../../../lib/domain/usecases/calcular_precio_item_usecase.dart';

void main() {
  late CalcularPrecioItemUseCase useCase;

  // setUp se ejecuta antes de cada test para preparar todo de forma limpia
  setUp(() {
    useCase = CalcularPrecioItemUseCase();
  });

  group('CalcularPrecioItemUseCase - Lógica de Precios', () {
    final pizzaMargarita = Producto(
      id: 1,
      nombre: 'Margarita',
      categoria: 'Pizzas',
      precioM: 10.0,
      precioG: 15.0,
      precioF: 20.0,
    );

    final pizzaPepperoni = Producto(
      id: 2,
      nombre: 'Pepperoni',
      categoria: 'Pizzas',
      precioM: 12.0,
      precioG: 17.0,
      precioF: 22.0,
    );

    test('Debe retornar el precio de la talla Mediana de un solo producto', () {
      final result = useCase.execute(
        producto1: pizzaMargarita,
        talla: 'Mediana',
      );
      expect(result, 10.0); // Esperamos que devuelva 10.0
    });

    test('Debe retornar el precio mayor en modo Mitad y Mitad', () {
      // En mitad y mitad de talla Familiar (Margarita 20.0 vs Pepperoni 22.0), el sistema debe cobrar la más cara (22.0)
      final result = useCase.execute(
        producto1: pizzaMargarita,
        producto2: pizzaPepperoni,
        talla: 'Familiar',
      );
      expect(result, 22.0); // Esperamos que devuelva 22.0
    });

    test('Debe usar el precio base si no tiene precios por talla (Ej. Extras/Bebidas)', () {
      final cocaCola = Producto(
        id: 3,
        nombre: 'Coca Cola',
        categoria: 'Bebidas',
        precio: 3.5,
      );

      final result = useCase.execute(producto1: cocaCola, talla: 'Única');
      expect(result, 3.5); // Esperamos que devuelva 3.5
    });
  });
}
