import 'package:flutter/material.dart';
import '../core/utils/result.dart';
import '../data/models/producto_model.dart';
import '../data/repositories/menu_repository.dart';

class MenuProvider extends ChangeNotifier {
  final MenuRepository _menuRepository;
  
  // Inyección de dependencias: usamos el mock en tests, o el real en la app
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

  Future<void> cargarMenu() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await _menuRepository.obtenerMenu();

    switch (result) {
      case Success(value: final productosCargados):
        _productos = productosCargados;
        _errorMessage = '';
      case Error(failure: final fallo):
        _errorMessage = fallo.message;
    }
    _isLoading = false;
    notifyListeners();
  }
}