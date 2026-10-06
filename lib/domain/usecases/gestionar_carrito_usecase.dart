// lib/domain/usecases/gestionar_carrito_usecase.dart
import '../../data/models/pedido_detalle_model.dart';
import '../../data/models/producto_model.dart';
import '../entities/producto.dart'; 
import 'calcular_precio_item_usecase.dart';

class GestionarCarritoUseCase {
  final CalcularPrecioItemUseCase _calcularPrecioUseCase;

  GestionarCarritoUseCase(this._calcularPrecioUseCase);

  List<PedidoDetalleModel> agregarItem({
    required List<PedidoDetalleModel> carritoActual,
    required ProductoModel producto1,
    ProductoModel? producto2,
    required int cantidad,
    required String talla,
  }) {
    // 1. Mapear producto1 a la entidad
    final entidadP1 = Producto(
      id: producto1.id,
      nombre: producto1.nombre,
      precio: producto1.precio,
      precioM: producto1.precioM,
      precioG: producto1.precioG,
      precioF: producto1.precioF,
      volumen: producto1.volumen,
      categoria: producto1.categoria,
    );

    // 2. Mapear producto2 si existe (Mitad y Mitad)
    Producto? entidadP2;
    if (producto2 != null) {
      entidadP2 = Producto(
        id: producto2.id,
        nombre: producto2.nombre,
        precio: producto2.precio,
        precioM: producto2.precioM, 
        precioG: producto2.precioG,
        precioF: producto2.precioF,
        volumen: producto2.volumen, 
        categoria: producto2.categoria,
      );
    }

    // 3. Calcular precio unitario con la regla de negocio
    final precioUnitario = _calcularPrecioUseCase.execute(
      producto1: entidadP1,
      producto2: entidadP2,
      talla: talla,
    );

    final List<PedidoDetalleModel> nuevoCarrito = List.from(carritoActual);

    // 4. Buscar si el producto ya existe en el carrito
    final indexExistente = nuevoCarrito.indexWhere((item) => 
      item.productoId == producto1.id && 
      item.producto2Id == producto2?.id && 
      item.talla == talla
    );

    if (indexExistente != -1) {
      // Si existe, reemplazamos la línea incrementando la cantidad
      final itemPrevio = nuevoCarrito[indexExistente];
      nuevoCarrito[indexExistente] = PedidoDetalleModel(
        id: itemPrevio.id,
        pedidoId: itemPrevio.pedidoId,
        productoId: itemPrevio.productoId,
        producto2Id: itemPrevio.producto2Id,
        cantidad: itemPrevio.cantidad + cantidad,
        precioUnitario: itemPrevio.precioUnitario,
        talla: itemPrevio.talla,
      );
    } else {
      // Si es un producto nuevo en esta orden, lo añadimos normalmente
      nuevoCarrito.add(PedidoDetalleModel(
        productoId: producto1.id,
        producto2Id: producto2?.id,
        cantidad: cantidad,
        precioUnitario: precioUnitario,
        talla: talla,
      ));
    }

    return nuevoCarrito;
  }
  
  List<PedidoDetalleModel> removerItem(List<PedidoDetalleModel> carritoActual, int index) {
    return List.from(carritoActual)..removeAt(index);
  }

  double calcularTotal(List<PedidoDetalleModel> carrito) {
    return carrito.fold(0, (total, item) => total + (item.precioUnitario * item.cantidad));
  }
}