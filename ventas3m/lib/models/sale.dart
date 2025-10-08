import 'sale_status.dart';
import 'payment_method.dart';

class Sale {
  final String id;
  final String projectId;
  final String productId;
  final String? stockId; // Nuevo campo para identificar el stock específico usado
  final String? customerId;
  final String sellerId;
  final double unitPrice;
  final DateTime saleDate;
  final String customerName;
  final double totalAmount;
  final int quantity;
  final double profit;
  final double? debt;
  final PaymentMethod paymentMethod;
  final SaleStatus status;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  Sale({
    required this.id,
    required this.projectId,
    required this.productId,
    this.stockId,
    this.customerId,
    required this.sellerId,
    required this.unitPrice,
    required this.saleDate,
    required this.customerName,
    required this.totalAmount,
    required this.quantity,
    required this.profit,
    this.debt,
    required this.paymentMethod,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory Sale.create({
    required String projectId,
    required String productId,
    String? stockId,
    String? customerId,
    required String sellerId,
    required double unitPrice,
    required String customerName,
    required int quantity,
    required double profit,
    double? debt,
    required PaymentMethod paymentMethod,
    String notes = '',
    String? createdBy,
  }) {
    final now = DateTime.now();
    final totalAmount = unitPrice * quantity;

    return Sale(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      projectId: projectId,
      productId: productId,
      stockId: stockId,
      customerId: customerId,
      sellerId: sellerId,
      unitPrice: unitPrice,
      saleDate: now,
      customerName: customerName,
      totalAmount: totalAmount,
      quantity: quantity,
      profit: profit,
      debt: debt,
      paymentMethod: paymentMethod,
      status: SaleStatus.completed,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy ?? sellerId,
    );
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      projectId: map['projectId'] ?? '',
      productId: map['productId'] ?? map['product'] ?? '',
      stockId: map['stockId'],
      customerId: map['customerId'],
      sellerId: map['sellerId'] ?? '',
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
      saleDate: map['saleDate'] != null
          ? DateTime.parse(map['saleDate'])
          : map['date'] != null
              ? DateTime.parse(map['date'])
              : DateTime.now(),
      customerName: map['customerName'] ?? map['customer'] ?? '',
      totalAmount: (map['totalAmount'] ?? map['total'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      profit: (map['profit'] ?? 0).toDouble(),
      debt: map['debt']?.toDouble(),
      paymentMethod: map['paymentMethod'] != null
          ? PaymentMethod.values.firstWhere(
              (e) => e.toString() == 'PaymentMethod.${map['paymentMethod']}',
              orElse: () => PaymentMethod.cash,
            )
          : PaymentMethod.cash,
      status: map['status'] != null
          ? SaleStatus.values.firstWhere(
              (e) => e.toString() == 'SaleStatus.${map['status']}',
              orElse: () => SaleStatus.completed,
            )
          : SaleStatus.completed,
      notes: map['notes'] ?? '',
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
      'projectId': projectId,
      'productId': productId,
      'stockId': stockId,
      'customerId': customerId,
      'sellerId': sellerId,
      'unitPrice': unitPrice,
      'saleDate': saleDate.toIso8601String(),
      'customerName': customerName,
      'totalAmount': totalAmount,
      'quantity': quantity,
      'profit': profit,
      'debt': debt,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'status': status.toString().split('.').last,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  Sale copyWith({
    String? id,
    String? projectId,
    String? productId,
    String? stockId,
    String? customerId,
    String? sellerId,
    double? unitPrice,
    DateTime? saleDate,
    String? customerName,
    double? totalAmount,
    int? quantity,
    double? profit,
    double? debt,
    PaymentMethod? paymentMethod,
    SaleStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Sale(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      productId: productId ?? this.productId,
      stockId: stockId ?? this.stockId,
      customerId: customerId ?? this.customerId,
      sellerId: sellerId ?? this.sellerId,
      unitPrice: unitPrice ?? this.unitPrice,
      saleDate: saleDate ?? this.saleDate,
      customerName: customerName ?? this.customerName,
      totalAmount: totalAmount ?? this.totalAmount,
      quantity: quantity ?? this.quantity,
      profit: profit ?? this.profit,
      debt: debt ?? this.debt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  bool get isPending => status == SaleStatus.pending;
  bool get isCompleted => status == SaleStatus.completed;
  bool get isCancelled => status == SaleStatus.cancelled;
  bool get isRefunded => status == SaleStatus.refunded;
  bool get hasDebt => debt != null && debt! > 0;
  bool get isPaid => !hasDebt || paymentMethod != PaymentMethod.debt;

  @override
  String toString() {
    return 'Sale(id: $id, productId: $productId, customerName: $customerName, totalAmount: $totalAmount, status: ${status.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Sale && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}