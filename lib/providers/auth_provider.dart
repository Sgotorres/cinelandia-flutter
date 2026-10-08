// lib/providers/auth_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  StreamSubscription<AuthState>? _authSubscription;
  bool _isLoading = false;
  String _errorMessage = '';

  String _nombre = '';
  String _apellido = '';
  
  // 1. NUEVA VARIABLE: Almacena el rol real del usuario autenticado
  String _rol = '';

  bool get isLoggedIn => _supabase.auth.currentSession != null;
  
  // 2. GETTER ACTUALIZADO: Devuelve el rol real en memoria. Por defecto, 'mesero'.
  String get userRole => _rol.isEmpty ? 'mesero' : _rol; 
  
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get nombreCompleto => _nombre.isNotEmpty ? '$_nombre $_apellido'.trim() : 'Cargando...';

  AuthProvider() {
    _authSubscription = _supabase.auth.onAuthStateChange.listen((event) {
      if (event.session != null) {
        _cargarDatosUsuario();
      } else {
        // Limpiar datos sensibles al cerrar sesión
        _nombre = '';
        _apellido = '';
        _rol = ''; 
      }
      notifyListeners();
    });
  }

  Future<void> _cargarDatosUsuario() async {
    final user = _supabase.auth.currentUser;
    if (user == null || user.email == null) return;

    try {
      // 3. CONSULTA SEGURA: Añadimos 'rol' al select para traerlo de Supabase
      final response = await _supabase
          .from('usuarios')
          .select('nombre, apellido, rol') 
          .eq('correo', user.email!)
          .maybeSingle();

      if (response != null) {
        _nombre = response['nombre'] ?? '';
        _apellido = response['apellido'] ?? '';
        // 4. ASIGNACIÓN: Guardamos el rol. Si viene nulo de la DB, asignamos 'mesero' por seguridad.
        _rol = response['rol'] ?? 'mesero'; 
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error cargando datos del usuario: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
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

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}