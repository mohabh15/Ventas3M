import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  // Valores por defecto
  static const String _defaultThemeMode = 'system';
  static const String _defaultLanguage = 'es';

  // Claves para SharedPreferences
  static const String _themeModeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _activeProjectIdKey = 'active_project_id';

  // Propiedades privadas
  String _themeMode = _defaultThemeMode;
  String _language = _defaultLanguage;
  String? _activeProjectId;

  // Constructor
  SettingsProvider() {
    _loadSettings();
  }

  // Getters públicos
  String get themeMode => _themeMode;
  String get language => _language;
  String? get activeProjectId => _activeProjectId;

  // Métodos para actualizar configuraciones
  void setThemeMode(String themeMode) {
    if (_themeMode != themeMode) {
      _themeMode = themeMode;
      _saveThemeMode();
      notifyListeners();
    }
  }

  void setLanguage(String language) {
    if (_language != language) {
      _language = language;
      _saveLanguage();
      notifyListeners();
    }
  }

  void setActiveProjectId(String? projectId) {
    if (_activeProjectId != projectId) {
      _activeProjectId = projectId;
      _saveActiveProjectId();
      notifyListeners();
    }
  }

  // Métodos privados para guardar en SharedPreferences
  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, _themeMode);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  Future<void> _saveLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, _language);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  Future<void> _saveActiveProjectId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_activeProjectId != null) {
        await prefs.setString(_activeProjectIdKey, _activeProjectId!);
      } else {
        await prefs.remove(_activeProjectIdKey);
      }
    } catch (e) {
      debugPrint('Error saving active project id: $e');
    }
  }

  // Método privado para cargar configuraciones
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Cargar theme mode con fallback a valor por defecto
      _themeMode = prefs.getString(_themeModeKey) ?? _defaultThemeMode;

      // Cargar language con fallback a valor por defecto
      _language = prefs.getString(_languageKey) ?? _defaultLanguage;

      // Cargar active project id
      _activeProjectId = prefs.getString(_activeProjectIdKey);

      // Notificar cambios después de que el frame esté construido para evitar
      // problemas de setState() durante build en otros providers
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
      // En caso de error, mantener valores por defecto
      _themeMode = _defaultThemeMode;
      _language = _defaultLanguage;
    }
  }

  // Método para resetear todas las configuraciones a valores por defecto
  Future<void> resetToDefaults() async {
    _themeMode = _defaultThemeMode;
    _language = _defaultLanguage;
    _activeProjectId = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, _themeMode);
      await prefs.setString(_languageKey, _language);
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting settings: $e');
    }
  }

  // Método para limpiar todas las configuraciones
  Future<void> clearAllSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_themeModeKey);
      await prefs.remove(_languageKey);
      await prefs.remove(_activeProjectIdKey);
      await resetToDefaults();
    } catch (e) {
      debugPrint('Error clearing settings: $e');
    }
  }

  // Método para verificar si hay configuraciones guardadas
  Future<bool> hasSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_themeModeKey) || prefs.containsKey(_languageKey) || prefs.containsKey(_activeProjectIdKey);
    } catch (e) {
      debugPrint('Error checking settings: $e');
      return false;
    }
  }
}