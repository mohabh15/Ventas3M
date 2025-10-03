import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/app_settings.dart';
import '../models/user.dart';

class SettingsProvider extends ChangeNotifier {
  // Claves para SharedPreferences
  static const String _appSettingsKey = 'app_settings';
  static const String _userProfileKey = 'user_profile';
  static const String _securitySettingsKey = 'security_settings';
  static const String _projectSettingsKey = 'project_settings';
  static const String _activeSessionsKey = 'active_sessions';

  // Propiedades privadas
  AppSettings _appSettings = AppSettings();
  UserProfile? _userProfile;
  SecuritySettings? _securitySettings;
  Map<String, ProjectSettings> _projectSettings = {};
  List<ActiveSession> _activeSessions = [];

  // Constructor
  SettingsProvider() {
    _loadSettings();
  }

  // Getters públicos para configuración de aplicación
  String get themeMode => _appSettings.themeMode;
  String get language => _appSettings.language;
  String get region => _appSettings.region;
  bool get pushNotifications => _appSettings.pushNotifications;
  bool get emailNotifications => _appSettings.emailNotifications;
  bool get smsNotifications => _appSettings.smsNotifications;
  bool get notificationSound => _appSettings.notificationSound;
  bool get notificationVibration => _appSettings.notificationVibration;
  bool get analyticsEnabled => _appSettings.analyticsEnabled;
  bool get crashReportingEnabled => _appSettings.crashReportingEnabled;
  bool get dataSharingEnabled => _appSettings.dataSharingEnabled;
  bool get biometricEnabled => _appSettings.biometricEnabled;
  bool get autoBackup => _appSettings.autoBackup;
  int get backupFrequency => _appSettings.backupFrequency;
  bool get autoSync => _appSettings.autoSync;
  int get syncFrequency => _appSettings.syncFrequency;
  bool get dataSaverMode => _appSettings.dataSaverMode;
  bool get accessibilityMode => _appSettings.accessibilityMode;
  String? get activeProjectId => _appSettings.activeProjectId;
  bool get showProjectStats => _appSettings.showProjectStats;
  bool get autoSwitchProject => _appSettings.autoSwitchProject;
  bool get twoFactorEnabled => _appSettings.twoFactorEnabled;
  bool get sessionTimeoutEnabled => _appSettings.sessionTimeoutEnabled;
  int get sessionTimeoutMinutes => _appSettings.sessionTimeoutMinutes;

  // Getters para modelos completos
  AppSettings get appSettings => _appSettings;
  UserProfile? get userProfile => _userProfile;
  SecuritySettings? get securitySettings => _securitySettings;
  Map<String, ProjectSettings> get projectSettings => _projectSettings;
  List<ActiveSession> get activeSessions => _activeSessions;

  // Métodos para actualizar configuración de aplicación
  void setThemeMode(String themeMode) {
    if (_appSettings.themeMode != themeMode) {
      _appSettings = _appSettings.copyWith(themeMode: themeMode);
      _saveAppSettings();
      notifyListeners();
    }
  }

  void setLanguage(String language) {
    if (_appSettings.language != language) {
      _appSettings = _appSettings.copyWith(language: language);
      _saveAppSettings();
      notifyListeners();
    }
  }

  void setRegion(String region) {
    if (_appSettings.region != region) {
      _appSettings = _appSettings.copyWith(region: region);
      _saveAppSettings();
      notifyListeners();
    }
  }

  void setActiveProjectId(String? projectId) {
    if (_appSettings.activeProjectId != projectId) {
      _appSettings = _appSettings.copyWith(activeProjectId: projectId);
      _saveAppSettings();
      notifyListeners();
    }
  }

  void setNotificationSettings({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? notificationSound,
    bool? notificationVibration,
  }) {
    _appSettings = _appSettings.copyWith(
      pushNotifications: pushNotifications,
      emailNotifications: emailNotifications,
      smsNotifications: smsNotifications,
      notificationSound: notificationSound,
      notificationVibration: notificationVibration,
    );
    _saveAppSettings();
    notifyListeners();
  }

  void setPrivacySettings({
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
    bool? dataSharingEnabled,
    bool? biometricEnabled,
  }) {
    _appSettings = _appSettings.copyWith(
      analyticsEnabled: analyticsEnabled,
      crashReportingEnabled: crashReportingEnabled,
      dataSharingEnabled: dataSharingEnabled,
      biometricEnabled: biometricEnabled,
    );
    _saveAppSettings();
    notifyListeners();
  }

  void setAdvancedSettings({
    bool? autoBackup,
    int? backupFrequency,
    bool? autoSync,
    int? syncFrequency,
    bool? dataSaverMode,
    bool? accessibilityMode,
  }) {
    _appSettings = _appSettings.copyWith(
      autoBackup: autoBackup,
      backupFrequency: backupFrequency,
      autoSync: autoSync,
      syncFrequency: syncFrequency,
      dataSaverMode: dataSaverMode,
      accessibilityMode: accessibilityMode,
    );
    _saveAppSettings();
    notifyListeners();
  }

  void setSecuritySettings({
    bool? twoFactorEnabled,
    bool? sessionTimeoutEnabled,
    int? sessionTimeoutMinutes,
  }) {
    _appSettings = _appSettings.copyWith(
      twoFactorEnabled: twoFactorEnabled,
      sessionTimeoutEnabled: sessionTimeoutEnabled,
      sessionTimeoutMinutes: sessionTimeoutMinutes,
    );
    _saveAppSettings();
    notifyListeners();
  }

  // Métodos para gestión de perfil de usuario
  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
    _saveUserProfile();
    notifyListeners();
  }

  void updateUserProfile({
    String? firstName,
    String? lastName,
    String? displayName,
    String? phone,
    String? bio,
    String? location,
    String? website,
    DateTime? birthDate,
    String? gender,
    String? preferredLanguage,
  }) {
    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(
        firstName: firstName,
        lastName: lastName,
        displayName: displayName,
        phone: phone,
        bio: bio,
        location: location,
        website: website,
        birthDate: birthDate,
        gender: gender,
        preferredLanguage: preferredLanguage,
      );
      _saveUserProfile();
      notifyListeners();
    }
  }

  // Métodos para gestión de configuración de seguridad
  void setSecuritySettingsModel(SecuritySettings settings) {
    _securitySettings = settings;
    _saveSecuritySettings();
    notifyListeners();
  }

  void addSecurityEvent(SecurityEvent event) {
    if (_securitySettings != null) {
      final updatedEvents = List<SecurityEvent>.from(_securitySettings!.securityEvents)..add(event);
      _securitySettings = _securitySettings!.copyWith(securityEvents: updatedEvents);
      _saveSecuritySettings();
      notifyListeners();
    }
  }

  // Métodos para gestión de configuración de proyectos
  void setProjectSettings(String projectId, ProjectSettings settings) {
    _projectSettings[projectId] = settings;
    _saveProjectSettings();
    notifyListeners();
  }

  void removeProjectSettings(String projectId) {
    _projectSettings.remove(projectId);
    _saveProjectSettings();
    notifyListeners();
  }

  ProjectSettings? getProjectSettings(String projectId) {
    return _projectSettings[projectId];
  }

  // Métodos para gestión de sesiones activas
  void setActiveSessions(List<ActiveSession> sessions) {
    _activeSessions = sessions;
    _saveActiveSessions();
    notifyListeners();
  }

  void addActiveSession(ActiveSession session) {
    _activeSessions.add(session);
    _saveActiveSessions();
    notifyListeners();
  }

  void removeActiveSession(String sessionId) {
    _activeSessions.removeWhere((session) => session.sessionId == sessionId);
    _saveActiveSessions();
    notifyListeners();
  }

  // Métodos privados para guardar en SharedPreferences
  Future<void> _saveAppSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_appSettingsKey, jsonEncode(_appSettings.toJson()));
    } catch (e) {
      debugPrint('Error saving app settings: $e');
    }
  }

  Future<void> _saveUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_userProfile != null) {
        await prefs.setString(_userProfileKey, jsonEncode(_userProfile!.toJson()));
      } else {
        await prefs.remove(_userProfileKey);
      }
    } catch (e) {
      debugPrint('Error saving user profile: $e');
    }
  }

  Future<void> _saveSecuritySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_securitySettings != null) {
        await prefs.setString(_securitySettingsKey, jsonEncode(_securitySettings!.toJson()));
      } else {
        await prefs.remove(_securitySettingsKey);
      }
    } catch (e) {
      debugPrint('Error saving security settings: $e');
    }
  }

  Future<void> _saveProjectSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final projectSettingsMap = _projectSettings.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      await prefs.setString(_projectSettingsKey, jsonEncode(projectSettingsMap));
    } catch (e) {
      debugPrint('Error saving project settings: $e');
    }
  }

  Future<void> _saveActiveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsList = _activeSessions.map((session) => session.toJson()).toList();
      await prefs.setString(_activeSessionsKey, jsonEncode(sessionsList));
    } catch (e) {
      debugPrint('Error saving active sessions: $e');
    }
  }

  // Método privado para cargar configuraciones
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Cargar configuración de aplicación
      final appSettingsJson = prefs.getString(_appSettingsKey);
      if (appSettingsJson != null) {
        _appSettings = AppSettings.fromJson(jsonDecode(appSettingsJson));
      }

      // Cargar perfil de usuario
      final userProfileJson = prefs.getString(_userProfileKey);
      if (userProfileJson != null) {
        _userProfile = UserProfile.fromJson(jsonDecode(userProfileJson));
      }

      // Cargar configuración de seguridad
      final securitySettingsJson = prefs.getString(_securitySettingsKey);
      if (securitySettingsJson != null) {
        _securitySettings = SecuritySettings.fromJson(jsonDecode(securitySettingsJson));
      }

      // Cargar configuración de proyectos
      final projectSettingsJson = prefs.getString(_projectSettingsKey);
      if (projectSettingsJson != null) {
        final projectSettingsMap = jsonDecode(projectSettingsJson) as Map<String, dynamic>;
        _projectSettings = projectSettingsMap.map(
          (key, value) => MapEntry(key, ProjectSettings.fromJson(value)),
        );
      }

      // Cargar sesiones activas
      final activeSessionsJson = prefs.getString(_activeSessionsKey);
      if (activeSessionsJson != null) {
        final sessionsList = jsonDecode(activeSessionsJson) as List<dynamic>;
        _activeSessions = sessionsList.map((session) => ActiveSession.fromJson(session)).toList();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
      // En caso de error, mantener valores por defecto
      _appSettings = AppSettings();
    }
  }

  // Método para resetear todas las configuraciones a valores por defecto
  Future<void> resetToDefaults() async {
    _appSettings = AppSettings();
    _userProfile = null;
    _securitySettings = null;
    _projectSettings.clear();
    _activeSessions.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_appSettingsKey);
      await prefs.remove(_userProfileKey);
      await prefs.remove(_securitySettingsKey);
      await prefs.remove(_projectSettingsKey);
      await prefs.remove(_activeSessionsKey);
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting settings: $e');
    }
  }

  // Método para limpiar todas las configuraciones
  Future<void> clearAllSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_appSettingsKey);
      await prefs.remove(_userProfileKey);
      await prefs.remove(_securitySettingsKey);
      await prefs.remove(_projectSettingsKey);
      await prefs.remove(_activeSessionsKey);
      await resetToDefaults();
    } catch (e) {
      debugPrint('Error clearing settings: $e');
    }
  }

  // Método para verificar si hay configuraciones guardadas
  Future<bool> hasSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_appSettingsKey) ||
             prefs.containsKey(_userProfileKey) ||
             prefs.containsKey(_securitySettingsKey) ||
             prefs.containsKey(_projectSettingsKey) ||
             prefs.containsKey(_activeSessionsKey);
    } catch (e) {
      debugPrint('Error checking settings: $e');
      return false;
    }
  }

  // Método para exportar configuración
  Map<String, dynamic> exportSettings() {
    return {
      'appSettings': _appSettings.toJson(),
      'userProfile': _userProfile?.toJson(),
      'securitySettings': _securitySettings?.toJson(),
      'projectSettings': _projectSettings.map((key, value) => MapEntry(key, value.toJson())),
      'activeSessions': _activeSessions.map((session) => session.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  // Método para importar configuración
  Future<void> importSettings(Map<String, dynamic> settingsData) async {
    try {
      if (settingsData.containsKey('appSettings')) {
        _appSettings = AppSettings.fromJson(settingsData['appSettings']);
      }

      if (settingsData.containsKey('userProfile') && settingsData['userProfile'] != null) {
        _userProfile = UserProfile.fromJson(settingsData['userProfile']);
      }

      if (settingsData.containsKey('securitySettings') && settingsData['securitySettings'] != null) {
        _securitySettings = SecuritySettings.fromJson(settingsData['securitySettings']);
      }

      if (settingsData.containsKey('projectSettings')) {
        final projectSettingsMap = settingsData['projectSettings'] as Map<String, dynamic>;
        _projectSettings = projectSettingsMap.map(
          (key, value) => MapEntry(key, ProjectSettings.fromJson(value)),
        );
      }

      if (settingsData.containsKey('activeSessions')) {
        final sessionsList = settingsData['activeSessions'] as List<dynamic>;
        _activeSessions = sessionsList.map((session) => ActiveSession.fromJson(session)).toList();
      }

      // Guardar todas las configuraciones
      await _saveAppSettings();
      await _saveUserProfile();
      await _saveSecuritySettings();
      await _saveProjectSettings();
      await _saveActiveSessions();

      notifyListeners();
    } catch (e) {
      debugPrint('Error importing settings: $e');
      throw Exception('Error al importar configuración: $e');
    }
  }
}