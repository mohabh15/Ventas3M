class TeamMemberBalance {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String? photoUrl;
  final double balance;
  final String role;
  final DateTime lastUpdated;
  final String projectId;

  TeamMemberBalance({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.balance,
    required this.role,
    required this.lastUpdated,
    required this.projectId,
  });

  factory TeamMemberBalance.fromJson(Map<String, dynamic> json) {
    return TeamMemberBalance(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      balance: (json['balance'] ?? 0).toDouble(),
      role: json['role'] ?? '',
      lastUpdated: json['lastUpdated']?.toDate() ?? DateTime.now(),
      projectId: json['projectId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'balance': balance,
      'role': role,
      'lastUpdated': lastUpdated,
      'projectId': projectId,
    };
  }

  TeamMemberBalance copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? photoUrl,
    double? balance,
    String? role,
    DateTime? lastUpdated,
    String? projectId,
  }) {
    return TeamMemberBalance(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      balance: balance ?? this.balance,
      role: role ?? this.role,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      projectId: projectId ?? this.projectId,
    );
  }

  @override
  String toString() {
    return 'TeamMemberBalance(id: $id, name: $name, balance: $balance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamMemberBalance && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}