import '../entities/producto.dart';

class CalcularPrecioItemUseCase {
  /// Ejecuta la regla de negocio: Si es mitad y mitad, se cobra la mitad más cara.
  double execute({
    required Producto producto1,
    Producto? producto2,
    required String talla,
  }) {
    double precioP1 = (talla == 'Familiar') ? (producto1.precioF ?? 0) : (producto1.precioG ?? 0);
    
    if (producto2 != null) {
      double precioP2 = (talla == 'Familiar') ? (producto2.precioF ?? 0) : (producto2.precioG ?? 0);
      return precioP1 > precioP2 ? precioP1 : precioP2;
    }
    
    return precioP1 > 0 ? precioP1 : (producto1.precio ?? 0);
  }
}