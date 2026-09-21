// lib/providers/menu_provider.dart
import 'package:flutter/material.dart';
import '../data/models/producto_model.dart';
import '../data/repositories/menu_repository.dart';

class MenuProvider extends ChangeNotifier {
  final MenuRepository _menuRepository = MenuRepository();

  List<ProductoModel> _productos = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<ProductoModel> get productos => _productos;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Filtrar productos por categoría
  List<ProductoModel> productosPorCategoria(String categoria) {
    return _productos.where((p) => p.categoria.toLowerCase() == categoria.toLowerCase()).toList();
  }

  // Cargar los productos desde Supabase
  Future<void> cargarMenu() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _productos = await _menuRepository.obtenerMenu();
    } catch (e) {
      _errorMessage = 'Error al cargar el menú: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} // <- ESTA LLAVE DE CIERRE ERA LA QUE FALTABA PARA LA CLASE MenuProvider