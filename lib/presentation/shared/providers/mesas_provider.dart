// lib/presentation/shared/providers/mesas_provider.dart
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../domain/entities/mesa.dart';
import '../../../data/repositories/mesas_repository.dart';
import '../../../core/utils/result.dart';

class MesasProvider extends ChangeNotifier {
  final MesasRepository _mesasRepository;

  // Variables de estado
  Map<int, String> _mesasCache = {};
  bool _isLoading = false;
  StreamSubscription<List<Mesa>>? _mesasSubscription;

  MesasProvider({required MesasRepository mesasRepository})
    : _mesasRepository = mesasRepository;

  Map<int, String> get mesasCache => _mesasCache;
  bool get isLoading => _isLoading;

  // Exponemos el stream limpio de entidades puras para la UI
  Stream<List<Mesa>> get mesasStream =>
      _mesasRepository.obtenerMesasStream();

  void cargarMesas() {
    if (_mesasSubscription != null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _mesasSubscription = _mesasRepository.obtenerMesasStream().listen(
        (mesas) {
          final cacheTemporal = <int, String>{};
          for (var mesa in mesas) {
            cacheTemporal[mesa.id] = mesa.nombre;
          }
          _mesasCache = cacheTemporal;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Error cargando mesas en tiempo real: $error');
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('Error configurando stream de mesas: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delegamos la eliminación al repositorio y devolvemos el error si existe
  Future<String?> eliminarMesa(int id) async {
    final result = await _mesasRepository.eliminarMesa(id);
    if (result is Error) {
      return (result as Error).failure.message;
    }
    return null; // Null significa éxito
  }

  @override
  void dispose() {
    _mesasSubscription?.cancel();
    super.dispose();
  }
}
