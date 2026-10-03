// lib/providers/menu_provider.dart
import 'dart:async'; // <-- IMPORTANTE: Necesario para StreamSubscription
import 'package:flutter/material.dart';
import '../core/utils/result.dart';
import '../data/models/producto_model.dart';
import '../data/repositories/menu_repository.dart';

class MenuProvider extends ChangeNotifier {
  final MenuRepository _menuRepository;
  
  // Guardamos la suscripción para poder cancelarla y evitar fugas de memoria
  StreamSubscription<List<ProductoModel>>? _menuSubscription;

  MenuProvider({MenuRepository? menuRepository}) 
      : _menuRepository = menuRepository ?? MenuRepository();

  List<ProductoModel> _productos = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<ProductoModel> get productos => _productos;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  List<ProductoModel> productosPorCategoria(String categoria) {
    return _productos.where((p) => p.categoria.toLowerCase() == categoria.toLowerCase()).toList();
  }

  // MÉTODO NUEVO QUE REEMPLAZA A cargarMenu()
  void escucharMenu() {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    // Nos suscribimos al Stream del repositorio
    _menuSubscription = _menuRepository.obtenerMenuStream().listen(
      (productosCargados) {
        _productos = productosCargados;
        _isLoading = false;
        _errorMessage = '';
        notifyListeners(); // Actualiza la UI de todos los meseros al instante
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Error de conexión en tiempo real: $error';
        notifyListeners();
      },
    );
  }

  // MÉTODO NUEVO PARA LIMPIAR LA MEMORIA
  @override
  void dispose() {
    _menuSubscription?.cancel();
    super.dispose();
  }
}