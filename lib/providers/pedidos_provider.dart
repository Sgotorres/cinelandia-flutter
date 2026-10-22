// lib/providers/pedidos_provider.dart
import 'package:flutter/material.dart';
import '../core/errors/failures.dart';
import '../core/utils/result.dart';
import '../data/models/pedido_detalle_model.dart';
import '../data/models/producto_model.dart';
import '../data/repositories/pedidos_repository.dart';
import '../domain/usecases/gestionar_carrito_usecase.dart';
import '../domain/usecases/tomar_pedido_usecase.dart';

class PedidosProvider extends ChangeNotifier {
  final TomarPedidoUseCase _tomarPedidoUseCase;
  final GestionarCarritoUseCase _gestionarCarritoUseCase;
  final PedidosRepository _pedidosRepository;

  PedidosProvider(this._tomarPedidoUseCase, this._gestionarCarritoUseCase, this._pedidosRepository);

  int? _mesaIdSeleccionada;
  String _mesaNombreSeleccionada = '';
  int? _pedidoActivoId;
  List<PedidoDetalleModel> _carrito = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _modoMitadYMitad = false;
  ProductoModel? _primeraMitad;

  int? get mesaIdSeleccionada => _mesaIdSeleccionada;
  String get mesaNombreSeleccionada => _mesaNombreSeleccionada;
  int? get pedidoActivoId => _pedidoActivoId;
  List<PedidoDetalleModel> get carrito => _carrito;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get modoMitadYMitad => _modoMitadYMitad;
  ProductoModel? get primeraMitad => _primeraMitad;
  double get totalPedido => _gestionarCarritoUseCase.calcularTotal(_carrito);

  void toggleModoMitad(bool valor) {
    _modoMitadYMitad = valor;
    if (!valor) _primeraMitad = null;
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

  void seleccionarMesa(int mesaId, String mesaNombre, {int? pedidoId}) {
    if (_mesaIdSeleccionada != null && _mesaIdSeleccionada != mesaId) _carrito.clear();
    _mesaIdSeleccionada = mesaId;
    _mesaNombreSeleccionada = mesaNombre;
    _pedidoActivoId = pedidoId;
    notifyListeners();
  }

  void agregarAlCarrito({
    required ProductoModel producto1,
    ProductoModel? producto2,
    required int cantidad,
    required String talla,
    String? nota,
    double precioExtra = 0.0,
  }) {
    _carrito = _gestionarCarritoUseCase.agregarItem(
      carritoActual: _carrito,
      producto1: producto1,
      producto2: producto2,
      cantidad: cantidad,
      talla: talla,
      nota: nota,
      precioExtra: precioExtra,
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

  Future<bool> enviarPedido() async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await _tomarPedidoUseCase.execute(
      mesaId: _mesaIdSeleccionada,
      carrito: _carrito,
      total: totalPedido,
      pedidoActivoId: _pedidoActivoId,
    );
    _isLoading = false;

    if (result is Success) {
      limpiarCarrito();
      return true;
    } else if (result is Error<bool, Failure>) {
      _errorMessage = result.failure.message;
      if (result.failure is NetworkFailure) {
        limpiarCarrito();
        return true;
      }
      notifyListeners();
      return false;
    }
    notifyListeners();
    return false;
  }

  Stream<List<Map<String, dynamic>>> obtenerPedidosActivosStream() => _pedidosRepository.obtenerPedidosActivosStream();
  Stream<List<Map<String, dynamic>>> obtenerTodosLosPedidosStream() => _pedidosRepository.obtenerTodosLosPedidosStream();
  Stream<List<Map<String, dynamic>>> detallesPedidoStream(int pedidoId) => _pedidosRepository.obtenerDetallesPedidoStream(pedidoId);
  Stream<String> estadoPedidoStream(int pedidoId) => _pedidosRepository.obtenerEstadoPedidoStream(pedidoId);

  Future<String?> actualizarEstado(int pedidoId, String nuevoEstado) async {
    final res = await _pedidosRepository.actualizarEstadoPedido(pedidoId, nuevoEstado);
    return res is Error ? (res as Error).failure.message : null;
  }

  Future<String?> eliminarDetalle(int detalleId, int pedidoId) async {
    final res = await _pedidosRepository.eliminarDetalleYActualizarPedido(detalleId, pedidoId);
    return res is Error ? (res as Error).failure.message : null;
  }

  Future<void> sincronizarPedidosOffline() => _pedidosRepository.sincronizarPedidosOffline();
}
