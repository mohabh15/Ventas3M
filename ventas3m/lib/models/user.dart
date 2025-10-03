class User {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;
  final Map<String, dynamic>? metadata;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.phone,
    this.createdAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
    this.metadata,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      phone: json['phone'],
      createdAt: json['createdAt']?.toDate(),
      lastLoginAt: json['lastLoginAt']?.toDate(),
      isEmailVerified: json['isEmailVerified'] ?? false,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'phone': phone,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
      'isEmailVerified': isEmailVerified,
      'metadata': metadata,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? phone,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Información detallada del perfil de usuario
class UserProfile {
  final String userId;
  String firstName;
  String lastName;
  String displayName;
  String email;
  String? phone;
  String? photoUrl;
  String? bio;
  String? location;
  String? website;
  DateTime? birthDate;
  String gender;
  String preferredLanguage;
  Map<String, dynamic> socialLinks;
  Map<String, dynamic> preferences;

  UserProfile({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.email,
    this.phone,
    this.photoUrl,
    this.bio,
    this.location,
    this.website,
    this.birthDate,
    this.gender = 'not_specified',
    this.preferredLanguage = 'es',
    this.socialLinks = const {},
    this.preferences = const {},
  });

  String get fullName => '$firstName $lastName';

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? displayName,
    String? email,
    String? phone,
    String? photoUrl,
    String? bio,
    String? location,
    String? website,
    DateTime? birthDate,
    String? gender,
    String? preferredLanguage,
    Map<String, dynamic>? socialLinks,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      userId: userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      website: website ?? this.website,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      socialLinks: socialLinks ?? this.socialLinks,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'bio': bio,
      'location': location,
      'website': website,
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender,
      'preferredLanguage': preferredLanguage,
      'socialLinks': socialLinks,
      'preferences': preferences,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      photoUrl: json['photoUrl'],
      bio: json['bio'],
      location: json['location'],
      website: json['website'],
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      gender: json['gender'] ?? 'not_specified',
      preferredLanguage: json['preferredLanguage'] ?? 'es',
      socialLinks: json['socialLinks'] ?? {},
      preferences: json['preferences'] ?? {},
    );
  }
}

/// Configuración de seguridad del usuario
class SecuritySettings {
  final String userId;
  bool twoFactorEnabled;
  String twoFactorMethod; // 'app', 'sms', 'email'
  bool biometricEnabled;
  bool sessionTimeoutEnabled;
  int sessionTimeoutMinutes;
  List<String> trustedDevices;
  List<SecurityEvent> securityEvents;
  DateTime? lastPasswordChange;
  bool passwordChangeRequired;

  SecuritySettings({
    required this.userId,
    this.twoFactorEnabled = false,
    this.twoFactorMethod = 'app',
    this.biometricEnabled = false,
    this.sessionTimeoutEnabled = true,
    this.sessionTimeoutMinutes = 30,
    this.trustedDevices = const [],
    this.securityEvents = const [],
    this.lastPasswordChange,
    this.passwordChangeRequired = false,
  });

  SecuritySettings copyWith({
    bool? twoFactorEnabled,
    String? twoFactorMethod,
    bool? biometricEnabled,
    bool? sessionTimeoutEnabled,
    int? sessionTimeoutMinutes,
    List<String>? trustedDevices,
    List<SecurityEvent>? securityEvents,
    DateTime? lastPasswordChange,
    bool? passwordChangeRequired,
  }) {
    return SecuritySettings(
      userId: userId,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      twoFactorMethod: twoFactorMethod ?? this.twoFactorMethod,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      sessionTimeoutEnabled: sessionTimeoutEnabled ?? this.sessionTimeoutEnabled,
      sessionTimeoutMinutes: sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
      trustedDevices: trustedDevices ?? this.trustedDevices,
      securityEvents: securityEvents ?? this.securityEvents,
      lastPasswordChange: lastPasswordChange ?? this.lastPasswordChange,
      passwordChangeRequired: passwordChangeRequired ?? this.passwordChangeRequired,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'twoFactorEnabled': twoFactorEnabled,
      'twoFactorMethod': twoFactorMethod,
      'biometricEnabled': biometricEnabled,
      'sessionTimeoutEnabled': sessionTimeoutEnabled,
      'sessionTimeoutMinutes': sessionTimeoutMinutes,
      'trustedDevices': trustedDevices,
      'securityEvents': securityEvents.map((e) => e.toJson()).toList(),
      'lastPasswordChange': lastPasswordChange?.toIso8601String(),
      'passwordChangeRequired': passwordChangeRequired,
    };
  }

  factory SecuritySettings.fromJson(Map<String, dynamic> json) {
    return SecuritySettings(
      userId: json['userId'] ?? '',
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,
      twoFactorMethod: json['twoFactorMethod'] ?? 'app',
      biometricEnabled: json['biometricEnabled'] ?? false,
      sessionTimeoutEnabled: json['sessionTimeoutEnabled'] ?? true,
      sessionTimeoutMinutes: json['sessionTimeoutMinutes'] ?? 30,
      trustedDevices: List<String>.from(json['trustedDevices'] ?? []),
      securityEvents: (json['securityEvents'] as List<dynamic>?)
          ?.map((e) => SecurityEvent.fromJson(e))
          .toList() ?? [],
      lastPasswordChange: json['lastPasswordChange'] != null
          ? DateTime.parse(json['lastPasswordChange'])
          : null,
      passwordChangeRequired: json['passwordChangeRequired'] ?? false,
    );
  }
}

/// Evento de seguridad para auditoría
class SecurityEvent {
  final String id;
  final String type; // 'login', 'logout', 'password_change', 'failed_login', etc.
  final String description;
  final DateTime timestamp;
  final String ipAddress;
  final String userAgent;
  final String location;
  final bool success;

  SecurityEvent({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    required this.ipAddress,
    required this.userAgent,
    required this.location,
    this.success = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'location': location,
      'success': success,
    };
  }

  factory SecurityEvent.fromJson(Map<String, dynamic> json) {
    return SecurityEvent(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      ipAddress: json['ipAddress'] ?? '',
      userAgent: json['userAgent'] ?? '',
      location: json['location'] ?? '',
      success: json['success'] ?? true,
    );
  }
}