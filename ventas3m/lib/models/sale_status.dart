enum SaleStatus {
  pending,
  completed,
  cancelled,
  refunded,
}

extension SaleStatusExtension on SaleStatus {
  String get displayName {
    switch (this) {
      case SaleStatus.pending:
        return 'Pendiente';
      case SaleStatus.completed:
        return 'Completada';
      case SaleStatus.cancelled:
        return 'Cancelada';
      case SaleStatus.refunded:
        return 'Devuelta';
    }
  }

  String get description {
    switch (this) {
      case SaleStatus.pending:
        return 'Venta pendiente de completar';
      case SaleStatus.completed:
        return 'Venta completada exitosamente';
      case SaleStatus.cancelled:
        return 'Venta cancelada';
      case SaleStatus.refunded:
        return 'Venta devuelta al cliente';
    }
  }
}