// lib/providers/mesas_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MesasProvider extends ChangeNotifier {
  Map<int, String> _mesasCache = {};
  bool _isLoading = false;

  Map<int, String> get mesasCache => _mesasCache;
  bool get isLoading => _isLoading;

  Future<void> cargarMesas() async {
    if (_mesasCache.isNotEmpty) return; // Evita descargas redundantes

    _isLoading = true;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.from('mesas').select('id, nombre');
      final cacheTemporal = <int, String>{};

      for (var mesa in response) {
        cacheTemporal[mesa['id'] as int] = mesa['nombre'] as String;
      }

      _mesasCache = cacheTemporal;
    } catch (e) {
      debugPrint('Error cargando mesas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}