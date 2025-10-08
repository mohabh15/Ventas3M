enum DebtStatus {
  pending('Pendiente'),
  paid('Pagada'),
  cancelled('Cancelada'),
  overdue('Vencida');

  const DebtStatus(this.displayName);

  final String displayName;

  static DebtStatus fromString(String value) {
    return DebtStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => DebtStatus.pending,
    );
  }
}

enum DebtType {
  aPagar('A Pagar'),
  aCobrar('A Cobrar');

  const DebtType(this.displayName);

  final String displayName;

  static DebtType fromString(String value) {
    return DebtType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => DebtType.aPagar,
    );
  }
}

class Debt {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final String debtor;
  final DebtType debtType;
  final DebtStatus status;
  final String? relatedTransactionId;
  final String projectId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  Debt({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.debtor,
    required this.debtType,
    required this.status,
    this.relatedTransactionId,
    required this.projectId,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  }) {
    if (amount <= 0) {
      throw ArgumentError('El monto de la deuda debe ser mayor a cero');
    }
    if (description.trim().isEmpty) {
      throw ArgumentError('La descripción de la deuda no puede estar vacía');
    }
    if (debtor.trim().isEmpty) {
      throw ArgumentError('El deudor no puede estar vacío');
    }
  }

  factory Debt.create({
    required double amount,
    required String description,
    required DateTime date,
    required String debtor,
    required DebtType debtType,
    String? relatedTransactionId,
    required String projectId,
    required String createdBy,
  }) {
    final now = DateTime.now();

    return Debt(
      id: now.millisecondsSinceEpoch.toString(),
      amount: amount,
      description: description,
      date: date,
      debtor: debtor,
      debtType: debtType,
      status: DebtStatus.pending,
      relatedTransactionId: relatedTransactionId,
      projectId: projectId,
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy,
    );
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      amount: (map['amount'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      date: map['date'] != null
          ? DateTime.parse(map['date'])
          : DateTime.now(),
      debtor: map['debtor'] ?? '',
      debtType: map['debtType'] != null
          ? DebtType.fromString(map['debtType'])
          : DebtType.aPagar,
      status: map['status'] != null
          ? DebtStatus.fromString(map['status'])
          : DebtStatus.pending,
      relatedTransactionId: map['relatedTransactionId'],
      projectId: map['projectId'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'debtor': debtor,
      'debtType': debtType.name,
      'status': status.name,
      'relatedTransactionId': relatedTransactionId,
      'projectId': projectId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  Debt copyWith({
    String? id,
    double? amount,
    String? description,
    DateTime? date,
    String? debtor,
    DebtType? debtType,
    DebtStatus? status,
    String? relatedTransactionId,
    String? projectId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Debt(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      debtor: debtor ?? this.debtor,
      debtType: debtType ?? this.debtType,
      status: status ?? this.status,
      relatedTransactionId: relatedTransactionId ?? this.relatedTransactionId,
      projectId: projectId ?? this.projectId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  bool get isPending => status == DebtStatus.pending;
  bool get isPaid => status == DebtStatus.paid;
  bool get isCancelled => status == DebtStatus.cancelled;
  bool get isOverdue => status == DebtStatus.overdue;
  bool get hasRelatedTransaction => relatedTransactionId != null && relatedTransactionId!.isNotEmpty;

  bool get isToPay => debtType == DebtType.aPagar;
  bool get isToCollect => debtType == DebtType.aCobrar;

  String get creditor => isToPay ? 'Proyecto' : debtor;
  String get effectiveDebtor => isToPay ? debtor : 'Proyecto';

  @override
  String toString() {
    return 'Debt(id: $id, description: $description, amount: $amount, debtor: $debtor, debtType: ${debtType.displayName}, status: ${status.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Debt && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}