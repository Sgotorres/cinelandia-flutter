import '../entities/producto.dart';

class CalcularPrecioItemUseCase {
  double execute({
    required Producto producto1,
    Producto? producto2,
    required String talla,
  }) {
    // Función helper para no repetir lógica
    double obtenerPrecioPorTalla(Producto prod, String tallaT) {
      if (tallaT == 'Familiar') return prod.precioF ?? 0;
      if (tallaT == 'Grande') return prod.precioG ?? 0;
      return prod.precioM ?? 0; // Si es Mediana/Pequeña
    }

    double precioP1 = obtenerPrecioPorTalla(producto1, talla);
    
    if (producto2 != null) {
      double precioP2 = obtenerPrecioPorTalla(producto2, talla);
      return precioP1 > precioP2 ? precioP1 : precioP2;
    }
    
    return precioP1 > 0 ? precioP1 : (producto1.precio ?? 0);
  }
}