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
  String _rol = '';
  
  // Bandera clave: le dice al router si ya terminamos de leer la base de datos
  bool _isRoleLoaded = false;

  bool get isLoggedIn => _supabase.auth.currentSession != null;
  bool get isRoleLoaded => _isRoleLoaded;
  String get userRole => _rol;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get nombreCompleto =>
      _nombre.isNotEmpty ? '$_nombre $_apellido'.trim() : 'Cargando...';

  AuthProvider() {
    // Si ya existe una sesión guardada al arrancar la app, cargamos los datos
    if (_supabase.auth.currentSession != null) {
      _cargarDatosUsuario();
    }

    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null) {
        // Al detectar sesión activa, consultamos el rol
        await _cargarDatosUsuario();
      } else {
        // Al cerrar sesión, limpiamos la memoria
        _nombre = '';
        _apellido = '';
        _rol = '';
        _isRoleLoaded = false;
        notifyListeners();
      }
    });
  }

  Future<void> _cargarDatosUsuario() async {
    final user = _supabase.auth.currentUser;
    if (user == null || user.email == null) return;

    try {
      final response = await _supabase
          .from('usuarios')
          .select('nombre, apellido, rol')
          .eq('correo', user.email!)
          .maybeSingle();

      if (response != null) {
        _nombre = response['nombre'] ?? '';
        _apellido = response['apellido'] ?? '';
        // Normalizamos el rol a minúsculas por si acaso. Por defecto: mesero.
        _rol = (response['rol'] ?? 'mesero').toString().trim().toLowerCase();
      } else {
        _rol = 'mesero';
      }
    } catch (e) {
      debugPrint('Error cargando datos del usuario: $e');
      _rol = 'mesero'; // En caso de fallo de red, asumimos mesero por seguridad
    } finally {
      // Sin importar si falla o tiene éxito, indicamos que ya terminamos de cargar
      _isRoleLoaded = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    _isRoleLoaded = false;
    notifyListeners();

    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Bloqueamos el retorno hasta que se haya leído la tabla de usuarios
      await _cargarDatosUsuario();

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      _isRoleLoaded = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado al iniciar sesión';
      _isLoading = false;
      _isRoleLoaded = false;
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