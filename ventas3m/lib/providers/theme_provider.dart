import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';
import 'settings_provider.dart';

class ThemeProvider extends ChangeNotifier {
  // Valores por defecto
  static const bool _defaultIsDark = false;
  static const bool _defaultHighContrast = false;

  // Claves para SharedPreferences
  static const String _isDarkKey = 'is_dark_mode';
  static const String _highContrastKey = 'high_contrast_mode';

  // Propiedades privadas
  bool _isDark = _defaultIsDark;
  bool _highContrast = _defaultHighContrast;

  // Referencia al Settings Provider para sincronización
  SettingsProvider? _settingsProvider;

  // Constructor
  ThemeProvider() {
    _loadThemePreferences();
  }

  // Getters públicos
  bool get isDark => _isDark;
  bool get highContrast => _highContrast;

  // Getter para obtener el tema actual usando el método de AppTheme
  ThemeData get currentTheme => AppTheme.getTheme(
    isDark: _isDark,
    highContrast: _highContrast,
  );

  // Métodos para cambiar el modo de tema
  void toggleDarkMode() {
    setDarkMode(!_isDark);
  }

  void setDarkMode(bool isDark) {
    if (_isDark != isDark) {
      _isDark = isDark;
      _saveIsDarkMode();
      _updateSettingsProvider();
      notifyListeners();
    }
  }

  void toggleHighContrast() {
    setHighContrast(!_highContrast);
  }

  void setHighContrast(bool highContrast) {
    if (_highContrast != highContrast) {
      _highContrast = highContrast;
      _saveHighContrastMode();
      _updateSettingsProvider();
      notifyListeners();
    }
  }

  // Método para establecer ambos modos a la vez
  void setThemeMode({required bool isDark, required bool highContrast}) {
    if (_isDark != isDark || _highContrast != highContrast) {
      _isDark = isDark;
      _highContrast = highContrast;
      _saveThemePreferences();
      _updateSettingsProvider();
      notifyListeners();
    }
  }

  // Método para alternar entre modos predefinidos
  void setThemePreset(ThemePreset preset) {
    switch (preset) {
      case ThemePreset.light:
        setThemeMode(isDark: false, highContrast: false);
        break;
      case ThemePreset.dark:
        setThemeMode(isDark: true, highContrast: false);
        break;
      case ThemePreset.highContrast:
        setThemeMode(isDark: false, highContrast: true);
        break;
    }
  }

  // Método para establecer el Settings Provider para sincronización
  void setSettingsProvider(SettingsProvider settingsProvider) {
    _settingsProvider = settingsProvider;
  }

  // Métodos privados para guardar en SharedPreferences
  Future<void> _saveIsDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isDarkKey, _isDark);
    } catch (e) {
      debugPrint('Error saving dark mode preference: $e');
    }
  }

  Future<void> _saveHighContrastMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_highContrastKey, _highContrast);
    } catch (e) {
      debugPrint('Error saving high contrast preference: $e');
    }
  }

  Future<void> _saveThemePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isDarkKey, _isDark);
      await prefs.setBool(_highContrastKey, _highContrast);
    } catch (e) {
      debugPrint('Error saving theme preferences: $e');
    }
  }

  // Método privado para cargar preferencias de tema
  Future<void> _loadThemePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Cargar modo oscuro con fallback a valor por defecto
      _isDark = prefs.getBool(_isDarkKey) ?? _defaultIsDark;

      // Cargar alto contraste con fallback a valor por defecto
      _highContrast = prefs.getBool(_highContrastKey) ?? _defaultHighContrast;

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preferences: $e');
      // En caso de error, mantener valores por defecto
      _isDark = _defaultIsDark;
      _highContrast = _defaultHighContrast;
    }
  }

  // Método privado para actualizar el Settings Provider
  void _updateSettingsProvider() {
    if (_settingsProvider != null) {
      // Sincronizar con el theme mode del Settings Provider
      String themeMode;
      if (_highContrast) {
        themeMode = 'high_contrast';
      } else if (_isDark) {
        themeMode = 'dark';
      } else {
        themeMode = 'light';
      }
      _settingsProvider!.setThemeMode(themeMode);
    }
  }

  // Método para resetear todas las preferencias de tema a valores por defecto
  Future<void> resetToDefaults() async {
    _isDark = _defaultIsDark;
    _highContrast = _defaultHighContrast;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isDarkKey, _isDark);
      await prefs.setBool(_highContrastKey, _highContrast);
      _updateSettingsProvider();
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting theme preferences: $e');
    }
  }

  // Método para limpiar todas las preferencias de tema
  Future<void> clearAllPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_isDarkKey);
      await prefs.remove(_highContrastKey);
      await resetToDefaults();
    } catch (e) {
      debugPrint('Error clearing theme preferences: $e');
    }
  }

  // Método para verificar si hay preferencias de tema guardadas
  Future<bool> hasPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_isDarkKey) || prefs.containsKey(_highContrastKey);
    } catch (e) {
      debugPrint('Error checking theme preferences: $e');
      return false;
    }
  }

  // Método para obtener información del tema actual como mapa
  Map<String, dynamic> get themeInfo => {
    'isDark': _isDark,
    'highContrast': _highContrast,
    'themeMode': _highContrast ? 'high_contrast' : (_isDark ? 'dark' : 'light'),
  };

  // Método para copiar configuración desde otro ThemeProvider
  void copyFrom(ThemeProvider other) {
    setThemeMode(isDark: other._isDark, highContrast: other._highContrast);
  }
}

// Enum para modos de tema predefinidos
enum ThemePreset {
  light,
  dark,
  highContrast,
}