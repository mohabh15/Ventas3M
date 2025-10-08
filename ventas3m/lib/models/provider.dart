class Provider {
  final String id;
  final String name;
  final String contactEmail;
  final String phone;
  final String address;
  final String projectId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Provider({
    required this.id,
    required this.name,
    required this.contactEmail,
    required this.phone,
    required this.address,
    required this.projectId,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['id'] as String,
      name: json['name'] as String,
      contactEmail: json['contactEmail'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      projectId: json['projectId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contactEmail': contactEmail,
      'phone': phone,
      'address': address,
      'projectId': projectId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  Provider copyWith({
    String? id,
    String? name,
    String? contactEmail,
    String? phone,
    String? address,
    String? projectId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Provider(
      id: id ?? this.id,
      name: name ?? this.name,
      contactEmail: contactEmail ?? this.contactEmail,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      projectId: projectId ?? this.projectId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}