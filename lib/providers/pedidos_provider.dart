// lib/providers/pedidos_provider.dart
import 'package:flutter/material.dart';
import '../data/models/pedido_model.dart'; // Importamos el modelo de pedido principal
import '../data/models/pedido_detalle_model.dart'; // Importamos el modelo de los detalles
import '../data/models/producto_model.dart';
import '../data/repositories/pedidos_repository.dart'; // Conexión directa al repositorio

class PedidosProvider extends ChangeNotifier {
  final PedidosRepository _pedidosRepository = PedidosRepository();

  String _mesaSeleccionada = '';
  List<PedidoDetalleModel> _carrito = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters para que la interfaz (UI) pueda leer los datos
  String get mesaSeleccionada => _mesaSeleccionada;
  List<PedidoDetalleModel> get carrito => _carrito;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Calcula el total dinámicamente sumando cantidad * precioUnitario de cada ítem en el carrito
  double get totalPedido {
    return _carrito.fold(0, (total, item) => total + (item.precioUnitario * item.cantidad));
  }

  // 1. Asigna la mesa elegida por el mesero
  void seleccionarMesa(String mesa) {
    _mesaSeleccionada = mesa;
    notifyListeners();
  }

  // 2. Agrega un producto al carrito (Maneja pizzas enteras o Mitad/Mitad)
  void agregarAlCarrito({
    required ProductoModel producto1,
    ProductoModel? producto2, // Opcional, solo llega si es una pizza combinada
    required int cantidad,
    required String talla, // Ej: 'Grande' o 'Familiar'
  }) {
    double precioUnitario = 0;
    
    // Extraemos el precio de la primera pizza según la talla elegida
    double precioP1 = (talla == 'Familiar') ? (producto1.precioF ?? 0) : (producto1.precioG ?? 0);
    
    if (producto2 != null) {
      // Si es MITAD Y MITAD: extraemos el precio de la segunda pizza
      double precioP2 = (talla == 'Familiar') ? (producto2.precioF ?? 0) : (producto2.precioG ?? 0);
      
      // Regla de negocio de la pizzería: Se cobra el precio de la mitad más cara
      precioUnitario = precioP1 > precioP2 ? precioP1 : precioP2;
    } else {
      // Si es una pizza normal o una bebida (las bebidas usan el campo 'precio' base)
      precioUnitario = precioP1 > 0 ? precioP1 : (producto1.precio ?? 0);
    }

    final detalle = PedidoDetalleModel(
      productoId: producto1.id,
      producto2Id: producto2?.id,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
      talla: talla,
    );

    _carrito.add(detalle);
    notifyListeners(); // Avisa a la pantalla para que actualice la lista
  }

  // 3. Elimina un ítem si el mesero se equivoca
  void removerDelCarrito(int index) {
    _carrito.removeAt(index);
    notifyListeners();
  }

  // 4. Limpia todo el carrito
  void limpiarCarrito() {
    _carrito.clear();
    _mesaSeleccionada = '';
    notifyListeners();
  }

  // 5. Envía el pedido a la base de datos a través del repositorio
  Future<bool> enviarPedido() async {
    if (_mesaSeleccionada.isEmpty || _carrito.isEmpty) {
      _errorMessage = 'Faltan datos para enviar el pedido (mesa o productos)';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Usamos tu función crearPedido pasándole los datos exactos que requiere el repositorio
      await _pedidosRepository.crearPedido(
        _mesaSeleccionada,
        totalPedido,
        _carrito,
      );
      
      limpiarCarrito(); // Vaciamos el carrito tras el éxito
      return true;
    } catch (e) {
      _errorMessage = 'Error al enviar el pedido: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}