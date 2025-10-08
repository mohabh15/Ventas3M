import '../models/sale.dart';
import '../models/payment_method.dart';

class SaleValidationError {
  final String field;
  final String message;

  const SaleValidationError(this.field, this.message);

  @override
  String toString() => '$field: $message';
}

class SaleValidationResult {
  final bool isValid;
  final List<SaleValidationError> errors;

  const SaleValidationResult({
    required this.isValid,
    required this.errors,
  });

  factory SaleValidationResult.success() {
    return const SaleValidationResult(isValid: true, errors: []);
  }

  factory SaleValidationResult.failure(List<SaleValidationError> errors) {
    return SaleValidationResult(isValid: false, errors: errors);
  }
}

class SaleValidationService {
  static const double _minUnitPrice = 0.01;
  static const double _maxUnitPrice = 999999.99;
  static const int _minQuantity = 1;
  static const int _maxQuantity = 99999;

  SaleValidationResult validateSale(Sale sale) {
    final errors = <SaleValidationError>[];

    // Validar campos requeridos
    errors.addAll(_validateRequiredFields(sale));

    // Validar formatos y rangos
    errors.addAll(_validateFormatsAndRanges(sale));

    // Validar lógica de negocio
    errors.addAll(_validateBusinessLogic(sale));

    return errors.isEmpty
        ? SaleValidationResult.success()
        : SaleValidationResult.failure(errors);
  }

  List<SaleValidationError> _validateRequiredFields(Sale sale) {
    final errors = <SaleValidationError>[];

    if (sale.id.isEmpty) {
      errors.add(const SaleValidationError('id', 'ID es requerido'));
    }

    if (sale.projectId.isEmpty) {
      errors.add(const SaleValidationError('projectId', 'ID de proyecto es requerido'));
    }

    if (sale.productId.isEmpty) {
      errors.add(const SaleValidationError('productId', 'ID de producto es requerido'));
    }

    if (sale.sellerId.isEmpty) {
      errors.add(const SaleValidationError('sellerId', 'ID de vendedor es requerido'));
    }

    if (sale.customerName.isEmpty) {
      errors.add(const SaleValidationError('customerName', 'Nombre del cliente es requerido'));
    }

    if (sale.createdBy.isEmpty) {
      errors.add(const SaleValidationError('createdBy', 'Usuario creador es requerido'));
    }

    return errors;
  }

  List<SaleValidationError> _validateFormatsAndRanges(Sale sale) {
    final errors = <SaleValidationError>[];

    // Validar precio unitario
    if (sale.unitPrice < _minUnitPrice) {
      errors.add(SaleValidationError(
        'unitPrice',
        'Precio unitario debe ser mayor a $_minUnitPrice',
      ));
    }

    if (sale.unitPrice > _maxUnitPrice) {
      errors.add(SaleValidationError(
        'unitPrice',
        'Precio unitario no puede ser mayor a $_maxUnitPrice',
      ));
    }

    // Validar cantidad
    if (sale.quantity < _minQuantity) {
      errors.add(SaleValidationError(
        'quantity',
        'Cantidad debe ser al menos $_minQuantity',
      ));
    }

    if (sale.quantity > _maxQuantity) {
      errors.add(SaleValidationError(
        'quantity',
        'Cantidad no puede ser mayor a $_maxQuantity',
      ));
    }

    // Validar monto total
    final expectedTotal = sale.unitPrice * sale.quantity;
    if ((sale.totalAmount - expectedTotal).abs() > 0.01) {
      errors.add(const SaleValidationError(
        'totalAmount',
        'Monto total no coincide con precio unitario × cantidad',
      ));
    }

    // Validar fechas
    if (sale.saleDate.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      errors.add(const SaleValidationError(
        'saleDate',
        'Fecha de venta no puede ser futura',
      ));
    }

    if (sale.saleDate.isBefore(DateTime(2020))) {
      errors.add(const SaleValidationError(
        'saleDate',
        'Fecha de venta no puede ser anterior a 2020',
      ));
    }

    // Validar deuda
    if (sale.debt != null && sale.debt! < 0) {
      errors.add(const SaleValidationError(
        'debt',
        'Deuda no puede ser negativa',
      ));
    }

    if (sale.debt != null && sale.debt! > sale.totalAmount) {
      errors.add(const SaleValidationError(
        'debt',
        'Deuda no puede ser mayor al monto total',
      ));
    }

    // Validar notas
    if (sale.notes.length > 500) {
      errors.add(const SaleValidationError(
        'notes',
        'Notas no pueden exceder 500 caracteres',
      ));
    }

    return errors;
  }

  List<SaleValidationError> _validateBusinessLogic(Sale sale) {
    final errors = <SaleValidationError>[];

    // Validar que si hay deuda, el método de pago debe ser debt
    if (sale.hasDebt && sale.paymentMethod != PaymentMethod.debt) {
      errors.add(const SaleValidationError(
        'paymentMethod',
        'Si hay deuda, el método de pago debe ser "deuda"',
      ));
    }

    // Validar que si no hay deuda, el método de pago no debe ser debt
    if (!sale.hasDebt && sale.paymentMethod == PaymentMethod.debt) {
      errors.add(const SaleValidationError(
        'paymentMethod',
        'Método de pago "deuda" requiere que exista deuda',
      ));
    }

    // Validar beneficio
    if (sale.profit < 0 && !sale.hasDebt) {
      errors.add(const SaleValidationError(
        'profit',
        'No se puede vender con pérdida sin generar deuda',
      ));
    }

    // Validar estado de venta completada
    if (sale.isCompleted && sale.hasDebt && sale.debt! > 0) {
      errors.add(const SaleValidationError(
        'status',
        'Venta completada no puede tener deuda pendiente',
      ));
    }

    return errors;
  }

  SaleValidationResult validateSaleCreation({
    required String projectId,
    required String productId,
    required String sellerId,
    required double unitPrice,
    required String customerName,
    required int quantity,
    required double profit,
    double? debt,
    required PaymentMethod paymentMethod,
    String notes = '',
  }) {
    final errors = <SaleValidationError>[];

    // Validar campos requeridos
    if (projectId.isEmpty) {
      errors.add(const SaleValidationError('projectId', 'ID de proyecto es requerido'));
    }

    if (productId.isEmpty) {
      errors.add(const SaleValidationError('productId', 'ID de producto es requerido'));
    }

    if (sellerId.isEmpty) {
      errors.add(const SaleValidationError('sellerId', 'ID de vendedor es requerido'));
    }

    if (customerName.isEmpty) {
      errors.add(const SaleValidationError('customerName', 'Nombre del cliente es requerido'));
    }

    // Validar valores numéricos
    if (unitPrice <= 0) {
      errors.add(const SaleValidationError('unitPrice', 'Precio unitario debe ser mayor a cero'));
    }

    if (quantity <= 0) {
      errors.add(const SaleValidationError('quantity', 'Cantidad debe ser mayor a cero'));
    }

    if (profit < 0 && (debt == null || debt <= 0)) {
      errors.add(const SaleValidationError(
        'profit',
        'No se puede vender con pérdida sin especificar deuda',
      ));
    }

    return errors.isEmpty
        ? SaleValidationResult.success()
        : SaleValidationResult.failure(errors);
  }

  bool isValidCustomerName(String customerName) {
    return customerName.trim().length >= 2 && customerName.trim().length <= 100;
  }

  bool isValidUnitPrice(double unitPrice) {
    return unitPrice >= _minUnitPrice && unitPrice <= _maxUnitPrice;
  }

  bool isValidQuantity(int quantity) {
    return quantity >= _minQuantity && quantity <= _maxQuantity;
  }

  bool isValidDebt(double? debt, double totalAmount) {
    if (debt == null) return true;
    return debt >= 0 && debt <= totalAmount;
  }

  bool isValidSaleDate(DateTime saleDate) {
    return !saleDate.isAfter(DateTime.now().add(const Duration(days: 1))) &&
           !saleDate.isBefore(DateTime(2020));
  }
}