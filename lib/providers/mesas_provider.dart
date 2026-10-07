// lib/providers/mesas_provider.dart
import 'dart:async'; // <-- Necesario para el StreamSubscription

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MesasProvider extends ChangeNotifier {
  Map<int, String> _mesasCache = {};
  bool _isLoading = false;

  // Guardamos la suscripción para evitar fugas de memoria
  StreamSubscription<List<Map<String, dynamic>>>? _mesasSubscription;

  Map<int, String> get mesasCache => _mesasCache;
  bool get isLoading => _isLoading;

  void cargarMesas() {
    // Si ya estamos escuchando la base de datos, no hacemos nada
    if (_mesasSubscription != null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Escuchamos la tabla 'mesas' en tiempo real
      _mesasSubscription = Supabase.instance.client
          .from('mesas')
          .stream(primaryKey: ['id'])
          .listen(
            (data) {
              final cacheTemporal = <int, String>{};
              for (var mesa in data) {
                cacheTemporal[mesa['id'] as int] = mesa['nombre'] as String;
              }

              _mesasCache = cacheTemporal;
              _isLoading = false;
              notifyListeners(); // Actualiza la UI de inmediato en toda la app
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

  // Limpieza de memoria cuando se destruye el provider
  @override
  void dispose() {
    _mesasSubscription?.cancel();
    super.dispose();
  }
}
