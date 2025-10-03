import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/sale.dart';

/// Servicio para manejar operaciones de ventas
class SalesService {
  static final SalesService _instance = SalesService._internal();
  factory SalesService() => _instance;
  SalesService._internal();

  // Lista de productos disponibles (simulada)
  final List<Product> _products = [];

  // Historial de ventas
  final List<Sale> _salesHistory = [];

  /// Inicializa productos de ejemplo
  Future<void> initializeProducts() async {
    if (_products.isNotEmpty) return;

    // Simular carga desde API
    await Future.delayed(const Duration(milliseconds: 500));

    _products.addAll([
      Product(
        id: '1',
        name: 'Laptop Gaming Pro',
        description: 'Laptop de alto rendimiento para gaming con procesador Intel i7',
        price: 1299.99,
        originalPrice: 1499.99,
        imageUrl: 'https://via.placeholder.com/200x150/1976D2/FFFFFF?text=Laptop',
        category: 'Electrónicos',
        rating: 4.5,
        reviewCount: 128,
        inStock: true,
        stockCount: 15,
        tags: ['Gaming', 'Alta Performance'],
        barcode: '1234567890123',
        sku: 'LT-GAMING-001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '2',
        name: 'Smartphone Premium',
        description: 'Teléfono inteligente con cámara avanzada de 108MP',
        price: 899.99,
        imageUrl: 'https://via.placeholder.com/200x150/4CAF50/FFFFFF?text=Phone',
        category: 'Electrónicos',
        rating: 4.2,
        reviewCount: 89,
        inStock: true,
        stockCount: 23,
        tags: ['Smartphone', 'Premium'],
        barcode: '1234567890124',
        sku: 'SP-PREMIUM-001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '3',
        name: 'Auriculares Inalámbricos',
        description: 'Auriculares con cancelación de ruido activa',
        price: 199.99,
        originalPrice: 249.99,
        imageUrl: 'https://via.placeholder.com/200x150/9C27B0/FFFFFF?text=Headphones',
        category: 'Electrónicos',
        rating: 4.7,
        reviewCount: 156,
        inStock: true,
        stockCount: 8,
        tags: ['Audio', 'Inalámbrico'],
        barcode: '1234567890125',
        sku: 'HP-WIRELESS-001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '4',
        name: 'Tablet Profesional',
        description: 'Tablet para diseño gráfico con lápiz incluido',
        price: 599.99,
        imageUrl: 'https://via.placeholder.com/200x150/FF9800/FFFFFF?text=Tablet',
        category: 'Electrónicos',
        rating: 4.3,
        reviewCount: 67,
        inStock: true,
        stockCount: 12,
        tags: ['Tablet', 'Profesional'],
        barcode: '1234567890126',
        sku: 'TB-PRO-001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ]);
  }

  /// Obtiene productos con filtros aplicados
  List<Product> getProducts({
    String? searchQuery,
    ProductCategory? category,
    bool? inStockOnly,
  }) {
    return _products.where((product) {
      // Filtro de búsqueda
      final matchesSearch = searchQuery == null ||
          product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
          product.sku.toLowerCase().contains(searchQuery.toLowerCase());

      // Filtro de categoría
      final matchesCategory = category == null ||
          product.category == category.displayName;

      // Filtro de stock
      final matchesStock = !inStockOnly! || product.inStock;

      return matchesSearch && matchesCategory && matchesStock;
    }).toList();
  }

  /// Busca producto por código de barras
  Product? findProductByBarcode(String barcode) {
    try {
      return _products.firstWhere((product) => product.barcode == barcode);
    } catch (e) {
      return null;
    }
  }

  /// Busca producto por SKU
  Product? findProductBySku(String sku) {
    try {
      return _products.firstWhere((product) => product.sku == sku);
    } catch (e) {
      return null;
    }
  }

  /// Procesa una nueva venta
  Future<Sale> processSale({
    required List<CartItem> items,
    required PaymentMethod paymentMethod,
    Customer? customer,
    String? notes,
    double globalDiscount = 0.0,
  }) async {
    // Calcular totales
    final subtotal = items.fold(0.0, (sum, item) => sum + item.subtotal);
    final tax = subtotal * 0.16; // IVA 16%
    final total = subtotal + tax - globalDiscount;

    // Crear venta
    final sale = Sale(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: items,
      subtotal: subtotal,
      tax: tax,
      discount: globalDiscount,
      total: total,
      paymentMethod: paymentMethod,
      customer: customer,
      notes: notes,
      status: SaleStatus.completed,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: 'Usuario Actual',
      invoiceNumber: 'VTA-${DateTime.now().millisecondsSinceEpoch}',
    );

    // Agregar al historial
    _salesHistory.insert(0, sale);

    // Actualizar stock de productos
    for (final item in items) {
      final productIndex = _products.indexWhere((p) => p.id == item.product.id);
      if (productIndex != -1) {
        final product = _products[productIndex];
        final updatedProduct = product.copyWith(
          stockCount: product.stockCount - item.quantity,
          inStock: product.stockCount - item.quantity > 0,
        );
        _products[productIndex] = updatedProduct;
      }
    }

    return sale;
  }

  /// Obtiene historial de ventas
  List<Sale> getSalesHistory({
    int? limit,
    SaleStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return _salesHistory.where((sale) {
      // Filtro de estado
      if (status != null && sale.status != status) {
        return false;
      }

      // Filtro de fecha desde
      if (fromDate != null && sale.createdAt.isBefore(fromDate)) {
        return false;
      }

      // Filtro de fecha hasta
      if (toDate != null && sale.createdAt.isAfter(toDate)) {
        return false;
      }

      return true;
    }).take(limit ?? _salesHistory.length).toList();
  }

  /// Obtiene estadísticas de ventas
  Map<String, dynamic> getSalesStats({int days = 30}) {
    final fromDate = DateTime.now().subtract(Duration(days: days));
    final recentSales = _salesHistory.where((sale) => sale.createdAt.isAfter(fromDate)).toList();

    final totalSales = recentSales.length;
    final totalRevenue = recentSales.fold(0.0, (sum, sale) => sum + sale.total);
    final totalItems = recentSales.fold(0, (sum, sale) => sum + sale.totalItems);

    // Calcular promedio por venta
    final averageSale = totalSales > 0 ? totalRevenue / totalSales : 0.0;

    // Calcular ventas por método de pago
    final paymentMethodStats = <PaymentMethodType, int>{};
    for (final sale in recentSales) {
      paymentMethodStats[sale.paymentMethod.type] =
          (paymentMethodStats[sale.paymentMethod.type] ?? 0) + 1;
    }

    return {
      'totalSales': totalSales,
      'totalRevenue': totalRevenue,
      'totalItems': totalItems,
      'averageSale': averageSale,
      'paymentMethodStats': paymentMethodStats,
      'periodDays': days,
    };
  }

  /// Cancela una venta
  Future<bool> cancelSale(String saleId) async {
    final saleIndex = _salesHistory.indexWhere((sale) => sale.id == saleId);
    if (saleIndex == -1) return false;

    // Marcar venta como cancelada
    final sale = _salesHistory[saleIndex];
    final cancelledSale = sale.copyWith(status: SaleStatus.cancelled);
    _salesHistory[saleIndex] = cancelledSale;

    // Restaurar stock de productos
    for (final item in sale.items) {
      final productIndex = _products.indexWhere((p) => p.id == item.product.id);
      if (productIndex != -1) {
        final product = _products[productIndex];
        final updatedProduct = product.copyWith(
          stockCount: product.stockCount + item.quantity,
          inStock: true,
        );
        _products[productIndex] = updatedProduct;
      }
    }

    return true;
  }

  /// Obtiene productos por categoría
  Map<String, List<Product>> getProductsByCategory() {
    final categories = <String, List<Product>>{};

    for (final product in _products) {
      if (!categories.containsKey(product.category)) {
        categories[product.category] = [];
      }
      categories[product.category]!.add(product);
    }

    return categories;
  }

  /// Valida disponibilidad de productos para carrito
  Map<String, bool> validateCartAvailability(List<CartItem> items) {
    final availability = <String, bool>{};

    for (final item in items) {
      final product = _products.where((p) => p.id == item.product.id).firstOrNull;
      availability[item.product.id] = product != null &&
          product.inStock &&
          product.stockCount >= item.quantity;
    }

    return availability;
  }

  /// Limpia productos antiguos (simulación de limpieza de datos)
  void clearOldProducts({int daysToKeep = 365}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    _products.removeWhere((product) => product.createdAt.isBefore(cutoffDate));
  }

  /// Obtiene producto por ID
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Actualiza información de producto
  Future<bool> updateProduct(Product updatedProduct) async {
    final index = _products.indexWhere((product) => product.id == updatedProduct.id);
    if (index == -1) return false;

    _products[index] = updatedProduct.copyWith(updatedAt: DateTime.now());
    return true;
  }

  /// Agrega nuevo producto
  Future<Product> addProduct(Product product) async {
    final newProduct = product.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _products.add(newProduct);
    return newProduct;
  }

  /// Elimina producto
  Future<bool> deleteProduct(String productId) async {
    final index = _products.indexWhere((product) => product.id == productId);
    if (index == -1) return false;

    _products.removeAt(index);
    return true;
  }
}

/// Extensiones útiles para trabajar con ventas
extension SalesServiceExtensions on SalesService {
  /// Obtiene productos en stock
  List<Product> get inStockProducts => _products.where((product) => product.inStock).toList();

  /// Obtiene productos con stock bajo
  List<Product> get lowStockProducts {
    return _products.where((product) =>
        product.inStock && product.stockCount > 0 && product.stockCount <= 5).toList();
  }

  /// Obtiene productos más vendidos
  List<Product> get topSellingProducts {
    // Esta sería una implementación más compleja con datos reales
    return _products.take(5).toList();
  }

  /// Obtiene ventas del día actual
  List<Sale> get todaysSales {
    final today = DateTime.now();
    return _salesHistory.where((sale) =>
        sale.createdAt.year == today.year &&
        sale.createdAt.month == today.month &&
        sale.createdAt.day == today.day).toList();
  }
}