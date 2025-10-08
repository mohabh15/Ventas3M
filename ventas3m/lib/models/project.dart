import 'provider.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final List<String> members;
  final List<Provider> providers;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.members,
    required this.providers,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      ownerId: json['ownerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool,
      members: List<String>.from(json['members'] as List<dynamic>? ?? []),
      providers: (json['providers'] as List<dynamic>? ?? [])
          .map((providerJson) => Provider.fromJson(providerJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'members': members,
      'providers': providers.map((provider) => provider.toJson()).toList(),
    };
  }
}