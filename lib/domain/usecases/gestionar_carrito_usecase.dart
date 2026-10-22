// lib/domain/usecases/gestionar_carrito_usecase.dart
import '../entities/pedido_detalle.dart';
import '../entities/producto.dart';
import 'calcular_precio_item_usecase.dart';

class GestionarCarritoUseCase {
  final CalcularPrecioItemUseCase _calcularPrecioUseCase;

  GestionarCarritoUseCase(this._calcularPrecioUseCase);

  List<PedidoDetalle> agregarItem({
    required List<PedidoDetalle> carritoActual,
    required Producto producto1,
    Producto? producto2,
    required int cantidad,
    required String talla,
    String? nota,
    double precioExtra = 0.0,
  }) {
    // 1. Calcular precio unitario con la regla de negocio + precio extra
    final precioUnitario = _calcularPrecioUseCase.execute(
      producto1: producto1,
      producto2: producto2,
      talla: talla,
    ) + precioExtra;

    final List<PedidoDetalle> nuevoCarrito = List.from(carritoActual);

    final String? notaNormalizada =
        (nota != null && nota.trim().isNotEmpty) ? nota.trim() : null;

    // 2. Buscar si el producto ya existe en el carrito (solo agrupa si nota y precioExtra coinciden)
    final indexExistente = nuevoCarrito.indexWhere((item) =>
        item.productoId == producto1.id &&
        item.producto2Id == producto2?.id &&
        item.talla == talla &&
        (item.nota?.trim().toLowerCase() ?? '') ==
            (notaNormalizada?.toLowerCase() ?? '') &&
        item.precioExtra == precioExtra);

    if (indexExistente != -1) {
      // Si existe, reemplazamos la línea incrementando la cantidad
      final itemPrevio = nuevoCarrito[indexExistente];
      nuevoCarrito[indexExistente] = PedidoDetalle(
        id: itemPrevio.id,
        pedidoId: itemPrevio.pedidoId,
        productoId: itemPrevio.productoId,
        producto2Id: itemPrevio.producto2Id,
        cantidad: itemPrevio.cantidad + cantidad,
        precioUnitario: itemPrevio.precioUnitario,
        talla: itemPrevio.talla,
        nota: itemPrevio.nota,
        precioExtra: itemPrevio.precioExtra,
      );
    } else {
      // Si es un producto nuevo en esta orden, lo añadimos normalmente
      nuevoCarrito.add(PedidoDetalle(
        productoId: producto1.id,
        producto2Id: producto2?.id,
        cantidad: cantidad,
        precioUnitario: precioUnitario,
        talla: talla,
        nota: notaNormalizada,
        precioExtra: precioExtra,
      ));
    }

    return nuevoCarrito;
  }

  List<PedidoDetalle> removerItem(
    List<PedidoDetalle> carritoActual,
    int index,
  ) {
    return List.from(carritoActual)..removeAt(index);
  }

  double calcularTotal(List<PedidoDetalle> carrito) {
    return carrito.fold(
      0,
      (total, item) => total + (item.precioUnitario * item.cantidad),
    );
  }
}
