import 'package:flutter/material.dart';

/// Filtros disponibles para productos
enum ProductFilterType {
  category('Categoría'),
  priceRange('Rango de precio'),
  stockStatus('Estado de stock'),
  rating('Calificación'),
  dateRange('Fecha de creación'),
  tags('Etiquetas');

  const ProductFilterType(this.displayName);
  final String displayName;
}

/// Estados de stock de productos
enum StockStatus {
  inStock('En stock', Colors.green),
  lowStock('Stock bajo', Colors.orange),
  outOfStock('Agotado', Colors.red),
  discontinued('Descontinuado', Colors.grey);

  const StockStatus(this.displayName, this.color);
  final String displayName;
  final Color color;
}

/// Modelo para filtros de productos
class ProductFilters {
  final List<String> categories;
  final RangeValues? priceRange;
  final StockStatus? stockStatus;
  final double? minRating;
  final DateTimeRange? dateRange;
  final List<String> tags;
  final String? searchQuery;
  final ProductSortOption sortBy;

  const ProductFilters({
    this.categories = const [],
    this.priceRange,
    this.stockStatus,
    this.minRating,
    this.dateRange,
    this.tags = const [],
    this.searchQuery,
    this.sortBy = ProductSortOption.name,
  });

  ProductFilters copyWith({
    List<String>? categories,
    RangeValues? priceRange,
    StockStatus? stockStatus,
    double? minRating,
    DateTimeRange? dateRange,
    List<String>? tags,
    String? searchQuery,
    ProductSortOption? sortBy,
  }) {
    return ProductFilters(
      categories: categories ?? this.categories,
      priceRange: priceRange ?? this.priceRange,
      stockStatus: stockStatus ?? this.stockStatus,
      minRating: minRating ?? this.minRating,
      dateRange: dateRange ?? this.dateRange,
      tags: tags ?? this.tags,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters {
    return categories.isNotEmpty ||
        priceRange != null ||
        stockStatus != null ||
        minRating != null ||
        dateRange != null ||
        tags.isNotEmpty ||
        (searchQuery?.isNotEmpty ?? false);
  }

  int get activeFilterCount {
    int count = 0;
    if (categories.isNotEmpty) count++;
    if (priceRange != null) count++;
    if (stockStatus != null) count++;
    if (minRating != null) count++;
    if (dateRange != null) count++;
    if (tags.isNotEmpty) count++;
    if (searchQuery?.isNotEmpty ?? false) count++;
    return count;
  }

  void clearFilters() {
    // Devolver filtros vacíos
  }

  Map<String, dynamic> toMap() {
    return {
      'categories': categories,
      'priceRange': priceRange != null ? {
        'start': priceRange!.start,
        'end': priceRange!.end,
      } : null,
      'stockStatus': stockStatus?.name,
      'minRating': minRating,
      'dateRange': dateRange != null ? {
        'start': dateRange!.start.toIso8601String(),
        'end': dateRange!.end.toIso8601String(),
      } : null,
      'tags': tags,
      'searchQuery': searchQuery,
      'sortBy': sortBy.name,
    };
  }

  factory ProductFilters.fromMap(Map<String, dynamic> map) {
    return ProductFilters(
      categories: List<String>.from(map['categories'] ?? []),
      priceRange: map['priceRange'] != null ? RangeValues(
        map['priceRange']['start'],
        map['priceRange']['end'],
      ) : null,
      stockStatus: map['stockStatus'] != null ? StockStatus.values.firstWhere(
        (e) => e.name == map['stockStatus'],
      ) : null,
      minRating: map['minRating']?.toDouble(),
      dateRange: map['dateRange'] != null ? DateTimeRange(
        start: DateTime.parse(map['dateRange']['start']),
        end: DateTime.parse(map['dateRange']['end']),
      ) : null,
      tags: List<String>.from(map['tags'] ?? []),
      searchQuery: map['searchQuery'],
      sortBy: map['sortBy'] != null ? ProductSortOption.values.firstWhere(
        (e) => e.name == map['sortBy'],
      ) : ProductSortOption.name,
    );
  }
}

/// Opciones de ordenamiento
enum ProductSortOption {
  name('Nombre', Icons.sort_by_alpha),
  price('Precio', Icons.attach_money),
  stock('Stock', Icons.inventory),
  rating('Calificación', Icons.star),
  date('Fecha de creación', Icons.calendar_today),
  popularity('Popularidad', Icons.trending_up);

  const ProductSortOption(this.displayName, this.icon);
  final String displayName;
  final IconData icon;
}

/// Vista de productos
enum ProductViewMode {
  grid(Icons.grid_view, 'Cuadrícula'),
  list(Icons.list, 'Lista');

  const ProductViewMode(this.icon, this.displayName);
  final IconData icon;
  final String displayName;
}

/// Estadísticas de productos
class ProductStats {
  final int totalProducts;
  final int inStockProducts;
  final int lowStockProducts;
  final int outOfStockProducts;
  final double averagePrice;
  final double totalValue;
  final Map<String, int> productsByCategory;

  const ProductStats({
    this.totalProducts = 0,
    this.inStockProducts = 0,
    this.lowStockProducts = 0,
    this.outOfStockProducts = 0,
    this.averagePrice = 0.0,
    this.totalValue = 0.0,
    this.productsByCategory = const {},
  });

  ProductStats copyWith({
    int? totalProducts,
    int? inStockProducts,
    int? lowStockProducts,
    int? outOfStockProducts,
    double? averagePrice,
    double? totalValue,
    Map<String, int>? productsByCategory,
  }) {
    return ProductStats(
      totalProducts: totalProducts ?? this.totalProducts,
      inStockProducts: inStockProducts ?? this.inStockProducts,
      lowStockProducts: lowStockProducts ?? this.lowStockProducts,
      outOfStockProducts: outOfStockProducts ?? this.outOfStockProducts,
      averagePrice: averagePrice ?? this.averagePrice,
      totalValue: totalValue ?? this.totalValue,
      productsByCategory: productsByCategory ?? this.productsByCategory,
    );
  }

  double get stockPercentage => totalProducts > 0 ? (inStockProducts / totalProducts) * 100 : 0;

  Map<String, dynamic> toMap() {
    return {
      'totalProducts': totalProducts,
      'inStockProducts': inStockProducts,
      'lowStockProducts': lowStockProducts,
      'outOfStockProducts': outOfStockProducts,
      'averagePrice': averagePrice,
      'totalValue': totalValue,
      'productsByCategory': productsByCategory,
    };
  }

  factory ProductStats.fromMap(Map<String, dynamic> map) {
    return ProductStats(
      totalProducts: map['totalProducts'] ?? 0,
      inStockProducts: map['inStockProducts'] ?? 0,
      lowStockProducts: map['lowStockProducts'] ?? 0,
      outOfStockProducts: map['outOfStockProducts'] ?? 0,
      averagePrice: (map['averagePrice'] ?? 0).toDouble(),
      totalValue: (map['totalValue'] ?? 0).toDouble(),
      productsByCategory: Map<String, int>.from(map['productsByCategory'] ?? {}),
    );
  }
}