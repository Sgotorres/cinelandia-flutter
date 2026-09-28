// lib/providers/pedidos_provider.dart
import 'package:flutter/material.dart';
import '../data/models/pedido_detalle_model.dart';
import '../data/models/producto_model.dart';
import '../data/repositories/pedidos_repository.dart';

class PedidosProvider extends ChangeNotifier {
  final PedidosRepository _pedidosRepository = PedidosRepository();

  // Guardamos el ID para la base de datos y el Nombre para mostrar en la interfaz
  int? _mesaIdSeleccionada;
  String _mesaNombreSeleccionada = ''; 
  
  List<PedidoDetalleModel> _carrito = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Variables para controlar el estado de "Mitad y Mitad"
  bool _modoMitadYMitad = false;
  ProductoModel? _primeraMitad;

  int? _pedidoActivoId;

  // Getters generales
  int? get mesaIdSeleccionada => _mesaIdSeleccionada;
  String get mesaNombreSeleccionada => _mesaNombreSeleccionada; 
  List<PedidoDetalleModel> get carrito => _carrito;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int? get pedidoActivoId => _pedidoActivoId;

  // Getters para Mitad y Mitad
  bool get modoMitadYMitad => _modoMitadYMitad;
  ProductoModel? get primeraMitad => _primeraMitad;

  // Calcula el total dinámicamente
  double get totalPedido {
    return _carrito.fold(0, (total, item) => total + (item.precioUnitario * item.cantidad));
  }

  // --- MÉTODOS PARA CONTROLAR MITAD Y MITAD ---
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

  // --- 1. SELECCIONAR MESA ---
  // Ahora recibe el ID numérico (int) para BD y el nombre (String) para la UI
  void seleccionarMesa(int mesaId, String mesaNombre, {int? pedidoId}) {
    if (_mesaIdSeleccionada != null && _mesaIdSeleccionada != mesaId) {
      _carrito.clear();
      _modoMitadYMitad = false;
      _primeraMitad = null;
    }
    _mesaIdSeleccionada = mesaId;
    _mesaNombreSeleccionada = mesaNombre;
    _pedidoActivoId = pedidoId; 
    notifyListeners();
  }

  // --- 2. AGREGAR AL CARRITO ---
  void agregarAlCarrito({
    required ProductoModel producto1,
    ProductoModel? producto2, 
    required int cantidad,
    required String talla,
  }) {
    double precioUnitario = 0;
    double precioP1 = (talla == 'Familiar') ? (producto1.precioF ?? 0) : (producto1.precioG ?? 0);
    
    if (producto2 != null) {
      double precioP2 = (talla == 'Familiar') ? (producto2.precioF ?? 0) : (producto2.precioG ?? 0);
      precioUnitario = precioP1 > precioP2 ? precioP1 : precioP2;
    } else {
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
    notifyListeners();
  }

  // --- 3. REMOVER DEL CARRITO ---
  void removerDelCarrito(int index) {
    _carrito.removeAt(index);
    notifyListeners();
  }

  // --- 4. LIMPIAR CARRITO COMPLETO ---
  void limpiarCarrito() {
    _carrito.clear();
    _mesaIdSeleccionada = null;
    _mesaNombreSeleccionada = '';
    _pedidoActivoId = null;
    
    _modoMitadYMitad = false;
    _primeraMitad = null;
    notifyListeners(); 
  }

  // --- 5. ENVIAR PEDIDO A BASE DE DATOS ---
  Future<bool> enviarPedido() async {
    if (_isLoading) return false;
    
    // Validamos que exista un ID de mesa seleccionado
    if (_mesaIdSeleccionada == null || _carrito.isEmpty) {
      _errorMessage = 'Faltan datos para enviar el pedido';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _pedidosRepository.crearPedido(
        _mesaIdSeleccionada!, // Enviamos el int a la base de datos
        totalPedido,
        _carrito,
        pedidoIdExistente: _pedidoActivoId,
      );

      limpiarCarrito();
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