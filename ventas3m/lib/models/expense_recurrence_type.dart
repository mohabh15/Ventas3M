enum ExpenseRecurrenceType {
  daily,
  weekly,
  monthly,
  yearly,
}

extension ExpenseRecurrenceTypeExtension on ExpenseRecurrenceType {
  String get displayName {
    switch (this) {
      case ExpenseRecurrenceType.daily:
        return 'Diario';
      case ExpenseRecurrenceType.weekly:
        return 'Semanal';
      case ExpenseRecurrenceType.monthly:
        return 'Mensual';
      case ExpenseRecurrenceType.yearly:
        return 'Anual';
    }
  }

  String get description {
    switch (this) {
      case ExpenseRecurrenceType.daily:
        return 'Se repite cada día';
      case ExpenseRecurrenceType.weekly:
        return 'Se repite cada semana';
      case ExpenseRecurrenceType.monthly:
        return 'Se repite cada mes';
      case ExpenseRecurrenceType.yearly:
        return 'Se repite cada año';
    }
  }
}