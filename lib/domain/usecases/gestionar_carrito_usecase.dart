import '../../data/models/pedido_detalle_model.dart';
import '../../data/models/producto_model.dart';
import '../entities/producto.dart'; // <-- IMPORTANTE: Añadir la importación de la entidad
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
    // 1. Convertir ProductoModel (Data) a Producto (Domain)
    final entidadP1 = Producto(
      id: producto1.id,
      nombre: producto1.nombre,
      precio: producto1.precio,
      precioG: producto1.precioG,
      precioF: producto1.precioF,
      categoria: producto1.categoria,
    );

    Producto? entidadP2;
    if (producto2 != null) {
      entidadP2 = Producto(
        id: producto2.id,
        nombre: producto2.nombre,
        precio: producto2.precio,
        precioG: producto2.precioG,
        precioF: producto2.precioF,
        categoria: producto2.categoria,
      );
    }

    // 2. Ejecutar el caso de uso de precios con las entidades correctas
    final precioUnitario = _calcularPrecioUseCase.execute(
      producto1: entidadP1,
      producto2: entidadP2,
      talla: talla,
    );

    final detalle = PedidoDetalleModel(
      productoId: producto1.id,
      producto2Id: producto2?.id,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
      talla: talla,
    );

    return List.from(carritoActual)..add(detalle);
  }

  List<PedidoDetalleModel> removerItem(List<PedidoDetalleModel> carritoActual, int index) {
    return List.from(carritoActual)..removeAt(index);
  }

  double calcularTotal(List<PedidoDetalleModel> carrito) {
    return carrito.fold(0, (total, item) => total + (item.precioUnitario * item.cantidad));
  }
}