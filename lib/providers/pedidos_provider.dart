// lib/providers/pedidos_provider.dart
import 'package:flutter/material.dart';
import '../data/models/pedido_detalle_model.dart';
import '../data/models/producto_model.dart';
import '../domain/usecases/gestionar_carrito_usecase.dart';
import '../domain/usecases/tomar_pedido_usecase.dart';

class PedidosProvider extends ChangeNotifier {
  final TomarPedidoUseCase _tomarPedidoUseCase;
  final GestionarCarritoUseCase _gestionarCarritoUseCase;

  PedidosProvider(this._tomarPedidoUseCase, this._gestionarCarritoUseCase);

  // Estado puro de UI
  int? _mesaIdSeleccionada;
  String _mesaNombreSeleccionada = '';
  int? _pedidoActivoId;
  
  List<PedidoDetalleModel> _carrito = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  int? get mesaIdSeleccionada => _mesaIdSeleccionada;
  String get mesaNombreSeleccionada => _mesaNombreSeleccionada;
  int? get pedidoActivoId => _pedidoActivoId;
  List<PedidoDetalleModel> get carrito => _carrito;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  
  double get totalPedido => _gestionarCarritoUseCase.calcularTotal(_carrito);

  // --- LÓGICA DE MITAD Y MITAD FALTANTE ---
  bool _modoMitadYMitad = false;
  ProductoModel? _primeraMitad;

  bool get modoMitadYMitad => _modoMitadYMitad;
  ProductoModel? get primeraMitad => _primeraMitad;

  void toggleModoMitad(bool valor) {
    _modoMitadYMitad = valor;
    if (!valor) {
      _primeraMitad = null; // Si se apaga el switch, limpiamos la selección
    }
    notifyListeners();
  }

  void seleccionarPrimeraMitad(ProductoModel producto) {
    _primeraMitad = producto;
    notifyListeners();
  }

  void limpiarMitadTemporal() {
    _primeraMitad = null;
    _modoMitadYMitad = false;
    notifyListeners();
  }

  // Selección de mesa
  void seleccionarMesa(int mesaId, String mesaNombre, {int? pedidoId}) {
    if (_mesaIdSeleccionada != null && _mesaIdSeleccionada != mesaId) {
      _carrito.clear();
    }
    _mesaIdSeleccionada = mesaId;
    _mesaNombreSeleccionada = mesaNombre;
    _pedidoActivoId = pedidoId;
    notifyListeners();
  }

  // Delegar operaciones del carrito al Caso de Uso
  void agregarAlCarrito({
    required ProductoModel producto1,
    ProductoModel? producto2,
    required int cantidad,
    required String talla,
  }) {
    _carrito = _gestionarCarritoUseCase.agregarItem(
      carritoActual: _carrito,
      producto1: producto1,
      producto2: producto2,
      cantidad: cantidad,
      talla: talla,
    );
    notifyListeners();
  }

  void removerDelCarrito(int index) {
    _carrito = _gestionarCarritoUseCase.removerItem(_carrito, index);
    notifyListeners();
  }

  void limpiarCarrito() {
    _carrito.clear();
    _mesaIdSeleccionada = null;
    _mesaNombreSeleccionada = '';
    _pedidoActivoId = null;
    notifyListeners();
  }

  // Enviar pedido delegando al UseCase
  Future<bool> enviarPedido() async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _tomarPedidoUseCase.execute(
        mesaId: _mesaIdSeleccionada,
        carrito: _carrito,
        total: totalPedido,
        pedidoActivoId: _pedidoActivoId,
      );
      limpiarCarrito();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}