/// Configuración completa de la aplicación
class AppSettings {
  // Tema y apariencia
  String themeMode;
  String language;
  String region;

  // Notificaciones
  bool pushNotifications;
  bool emailNotifications;
  bool smsNotifications;
  bool notificationSound;
  bool notificationVibration;

  // Privacidad
  bool analyticsEnabled;
  bool crashReportingEnabled;
  bool dataSharingEnabled;
  bool biometricEnabled;

  // Configuración avanzada
  bool autoBackup;
  int backupFrequency; // en días
  bool autoSync;
  int syncFrequency; // en minutos
  bool dataSaverMode;
  bool accessibilityMode;

  // Configuración de proyectos
  String? activeProjectId;
  bool showProjectStats;
  bool autoSwitchProject;

  // Configuración de seguridad
  bool twoFactorEnabled;
  bool sessionTimeoutEnabled;
  int sessionTimeoutMinutes;

  AppSettings({
    this.themeMode = 'system',
    this.language = 'es',
    this.region = 'ES',
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.notificationSound = true,
    this.notificationVibration = true,
    this.analyticsEnabled = true,
    this.crashReportingEnabled = true,
    this.dataSharingEnabled = false,
    this.biometricEnabled = false,
    this.autoBackup = true,
    this.backupFrequency = 7,
    this.autoSync = true,
    this.syncFrequency = 30,
    this.dataSaverMode = false,
    this.accessibilityMode = false,
    this.activeProjectId,
    this.showProjectStats = true,
    this.autoSwitchProject = false,
    this.twoFactorEnabled = false,
    this.sessionTimeoutEnabled = true,
    this.sessionTimeoutMinutes = 30,
  });

  // Crear copia con modificaciones
  AppSettings copyWith({
    String? themeMode,
    String? language,
    String? region,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? notificationSound,
    bool? notificationVibration,
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
    bool? dataSharingEnabled,
    bool? biometricEnabled,
    bool? autoBackup,
    int? backupFrequency,
    bool? autoSync,
    int? syncFrequency,
    bool? dataSaverMode,
    bool? accessibilityMode,
    String? activeProjectId,
    bool? showProjectStats,
    bool? autoSwitchProject,
    bool? twoFactorEnabled,
    bool? sessionTimeoutEnabled,
    int? sessionTimeoutMinutes,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      region: region ?? this.region,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      notificationSound: notificationSound ?? this.notificationSound,
      notificationVibration: notificationVibration ?? this.notificationVibration,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      crashReportingEnabled: crashReportingEnabled ?? this.crashReportingEnabled,
      dataSharingEnabled: dataSharingEnabled ?? this.dataSharingEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoBackup: autoBackup ?? this.autoBackup,
      backupFrequency: backupFrequency ?? this.backupFrequency,
      autoSync: autoSync ?? this.autoSync,
      syncFrequency: syncFrequency ?? this.syncFrequency,
      dataSaverMode: dataSaverMode ?? this.dataSaverMode,
      accessibilityMode: accessibilityMode ?? this.accessibilityMode,
      activeProjectId: activeProjectId ?? this.activeProjectId,
      showProjectStats: showProjectStats ?? this.showProjectStats,
      autoSwitchProject: autoSwitchProject ?? this.autoSwitchProject,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      sessionTimeoutEnabled: sessionTimeoutEnabled ?? this.sessionTimeoutEnabled,
      sessionTimeoutMinutes: sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
    );
  }

  // Convertir a/from JSON para almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode,
      'language': language,
      'region': region,
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'smsNotifications': smsNotifications,
      'notificationSound': notificationSound,
      'notificationVibration': notificationVibration,
      'analyticsEnabled': analyticsEnabled,
      'crashReportingEnabled': crashReportingEnabled,
      'dataSharingEnabled': dataSharingEnabled,
      'biometricEnabled': biometricEnabled,
      'autoBackup': autoBackup,
      'backupFrequency': backupFrequency,
      'autoSync': autoSync,
      'syncFrequency': syncFrequency,
      'dataSaverMode': dataSaverMode,
      'accessibilityMode': accessibilityMode,
      'activeProjectId': activeProjectId,
      'showProjectStats': showProjectStats,
      'autoSwitchProject': autoSwitchProject,
      'twoFactorEnabled': twoFactorEnabled,
      'sessionTimeoutEnabled': sessionTimeoutEnabled,
      'sessionTimeoutMinutes': sessionTimeoutMinutes,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: json['themeMode'] ?? 'system',
      language: json['language'] ?? 'es',
      region: json['region'] ?? 'ES',
      pushNotifications: json['pushNotifications'] ?? true,
      emailNotifications: json['emailNotifications'] ?? true,
      smsNotifications: json['smsNotifications'] ?? false,
      notificationSound: json['notificationSound'] ?? true,
      notificationVibration: json['notificationVibration'] ?? true,
      analyticsEnabled: json['analyticsEnabled'] ?? true,
      crashReportingEnabled: json['crashReportingEnabled'] ?? true,
      dataSharingEnabled: json['dataSharingEnabled'] ?? false,
      biometricEnabled: json['biometricEnabled'] ?? false,
      autoBackup: json['autoBackup'] ?? true,
      backupFrequency: json['backupFrequency'] ?? 7,
      autoSync: json['autoSync'] ?? true,
      syncFrequency: json['syncFrequency'] ?? 30,
      dataSaverMode: json['dataSaverMode'] ?? false,
      accessibilityMode: json['accessibilityMode'] ?? false,
      activeProjectId: json['activeProjectId'],
      showProjectStats: json['showProjectStats'] ?? true,
      autoSwitchProject: json['autoSwitchProject'] ?? false,
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,
      sessionTimeoutEnabled: json['sessionTimeoutEnabled'] ?? true,
      sessionTimeoutMinutes: json['sessionTimeoutMinutes'] ?? 30,
    );
  }
}

/// Configuración específica de un proyecto
class ProjectSettings {
  final String projectId;
  String displayName;
  bool notificationsEnabled;
  bool autoSyncEnabled;
  int syncFrequency;
  Map<String, dynamic> customSettings;

  ProjectSettings({
    required this.projectId,
    required this.displayName,
    this.notificationsEnabled = true,
    this.autoSyncEnabled = true,
    this.syncFrequency = 30,
    this.customSettings = const {},
  });

  ProjectSettings copyWith({
    String? displayName,
    bool? notificationsEnabled,
    bool? autoSyncEnabled,
    int? syncFrequency,
    Map<String, dynamic>? customSettings,
  }) {
    return ProjectSettings(
      projectId: projectId,
      displayName: displayName ?? this.displayName,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      syncFrequency: syncFrequency ?? this.syncFrequency,
      customSettings: customSettings ?? this.customSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'displayName': displayName,
      'notificationsEnabled': notificationsEnabled,
      'autoSyncEnabled': autoSyncEnabled,
      'syncFrequency': syncFrequency,
      'customSettings': customSettings,
    };
  }

  factory ProjectSettings.fromJson(Map<String, dynamic> json) {
    return ProjectSettings(
      projectId: json['projectId'],
      displayName: json['displayName'] ?? '',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      autoSyncEnabled: json['autoSyncEnabled'] ?? true,
      syncFrequency: json['syncFrequency'] ?? 30,
      customSettings: json['customSettings'] ?? {},
    );
  }
}

/// Información de sesión activa
class ActiveSession {
  final String sessionId;
  final String deviceName;
  final String deviceType;
  final String location;
  final DateTime loginTime;
  final DateTime? lastActivity;
  final bool isCurrentSession;

  ActiveSession({
    required this.sessionId,
    required this.deviceName,
    required this.deviceType,
    required this.location,
    required this.loginTime,
    this.lastActivity,
    this.isCurrentSession = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'location': location,
      'loginTime': loginTime.toIso8601String(),
      'lastActivity': lastActivity?.toIso8601String(),
      'isCurrentSession': isCurrentSession,
    };
  }

  factory ActiveSession.fromJson(Map<String, dynamic> json) {
    return ActiveSession(
      sessionId: json['sessionId'],
      deviceName: json['deviceName'],
      deviceType: json['deviceType'],
      location: json['location'],
      loginTime: DateTime.parse(json['loginTime']),
      lastActivity: json['lastActivity'] != null ? DateTime.parse(json['lastActivity']) : null,
      isCurrentSession: json['isCurrentSession'] ?? false,
    );
  }
}

/// Estadísticas de uso por proyecto
class ProjectUsageStats {
  final String projectId;
  final int totalSales;
  final double totalRevenue;
  final int totalProducts;
  final int totalCustomers;
  final DateTime lastActivity;
  final Map<String, int> usageByDay; // día -> cantidad de acciones
  final Map<String, double> revenueByMonth; // mes -> ingresos

  ProjectUsageStats({
    required this.projectId,
    this.totalSales = 0,
    this.totalRevenue = 0.0,
    this.totalProducts = 0,
    this.totalCustomers = 0,
    required this.lastActivity,
    this.usageByDay = const {},
    this.revenueByMonth = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'totalSales': totalSales,
      'totalRevenue': totalRevenue,
      'totalProducts': totalProducts,
      'totalCustomers': totalCustomers,
      'lastActivity': lastActivity.toIso8601String(),
      'usageByDay': usageByDay,
      'revenueByMonth': revenueByMonth,
    };
  }

  factory ProjectUsageStats.fromJson(Map<String, dynamic> json) {
    return ProjectUsageStats(
      projectId: json['projectId'],
      totalSales: json['totalSales'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0.0).toDouble(),
      totalProducts: json['totalProducts'] ?? 0,
      totalCustomers: json['totalCustomers'] ?? 0,
      lastActivity: DateTime.parse(json['lastActivity']),
      usageByDay: Map<String, int>.from(json['usageByDay'] ?? {}),
      revenueByMonth: Map<String, double>.from(json['revenueByMonth'] ?? {}),
    );
  }
}