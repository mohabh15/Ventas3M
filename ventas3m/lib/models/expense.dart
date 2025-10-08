import 'payment_method.dart';
import 'expense_recurrence_type.dart';
import '../services/formatting_service.dart';

class Expense {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String category;
  final String? projectId;
  final String? providerId;
  final PaymentMethod paymentMethod;
  final bool isRecurring;
  final ExpenseRecurrenceType? recurrenceType;
  final String? notes;
  final String? receiptImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    this.projectId,
    this.providerId,
    required this.paymentMethod,
    required this.isRecurring,
    this.recurrenceType,
    this.notes,
    this.receiptImageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  }) {
    // Validaciones básicas
    if (amount < 0) {
      throw ArgumentError('El monto del gasto debe ser positivo');
    }
    if (description.trim().isEmpty) {
      throw ArgumentError('La descripción del gasto no puede estar vacía');
    }
    if (category.trim().isEmpty) {
      throw ArgumentError('La categoría del gasto no puede estar vacía');
    }
    if (isRecurring && recurrenceType == null) {
      throw ArgumentError('Si el gasto es recurrente, debe especificar el tipo de recurrencia');
    }
  }

  factory Expense.create({
    required String description,
    required double amount,
    required DateTime date,
    required String category,
    String? projectId,
    String? providerId,
    required PaymentMethod paymentMethod,
    bool isRecurring = false,
    ExpenseRecurrenceType? recurrenceType,
    String? notes,
    String? receiptImageUrl,
    String? createdBy,
  }) {
    final now = DateTime.now();

    return Expense(
      id: now.millisecondsSinceEpoch.toString(),
      description: description,
      amount: amount,
      date: date,
      category: category,
      projectId: projectId,
      providerId: providerId,
      paymentMethod: paymentMethod,
      isRecurring: isRecurring,
      recurrenceType: recurrenceType,
      notes: notes,
      receiptImageUrl: receiptImageUrl,
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy ?? '',
    );
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: map['date'] != null
          ? DateTime.parse(map['date'])
          : DateTime.now(),
      category: map['category'] ?? '',
      projectId: map['projectId'],
      providerId: map['providerId'],
      paymentMethod: map['paymentMethod'] != null
          ? PaymentMethod.values.firstWhere(
              (e) => e.toString() == 'PaymentMethod.${map['paymentMethod']}',
              orElse: () => PaymentMethod.cash,
            )
          : PaymentMethod.cash,
      isRecurring: map['isRecurring'] ?? false,
      recurrenceType: map['recurrenceType'] != null
          ? ExpenseRecurrenceType.values.firstWhere(
              (e) => e.toString() == 'ExpenseRecurrenceType.${map['recurrenceType']}',
              orElse: () => ExpenseRecurrenceType.monthly,
            )
          : null,
      notes: map['notes'],
      receiptImageUrl: map['receiptImageUrl'],
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
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'projectId': projectId,
      'providerId': providerId,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'isRecurring': isRecurring,
      'recurrenceType': recurrenceType?.toString().split('.').last,
      'notes': notes,
      'receiptImageUrl': receiptImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  Expense copyWith({
    String? id,
    String? description,
    double? amount,
    DateTime? date,
    String? category,
    String? projectId,
    String? providerId,
    PaymentMethod? paymentMethod,
    bool? isRecurring,
    ExpenseRecurrenceType? recurrenceType,
    String? notes,
    String? receiptImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Expense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      projectId: projectId ?? this.projectId,
      providerId: providerId ?? this.providerId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      notes: notes ?? this.notes,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  // Métodos auxiliares para formateo
  String get formattedAmount {
    return FormattingService.formatExpenseAmount(amount);
  }

  String get formattedDate {
    return FormattingService.formatExpenseDate(date);
  }

  String get formattedDateTime {
    return FormattingService.formatExpenseDateTime(date);
  }

  String get formattedCreatedAt {
    return FormattingService.formatExpenseDateTime(createdAt);
  }

  String get formattedUpdatedAt {
    return FormattingService.formatExpenseDateTime(updatedAt);
  }

  // Getters auxiliares
  bool get hasReceipt => receiptImageUrl != null && receiptImageUrl!.isNotEmpty;
  bool get hasProject => projectId != null && projectId!.isNotEmpty;
  bool get hasProvider => providerId != null && providerId!.isNotEmpty;
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  @override
  String toString() {
    return 'Expense(id: $id, description: $description, amount: $formattedAmount, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}