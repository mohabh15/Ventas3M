import 'product.dart';

/// Elemento del carrito de ventas
class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final double unitPrice;
  final double? discount;
  final String? notes;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    this.discount,
    this.notes,
    required this.addedAt,
  });

  /// Crea una copia del elemento con propiedades modificadas
  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    double? unitPrice,
    double? discount,
    String? notes,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
      notes: notes ?? this.notes,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  /// Calcula el subtotal del elemento (precio * cantidad - descuento)
  double get subtotal {
    final baseTotal = unitPrice * quantity;
    final discountAmount = discount ?? 0.0;
    return baseTotal - discountAmount;
  }

  /// Calcula el precio unitario efectivo después del descuento
  double get effectiveUnitPrice {
    if (discount == null || discount == 0) {
      return unitPrice;
    }
    return unitPrice - (discount! / quantity);
  }

  /// Verifica si el elemento tiene descuento aplicado
  bool get hasDiscount => discount != null && discount! > 0;

  /// Calcula el porcentaje de descuento aplicado
  double get discountPercentage {
    if (!hasDiscount) return 0.0;
    return (discount! / (unitPrice * quantity)) * 100;
  }

  /// Convierte el elemento a un mapa para almacenamiento
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product.toMap(),
      'quantity': quantity,
      'unitPrice': unitPrice,
      'discount': discount,
      'notes': notes,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  /// Crea un elemento desde un mapa
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      product: Product.fromMap(Map<String, dynamic>.from(map['product'] ?? {})),
      quantity: (map['quantity'] ?? 1).toInt(),
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
      discount: map['discount']?.toDouble(),
      notes: map['notes'],
      addedAt: DateTime.parse(map['addedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  String toString() {
    return 'CartItem(id: $id, product: ${product.name}, quantity: $quantity, subtotal: $subtotal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Estado del carrito de ventas
enum CartStatus {
  active('Activo'),
  completed('Completado'),
  cancelled('Cancelado'),
  saved('Guardado');

  const CartStatus(this.displayName);
  final String displayName;
}