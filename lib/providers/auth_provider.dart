// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  bool _isLoading = false;
  String _errorMessage = '';
  
  // Variables que el router necesita para decidir adónde enviar al usuario
  bool get isLoggedIn => _supabase.auth.currentSession != null;
  String get userRole => _obtenerRolSimulado(); // En producción, esto vendría de Supabase

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Constructor: Escucha cambios de sesión automáticamente
  AuthProvider() {
    _supabase.auth.onAuthStateChange.listen((event) {
      // Cuando el usuario inicia sesión o cierra sesión, avisa al router
      notifyListeners();
    });
  }

  // Lógica de Inicio de Sesión
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      // Si el login fue exitoso, la variable isLoggedIn cambiará
      // y el router redireccionará automáticamente.
      _isLoading = false;
      notifyListeners();
      return true;

    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado al iniciar sesión';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Lógica de Cierre de Sesión
  Future<void> logout() async {
    await _supabase.auth.signOut();
    // El router detectará el cierre de sesión y enviará al usuario al Login
  }

  // Función temporal para simular roles. 
  // En tu base de datos de Supabase, deberías tener una tabla 'usuarios' con un campo 'rol'.
  String _obtenerRolSimulado() {
    final user = _supabase.auth.currentUser;
    if (user == null) return '';

    // Lógica rápida: Si el correo contiene la palabra 'admin', es admin. Si no, es mesero.
    // ESTO ES SOLO PARA PRUEBAS. Reemplázalo con una consulta a tu tabla de roles.
    if (user.email?.toLowerCase().contains('admin') ?? false) {
      return 'admin';
    }
    return 'mesero';
  }
}