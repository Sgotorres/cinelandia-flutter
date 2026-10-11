import 'package:flutter/material.dart';
import '../data/repositories/notificaciones_repository.dart';

class NotificacionesProvider extends ChangeNotifier {
  final NotificacionesRepository _repository;
  NotificacionesProvider(this._repository);

  Stream<List<Map<String, dynamic>>> notificacionesStream(String rol) {
    return _repository.obtenerNotificacionesStream(rol);
  }

  Future<void> enviarTimbre(String miRol, String miNombre) async {
    final receptor = miRol == 'admin' ? 'mesero' : 'admin';
    final emisorNombre = miRol == 'admin' ? 'La Administración' : 'Mesero: $miNombre';
    await _repository.enviarNotificacion(miRol, receptor, '🔔 $emisorNombre te está llamando');
  }

  Future<void> marcarComoLeida(int id) async {
    await _repository.marcarComoLeida(id);
  }
}