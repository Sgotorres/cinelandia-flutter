import 'package:supabase_flutter/supabase_flutter.dart';

class NotificacionesRepository {
  final SupabaseClient _supabase;
  NotificacionesRepository({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  Stream<List<Map<String, dynamic>>> obtenerNotificacionesStream(String rol) {
    return _supabase.from('notificaciones').stream(primaryKey: ['id']).eq('receptor', rol).eq('leido', false).order('fecha', ascending: false);
  }

  Future<void> enviarNotificacion(String emisor, String receptor, String mensaje) async {
    await _supabase.from('notificaciones').insert({'emisor': emisor, 'receptor': receptor, 'mensaje': mensaje});
  }

  Future<void> marcarComoLeida(int id) async {
    await _supabase.from('notificaciones').update({'leido': true}).eq('id', id);
  }
}