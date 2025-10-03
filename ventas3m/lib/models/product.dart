class Product {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String projectId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.projectId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      basePrice: (json['basePrice'] as num).toDouble(),
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      projectId: json['projectId'] as String,
    );
  }

  // Factory para crear desde datos del formulario (sin projectId)
  factory Product.fromFormData(Map<String, dynamic> formData) {
    return Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: formData['name'] as String,
      description: formData['description'] as String,
      basePrice: (formData['basePrice'] as num).toDouble(),
      category: formData['category'] as String,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      projectId: '', // Se establecerá después con el proyecto actual
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'projectId': projectId,
    };
  }
}

class ProductStock {
  final String id;
  final String productId;
  final int quantity;
  final String responsibleId;
  final String providerId;
  final double price;
  final DateTime purchaseDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String projectId;

  ProductStock({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.responsibleId,
    required this.providerId,
    required this.price,
    required this.purchaseDate,
    required this.createdAt,
    required this.updatedAt,
    required this.projectId,
  });

  factory ProductStock.fromJson(Map<String, dynamic> json) {
    return ProductStock(
      id: json['id'] as String,
      productId: json['productId'] as String,
      quantity: json['quantity'] as int,
      responsibleId: json['responsibleId'] as String,
      providerId: json['providerId'] as String,
      price: (json['price'] as num).toDouble(),
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      projectId: json['projectId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'quantity': quantity,
      'responsibleId': responsibleId,
      'providerId': providerId,
      'price': price,
      'purchaseDate': purchaseDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'projectId': projectId,
    };
  }
}