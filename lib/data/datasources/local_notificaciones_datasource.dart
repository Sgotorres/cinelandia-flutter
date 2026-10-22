// lib/data/datasources/local_notificaciones_datasource.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotificacionesDataSource {
  static const String _localKey = 'notificaciones_locales_cache';

  Future<List<Map<String, dynamic>>> obtenerTodas() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_localKey) ?? [];
    return raw.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> obtenerPorRol(String rol) async {
    final todas = await obtenerTodas();
    return todas
        .where(
          (n) =>
              n['receptor']?.toString().toLowerCase() == rol.toLowerCase() &&
              n['leido'] != true,
        )
        .toList();
  }

  Future<void> guardar(Map<String, dynamic> noti) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = await obtenerTodas();
    lista.insert(0, noti);
    await prefs.setStringList(
      _localKey,
      lista.map((e) => jsonEncode(e)).toList(),
    );
  }

  Future<void> eliminar(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = await obtenerTodas();
    lista.removeWhere((n) => n['id'] == id);
    await prefs.setStringList(
      _localKey,
      lista.map((e) => jsonEncode(e)).toList(),
    );
  }
}
