// lib/presentation/shared/providers/notificaciones_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/utils/sound_service.dart';
import '../../../data/repositories/notificaciones_repository.dart';

class NotificacionesProvider extends ChangeNotifier {
  final NotificacionesRepository _repository;
  final SoundService _soundService;

  StreamSubscription<Map<String, dynamic>>? _broadcastSub;
  List<Map<String, dynamic>> _notificaciones = [];
  String _rolActual = '';
  String? _ultimoMensajeRecibido;

  NotificacionesProvider(this._repository, this._soundService) {
    _broadcastSub = _repository.eventosBroadcast.listen(_alRecibirBroadcast);
  }

  List<Map<String, dynamic>> get notificaciones => _notificaciones;
  String? get ultimoMensajeRecibido => _ultimoMensajeRecibido;

  void limpiarUltimoMensaje() {
    _ultimoMensajeRecibido = null;
  }

  Future<void> configurarRol(String rol) async {
    final rolLimpio = rol.trim().toLowerCase();
    if (rolLimpio.isEmpty) return;

    final cambioRol = _rolActual != rolLimpio;
    _rolActual = rolLimpio;

    final pendientes = await _repository.cargarPendientes(rolLimpio);
    final habiaMenos = pendientes.length > _notificaciones.length;
    _notificaciones = pendientes;
    notifyListeners();

    // Si al iniciar sesión con este rol tiene llamadas pendientes nuevas, suena
    if (cambioRol && _notificaciones.isNotEmpty && habiaMenos) {
      await _soundService.tocarCampanita();
    }
  }

  void _alRecibirBroadcast(Map<String, dynamic> payload) {
    final receptor = payload['receptor']?.toString().toLowerCase() ?? '';
    if (_rolActual.isNotEmpty && receptor == _rolActual) {
      final id = payload['id'] as int;
      final yaExiste = _notificaciones.any((n) => n['id'] == id);
      if (!yaExiste) {
        _notificaciones = [payload, ..._notificaciones];
        _ultimoMensajeRecibido = payload['mensaje']?.toString();
        _soundService.tocarCampanita();
        notifyListeners();
      }
    }
  }

  Future<void> enviarTimbre(String miRol, String miNombre) async {
    final rolLimpio = miRol.trim().toLowerCase().isEmpty
        ? 'mesero'
        : miRol.trim().toLowerCase();
    final receptor = rolLimpio == 'admin' ? 'mesero' : 'admin';
    final nombreMostrado =
        miNombre.isEmpty || miNombre == 'Cargando...' ? rolLimpio : miNombre;
    final emisorNombre = rolLimpio == 'admin'
        ? 'La Administración'
        : 'Mesero ($nombreMostrado)';

    await _repository.enviarNotificacion(
      rolLimpio,
      receptor,
      '🔔 $emisorNombre te está llamando',
    );

    // Hacemos sonar la campanita como confirmación auditiva inmediata
    await _soundService.tocarCampanita();
  }

  Future<void> marcarComoLeida(int id) async {
    _notificaciones = _notificaciones.where((n) => n['id'] != id).toList();
    notifyListeners();
    await _repository.marcarComoLeida(id);
  }

  @override
  void dispose() {
    _broadcastSub?.cancel();
    super.dispose();
  }
}
