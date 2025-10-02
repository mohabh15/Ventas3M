import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // Estados
  User? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // Clave para almacenamiento local
  static const String _userKey = 'current_user';
  static const String _sessionKey = 'user_session';

  AuthProvider() {
    _initializeAuth();
  }

  // Inicializar autenticación al crear el provider
  Future<void> _initializeAuth() async {
    _setLoading(true);

    try {
      // Verificar si hay una sesión guardada
      final prefs = await SharedPreferences.getInstance();
      final hasSession = prefs.getBool(_sessionKey) ?? false;

      if (hasSession) {
        // Intentar restaurar la sesión
        await checkCurrentSession();
      } else {
        _setLoading(false);
      }
    } catch (e) {
      _setError('Error al inicializar autenticación: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Método de login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.login(email, password);
      await _setAuthenticatedUser(user);

      // Guardar sesión
      await _saveSession();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Método de login con Google
  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.loginWithGoogle();
      await _setAuthenticatedUser(user);

      // Guardar sesión
      await _saveSession();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Método de registro
  Future<bool> register(String email, String password, String name, {String? phone}) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.register(email, password, name, phone: phone);
      await _setAuthenticatedUser(user);

      // Guardar sesión
      await _saveSession();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Método de logout
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
      await _clearSession();
      _setUnauthenticatedUser();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Verificar sesión actual
  Future<bool> checkCurrentSession() async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.checkCurrentSession();

      if (user != null) {
        await _setAuthenticatedUser(user);
        await _saveSession();
        return true;
      } else {
        await _clearSession();
        _setUnauthenticatedUser();
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      await _clearSession();
      _setUnauthenticatedUser();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar perfil de usuario
  Future<bool> updateProfile({String? name, String? phone, String? photoUrl}) async {
    if (_currentUser == null) {
      _setError('Usuario no autenticado');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final updatedUser = await _authService.updateProfile(
        _currentUser!.id,
        name: name,
        phone: phone,
        photoUrl: photoUrl,
      );

      await _setAuthenticatedUser(updatedUser);
      await _saveSession();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Enviar email de recuperación de contraseña
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Método para entrar como invitado
  Future<void> loginAsGuest() async {
    _setLoading(true);
    _clearError();

    try {
      // Crear usuario invitado
      final guestUser = User(
        id: 'guest',
        name: 'Invitado',
        email: 'guest@example.com',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _setAuthenticatedUser(guestUser);
      await _saveSession();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Limpiar errores
  void clearError() {
    _clearError();
  }

  // Método auxiliar para establecer usuario autenticado
  Future<void> _setAuthenticatedUser(User user) async {
    _currentUser = user;
    _isAuthenticated = true;
    _errorMessage = null;
    notifyListeners();
  }

  // Método auxiliar para establecer usuario no autenticado
  void _setUnauthenticatedUser() {
    _currentUser = null;
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Método auxiliar para establecer estado de carga
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Método auxiliar para establecer error
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Método auxiliar para limpiar error
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Método auxiliar para guardar sesión en SharedPreferences
  Future<void> _saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_currentUser != null) {
        // Guardar datos del usuario
        await prefs.setString(_userKey, _currentUser!.toMap().toString());
        // Marcar sesión como activa
        await prefs.setBool(_sessionKey, true);
      }
    } catch (e) {
      // Warning: Could not save session (removed print for production)
    }
  }

  // Método auxiliar para limpiar sesión
  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.setBool(_sessionKey, false);
    } catch (e) {
      // Warning: Could not clear session (removed print for production)
    }
  }


  // Stream para escuchar cambios de autenticación desde Firebase
  Stream<AuthState> get authStateStream {
    return _authService.authStateChanges.map((firebaseUser) {
      if (firebaseUser != null) {
        return AuthState.authenticated;
      } else {
        return AuthState.unauthenticated;
      }
    });
  }
}

// Enum para estados de autenticación
enum AuthState {
  authenticated,
  unauthenticated,
  loading,
}