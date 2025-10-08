enum PaymentMethod {
  cash,
  card,
  transfer,
  debt,
  check,
  digitalWallet,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Efectivo';
      case PaymentMethod.card:
        return 'Tarjeta';
      case PaymentMethod.transfer:
        return 'Transferencia';
      case PaymentMethod.debt:
        return 'Deuda';
      case PaymentMethod.check:
        return 'Cheque';
      case PaymentMethod.digitalWallet:
        return 'Billetera Digital';
    }
  }

  String get description {
    switch (this) {
      case PaymentMethod.cash:
        return 'Pago en efectivo';
      case PaymentMethod.card:
        return 'Pago con tarjeta de crédito/débito';
      case PaymentMethod.transfer:
        return 'Transferencia bancaria';
      case PaymentMethod.debt:
        return 'Compra a crédito (genera deuda)';
      case PaymentMethod.check:
        return 'Pago con cheque';
      case PaymentMethod.digitalWallet:
        return 'Pago con billetera digital';
    }
  }
}