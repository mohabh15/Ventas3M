import 'package:flutter/material.dart';

/// Modelo de producto para la aplicación de ventas
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final int stockCount;
  final List<String> tags;
  final String barcode;
  final String sku;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    required this.category,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.inStock = true,
    this.stockCount = 0,
    this.tags = const [],
    required this.barcode,
    required this.sku,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una copia del producto con propiedades modificadas
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    String? imageUrl,
    String? category,
    double? rating,
    int? reviewCount,
    bool? inStock,
    int? stockCount,
    List<String>? tags,
    String? barcode,
    String? sku,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      inStock: inStock ?? this.inStock,
      stockCount: stockCount ?? this.stockCount,
      tags: tags ?? this.tags,
      barcode: barcode ?? this.barcode,
      sku: sku ?? this.sku,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte el producto a un mapa para almacenamiento
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'inStock': inStock,
      'stockCount': stockCount,
      'tags': tags,
      'barcode': barcode,
      'sku': sku,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Crea un producto desde un mapa
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      originalPrice: map['originalPrice']?.toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: (map['reviewCount'] ?? 0).toInt(),
      inStock: map['inStock'] ?? true,
      stockCount: (map['stockCount'] ?? 0).toInt(),
      tags: List<String>.from(map['tags'] ?? []),
      barcode: map['barcode'] ?? '',
      sku: map['sku'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Categorías de productos disponibles
enum ProductCategory {
  electronics('Electrónicos', Icons.electrical_services, Color(0xFF2196F3)),
  clothing('Ropa', Icons.checkroom, Color(0xFFE91E63)),
  food('Alimentos', Icons.restaurant, Color(0xFF4CAF50)),
  books('Libros', Icons.menu_book, Color(0xFF9C27B0)),
  home('Hogar', Icons.home, Color(0xFFFF9800)),
  sports('Deportes', Icons.sports_soccer, Color(0xFFF44336)),
  beauty('Belleza', Icons.face, Color(0xFFE91E63)),
  toys('Juguetes', Icons.toys, Color(0xFFFF5722)),
  automotive('Automotriz', Icons.directions_car, Color(0xFF607D8B)),
  other('Otros', Icons.category, Color(0xFF9E9E9E));

  const ProductCategory(this.displayName, this.icon, this.color);
  final String displayName;
  final IconData icon;
  final Color color;
}

/// Modelo para categorías personalizadas
class ProductCategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int productCount;
  final DateTime createdAt;

  const ProductCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.productCount = 0,
    required this.createdAt,
  });

  ProductCategoryModel copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    int? productCount,
    DateTime? createdAt,
  }) {
    return ProductCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      productCount: productCount ?? this.productCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'color': color.toARGB32(),
      'productCount': productCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProductCategoryModel.fromMap(Map<String, dynamic> map) {
    return ProductCategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: IconData(map['icon'] ?? Icons.category.codePoint, fontFamily: 'MaterialIcons'),
      color: Color(map['color'] ?? Colors.grey.toARGB32()),
      productCount: (map['productCount'] ?? 0).toInt(),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Estados de disponibilidad del producto
enum ProductAvailability {
  inStock('En Stock'),
  lowStock('Stock Bajo'),
  outOfStock('Agotado'),
  discontinued('Descontinuado');

  const ProductAvailability(this.displayName);
  final String displayName;
}