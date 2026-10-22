import 'package:flutter_test/flutter_test.dart';
import 'package:cinelandia/domain/entities/producto.dart';
import 'package:cinelandia/domain/entities/pedido_detalle.dart';
import 'package:cinelandia/domain/usecases/calcular_precio_item_usecase.dart';
import 'package:cinelandia/domain/usecases/gestionar_carrito_usecase.dart';

void main() {
  late CalcularPrecioItemUseCase calcularPrecioUseCase;
  late GestionarCarritoUseCase gestionarCarritoUseCase;

  setUp(() {
    calcularPrecioUseCase = CalcularPrecioItemUseCase();
    gestionarCarritoUseCase = GestionarCarritoUseCase(calcularPrecioUseCase);
  });

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

  group('GestionarCarritoUseCase - Gestión y Cálculos del Carrito', () {
    test('Debe agregar un producto nuevo a un carrito vacío', () {
      final carrito = gestionarCarritoUseCase.agregarItem(
        carritoActual: [],
        producto1: pizzaMargarita,
        cantidad: 2,
        talla: 'Mediana',
      );

      expect(carrito.length, 1);
      expect(carrito.first.productoId, 1);
      expect(carrito.first.cantidad, 2);
      expect(carrito.first.precioUnitario, 10.0);
      expect(carrito.first.talla, 'Mediana');
    });

    test('Debe agrupar e incrementar la cantidad si el mismo producto, talla, nota y extra ya existen', () {
      var carrito = <PedidoDetalle>[];

      carrito = gestionarCarritoUseCase.agregarItem(
        carritoActual: carrito,
        producto1: pizzaMargarita,
        cantidad: 1,
        talla: 'Grande',
        nota: 'Sin cebolla',
        precioExtra: 2.0,
      );

      carrito = gestionarCarritoUseCase.agregarItem(
        carritoActual: carrito,
        producto1: pizzaMargarita,
        cantidad: 2,
        talla: 'Grande',
        nota: '  sin cebolla ',
        precioExtra: 2.0,
      );

      expect(carrito.length, 1);
      expect(carrito.first.cantidad, 3);
      expect(carrito.first.precioUnitario, 17.0); // 15.0 (Grande) + 2.0 (extra)
    });

    test('No debe agrupar si el producto tiene diferente nota o precioExtra', () {
      var carrito = <PedidoDetalle>[];

      carrito = gestionarCarritoUseCase.agregarItem(
        carritoActual: carrito,
        producto1: pizzaMargarita,
        cantidad: 1,
        talla: 'Mediana',
        nota: 'Borde de queso',
        precioExtra: 3.0,
      );

      carrito = gestionarCarritoUseCase.agregarItem(
        carritoActual: carrito,
        producto1: pizzaMargarita,
        cantidad: 1,
        talla: 'Mediana',
      );

      expect(carrito.length, 2);
    });

    test('Debe calcular correctamente el precio en modo Mitad y Mitad más extra', () {
      final carrito = gestionarCarritoUseCase.agregarItem(
        carritoActual: [],
        producto1: pizzaMargarita,
        producto2: pizzaPepperoni,
        cantidad: 1,
        talla: 'Familiar',
        precioExtra: 1.5,
      );

      expect(carrito.length, 1);
      expect(carrito.first.productoId, 1);
      expect(carrito.first.producto2Id, 2);
      // Mayor entre Margarita (20.0) y Pepperoni (22.0) = 22.0 + 1.5 extra = 23.5
      expect(carrito.first.precioUnitario, 23.5);
    });

    test('Debe remover un ítem del carrito por su índice y calcular el total exacto', () {
      var carrito = <PedidoDetalle>[];

      carrito = gestionarCarritoUseCase.agregarItem(
        carritoActual: carrito,
        producto1: pizzaMargarita,
        cantidad: 2,
        talla: 'Mediana', // 2 * 10 = 20.0
      );

      carrito = gestionarCarritoUseCase.agregarItem(
        carritoActual: carrito,
        producto1: pizzaPepperoni,
        cantidad: 1,
        talla: 'Grande', // 1 * 17 = 17.0
      );

      expect(gestionarCarritoUseCase.calcularTotal(carrito), 37.0);

      carrito = gestionarCarritoUseCase.removerItem(carrito, 0);
      expect(carrito.length, 1);
      expect(gestionarCarritoUseCase.calcularTotal(carrito), 17.0);
    });
  });
}
