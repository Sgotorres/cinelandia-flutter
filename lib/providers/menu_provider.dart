// lib/providers/menu_provider.dart
import 'dart:async';

import 'package:flutter/material.dart';

import '../core/utils/result.dart';
import '../data/models/producto_model.dart';
import '../data/repositories/menu_repository.dart';

class MenuProvider extends ChangeNotifier {
  final MenuRepository _menuRepository;
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
    return _productos
        .where((p) => p.categoria.toLowerCase() == categoria.toLowerCase())
        .toList();
  }

  void escucharMenu() {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    _menuSubscription = _menuRepository.obtenerMenuStream().listen(
      (productosCargados) {
        _productos = productosCargados;
        _isLoading = false;
        _errorMessage = '';
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Error de conexión en tiempo real: $error';
        notifyListeners();
      },
    );
  }

  // --- NUEVAS ACCIONES DEL ADMINISTRADOR ---

  Future<String?> eliminarProducto(int id) async {
    final result = await _menuRepository.eliminarProducto(id);
    if (result is Error) {
      return (result as Error).failure.message;
    }
    return null; // Éxito
  }

  Future<String?> actualizarDisponibilidad(int id, bool disponible) async {
    final result = await _menuRepository.actualizarDisponibilidad(
      id,
      disponible,
    );
    if (result is Error) {
      return (result as Error).failure.message;
    }
    return null; // Éxito
  }

  @override
  void dispose() {
    _menuSubscription?.cancel();
    super.dispose();
  }
}
