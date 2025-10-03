class Sale {
  final String id;
  final String product;
  final int quantity;
  final double unitPrice;
  final double total;
  final String customer;
  final DateTime date;

  Sale({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.customer,
    required this.date,
  });

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      product: map['product'],
      quantity: map['quantity'],
      unitPrice: map['unitPrice'],
      total: map['total'],
      customer: map['customer'],
      date: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'total': total,
      'customer': customer,
      'date': date.toIso8601String(),
    };
  }
}