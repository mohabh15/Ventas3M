import 'cart_item.dart';

/// Modelo de venta completa
class Sale {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final PaymentMethod paymentMethod;
  final Customer? customer;
  final String? notes;
  final SaleStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? invoiceNumber;

  Sale({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    this.customer,
    this.notes,
    this.status = SaleStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.invoiceNumber,
  });

  /// Crea una copia de la venta con propiedades modificadas
  Sale copyWith({
    String? id,
    List<CartItem>? items,
    double? subtotal,
    double? tax,
    double? discount,
    double? total,
    PaymentMethod? paymentMethod,
    Customer? customer,
    String? notes,
    SaleStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? invoiceNumber,
  }) {
    return Sale(
      id: id ?? this.id,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      customer: customer ?? this.customer,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
    );
  }

  /// Calcula el número total de artículos en la venta
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Verifica si la venta tiene descuento aplicado
  bool get hasDiscount => discount > 0;

  /// Calcula el porcentaje de descuento aplicado
  double get discountPercentage {
    if (subtotal == 0) return 0.0;
    return (discount / subtotal) * 100;
  }

  /// Verifica si la venta incluye información del cliente
  bool get hasCustomer => customer != null;

  /// Convierte la venta a un mapa para almacenamiento
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'paymentMethod': paymentMethod.toMap(),
      'customer': customer?.toMap(),
      'notes': notes,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'invoiceNumber': invoiceNumber,
    };
  }

  /// Crea una venta desde un mapa
  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] ?? '',
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => CartItem.fromMap(Map<String, dynamic>.from(item)))
          .toList() ?? [],
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      tax: (map['tax'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      paymentMethod: PaymentMethod.fromMap(Map<String, dynamic>.from(map['paymentMethod'] ?? {})),
      customer: map['customer'] != null ? Customer.fromMap(Map<String, dynamic>.from(map['customer'])) : null,
      notes: map['notes'],
      status: SaleStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => SaleStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      createdBy: map['createdBy'] ?? '',
      invoiceNumber: map['invoiceNumber'],
    );
  }

  @override
  String toString() {
    return 'Sale(id: $id, total: $total, items: ${items.length}, status: ${status.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Sale && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Estados de la venta
enum SaleStatus {
  pending('Pendiente'),
  processing('Procesando'),
  completed('Completada'),
  cancelled('Cancelada'),
  refunded('Reembolsada');

  const SaleStatus(this.displayName);
  final String displayName;
}

/// Información del cliente
class Customer {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? documentNumber;
  final CustomerType type;

  const Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.documentNumber,
    this.type = CustomerType.individual,
  });

  /// Crea una copia del cliente con propiedades modificadas
  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? documentNumber,
    CustomerType? type,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      documentNumber: documentNumber ?? this.documentNumber,
      type: type ?? this.type,
    );
  }

  /// Convierte el cliente a un mapa para almacenamiento
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'documentNumber': documentNumber,
      'type': type.name,
    };
  }

  /// Crea un cliente desde un mapa
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'],
      phone: map['phone'],
      address: map['address'],
      documentNumber: map['documentNumber'],
      type: CustomerType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => CustomerType.individual,
      ),
    );
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, type: ${type.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Tipos de cliente
enum CustomerType {
  individual('Individual'),
  business('Empresa');

  const CustomerType(this.displayName);
  final String displayName;
}

/// Métodos de pago disponibles
enum PaymentMethodType {
  cash('Efectivo'),
  card('Tarjeta'),
  transfer('Transferencia'),
  check('Cheque'),
  credit('Crédito');

  const PaymentMethodType(this.displayName);
  final String displayName;
}

/// Información del método de pago
class PaymentMethod {
  final PaymentMethodType type;
  final String? reference;
  final String? cardLastDigits;
  final String? authorizationCode;

  const PaymentMethod({
    required this.type,
    this.reference,
    this.cardLastDigits,
    this.authorizationCode,
  });

  /// Crea una copia del método de pago con propiedades modificadas
  PaymentMethod copyWith({
    PaymentMethodType? type,
    String? reference,
    String? cardLastDigits,
    String? authorizationCode,
  }) {
    return PaymentMethod(
      type: type ?? this.type,
      reference: reference ?? this.reference,
      cardLastDigits: cardLastDigits ?? this.cardLastDigits,
      authorizationCode: authorizationCode ?? this.authorizationCode,
    );
  }

  /// Convierte el método de pago a un mapa para almacenamiento
  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'reference': reference,
      'cardLastDigits': cardLastDigits,
      'authorizationCode': authorizationCode,
    };
  }

  /// Crea un método de pago desde un mapa
  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      type: PaymentMethodType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => PaymentMethodType.cash,
      ),
      reference: map['reference'],
      cardLastDigits: map['cardLastDigits'],
      authorizationCode: map['authorizationCode'],
    );
  }

  @override
  String toString() {
    return 'PaymentMethod(type: ${type.displayName}, reference: $reference)';
  }
}