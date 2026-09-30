import 'package:flutter_test/flutter_test.dart';
import 'package:cinelandia/domain/usecases/calcular_precio_item_usecase.dart';
import 'package:cinelandia/domain/entities/producto.dart';

void main() {
  late CalcularPrecioItemUseCase useCase;

  setUp(() {
    useCase = CalcularPrecioItemUseCase();
  });

  group('Lógica de Precios y Mitades -', () {
    final pizzaMargarita = Producto(id: 1, nombre: 'Margarita', categoria: 'Pizzas', precioG: 10.0, precioF: 15.0);
    final pizzaPepperoni = Producto(id: 2, nombre: 'Pepperoni', categoria: 'Pizzas', precioG: 12.0, precioF: 18.0);
    final refresco = Producto(id: 3, nombre: 'Refresco', categoria: 'Bebidas', precio: 3.0);

    test('Debe retornar el precio correcto para una pizza normal de un solo sabor', () {
      final precio = useCase.execute(producto1: pizzaMargarita, talla: 'Grande');
      expect(precio, 10.0); // 10.0 es el precioG de la Margarita
    });

    test('Debe cobrar SIEMPRE la mitad más cara en modo Mitad y Mitad', () {
      // Margarita(15.0) vs Pepperoni(18.0) en tamaño Familiar
      final precio = useCase.execute(
        producto1: pizzaMargarita, 
        producto2: pizzaPepperoni, 
        talla: 'Familiar'
      );
      
      // La regla de oro: el cliente paga el precio de la mitad más cara
      expect(precio, 18.0); 
    });

    test('Debe retornar el precio base normal para productos sin talla (Bebidas)', () {
      final precio = useCase.execute(producto1: refresco, talla: 'Única');
      expect(precio, 3.0);
    });
  });
}