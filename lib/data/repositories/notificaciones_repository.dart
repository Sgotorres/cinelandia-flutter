// lib/data/repositories/notificaciones_repository.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../datasources/local_notificaciones_datasource.dart';

class NotificacionesRepository {
  final SupabaseClient _supabase;
  final LocalNotificacionesDataSource _localDataSource;
  RealtimeChannel? _broadcastChannel;
  final _controladorEventos =
      StreamController<Map<String, dynamic>>.broadcast();

  NotificacionesRepository({
    required SupabaseClient supabaseClient,
    LocalNotificacionesDataSource? localDataSource,
  }) : _supabase = supabaseClient,
       _localDataSource = localDataSource ?? LocalNotificacionesDataSource() {
    _iniciarCanalBroadcast();
  }

  Stream<Map<String, dynamic>> get eventosBroadcast =>
      _controladorEventos.stream;

  void _iniciarCanalBroadcast() {
    try {
      _broadcastChannel = _supabase.channel(
        'canal_timbre_pizzeria',
        opts: const RealtimeChannelConfig(self: true),
      );
      _broadcastChannel!
          .onBroadcast(
            event: 'timbre',
            callback: (payload) {
              _controladorEventos.add(Map<String, dynamic>.from(payload));
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Aviso canal broadcast: $e');
    }
  }

  Future<List<Map<String, dynamic>>> cargarPendientes(String rol) async {
    final rolLimpio = rol.trim().toLowerCase();
    final Map<int, Map<String, dynamic>> combinadas = {};

    final locales = await _localDataSource.obtenerPorRol(rolLimpio);
    for (final n in locales) {
      combinadas[n['id'] as int] = n;
    }

    try {
      final remotas = await _supabase
          .from('notificaciones')
          .select()
          .eq('receptor', rolLimpio)
          .eq('leido', false)
          .order('fecha', ascending: false);
      for (final item in remotas) {
        final map = Map<String, dynamic>.from(item);
        combinadas[map['id'] as int] = map;
      }
    } catch (_) {}

    final lista = combinadas.values.toList();
    lista.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
    return lista;
  }

  Future<Map<String, dynamic>> enviarNotificacion(
    String emisor,
    String receptor,
    String mensaje,
  ) async {
    final nuevaNoti = <String, dynamic>{
      'id': DateTime.now().millisecondsSinceEpoch,
      'emisor': emisor.trim().toLowerCase(),
      'receptor': receptor.trim().toLowerCase(),
      'mensaje': mensaje,
      'leido': false,
      'fecha': DateTime.now().toIso8601String(),
    };

    await _localDataSource.guardar(nuevaNoti);

    try {
      final res = await _supabase
          .from('notificaciones')
          .insert({
            'emisor': nuevaNoti['emisor'],
            'receptor': nuevaNoti['receptor'],
            'mensaje': mensaje,
            'leido': false,
          })
          .select()
          .maybeSingle();
      if (res != null && res['id'] != null) {
        nuevaNoti['id'] = res['id'];
      }
    } catch (_) {}

    try {
      await _broadcastChannel?.sendBroadcastMessage(
        event: 'timbre',
        payload: nuevaNoti,
      );
    } catch (_) {}

    return nuevaNoti;
  }

  Future<void> marcarComoLeida(int id) async {
    await _localDataSource.eliminar(id);
    try {
      await _supabase
          .from('notificaciones')
          .update({'leido': true})
          .eq('id', id);
    } catch (_) {}
  }
}
