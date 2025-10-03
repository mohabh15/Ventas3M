import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/product_filters.dart';
import '../services/firebase_service.dart';

/// Provider para manejar el estado de productos
class ProductsProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;

  ProductsProvider(this._firebaseService);

  // Estado de carga
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Lista de productos
  List<Product> _products = [];
  List<Product> get products => _products;

  // Productos filtrados
  List<Product> _filteredProducts = [];
  List<Product> get filteredProducts => _filteredProducts;

  // Categorías disponibles
  List<ProductCategoryModel> _categories = [];
  List<ProductCategoryModel> get categories => _categories;

  // Estadísticas
  ProductStats _stats = const ProductStats();
  ProductStats get stats => _stats;

  // Filtros actuales
  ProductFilters _filters = const ProductFilters();
  ProductFilters get filters => _filters;

  // Vista actual
  ProductViewMode _viewMode = ProductViewMode.grid;
  ProductViewMode get viewMode => _viewMode;

  // Producto seleccionado para edición
  Product? _selectedProduct;
  Product? get selectedProduct => _selectedProduct;

  // Modo de selección múltiple
  bool _isSelectionMode = false;
  bool get isSelectionMode => _isSelectionMode;

  final Set<String> _selectedProducts = {};
  Set<String> get selectedProducts => _selectedProducts;

  // Búsqueda
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Inicializar datos
  Future<void> initialize() async {
    await loadProducts();
    await loadCategories();
    await calculateStats();
  }

  // Cargar productos desde Firebase
  Future<void> loadProducts() async {
    _setLoading(true);
    try {
      _products = await _firebaseService.getProducts();
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading products: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Cargar categorías desde Firebase
  Future<void> loadCategories() async {
    try {
      // Por ahora usar categorías por defecto
      _categories = ProductCategory.values.map((category) => ProductCategoryModel(
        id: category.name,
        name: category.displayName,
        icon: category.icon,
        color: category.color,
        createdAt: DateTime.now(),
      )).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  // Calcular estadísticas
  Future<void> calculateStats() async {
    try {
      final totalProducts = _products.length;
      final inStockProducts = _products.where((p) => p.inStock).length;
      final lowStockProducts = _products.where((p) => p.stockCount <= 5 && p.stockCount > 0).length;
      final outOfStockProducts = _products.where((p) => !p.inStock || p.stockCount == 0).length;

      final totalValue = _products.fold<double>(0, (sum, p) => sum + (p.price * p.stockCount));
      final averagePrice = totalProducts > 0 ? totalValue / totalProducts : 0.0;

      final productsByCategory = <String, int>{};
      for (final product in _products) {
        productsByCategory[product.category] = (productsByCategory[product.category] ?? 0) + 1;
      }

      _stats = ProductStats(
        totalProducts: totalProducts,
        inStockProducts: inStockProducts,
        lowStockProducts: lowStockProducts,
        outOfStockProducts: outOfStockProducts,
        averagePrice: averagePrice,
        totalValue: totalValue,
        productsByCategory: productsByCategory,
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Error calculating stats: $e');
    }
  }

  // Aplicar filtros a productos
  void _applyFilters() {
    var filtered = List<Product>.from(_products);

    // Filtro de búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               product.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               product.sku.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               product.barcode.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filtro de categorías
    if (_filters.categories.isNotEmpty) {
      filtered = filtered.where((product) => _filters.categories.contains(product.category)).toList();
    }

    // Filtro de rango de precio
    if (_filters.priceRange != null) {
      filtered = filtered.where((product) {
        return product.price >= _filters.priceRange!.start && product.price <= _filters.priceRange!.end;
      }).toList();
    }

    // Filtro de estado de stock
    if (_filters.stockStatus != null) {
      filtered = filtered.where((product) {
        switch (_filters.stockStatus!) {
          case StockStatus.inStock:
            return product.inStock && product.stockCount > 5;
          case StockStatus.lowStock:
            return product.inStock && product.stockCount <= 5 && product.stockCount > 0;
          case StockStatus.outOfStock:
            return !product.inStock || product.stockCount == 0;
          case StockStatus.discontinued:
            return false; // Implementar lógica cuando esté disponible
        }
      }).toList();
    }

    // Filtro de calificación mínima
    if (_filters.minRating != null) {
      filtered = filtered.where((product) => product.rating >= _filters.minRating!).toList();
    }

    // Filtro de rango de fecha
    if (_filters.dateRange != null) {
      filtered = filtered.where((product) {
        return product.createdAt.isAfter(_filters.dateRange!.start) &&
               product.createdAt.isBefore(_filters.dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Filtro de etiquetas
    if (_filters.tags.isNotEmpty) {
      filtered = filtered.where((product) {
        return _filters.tags.any((tag) => product.tags.contains(tag));
      }).toList();
    }

    // Aplicar ordenamiento
    _applySorting(filtered);

    _filteredProducts = filtered;
    notifyListeners();
  }

  // Aplicar ordenamiento
  void _applySorting(List<Product> products) {
    products.sort((a, b) {
      switch (_filters.sortBy) {
        case ProductSortOption.name:
          return a.name.compareTo(b.name);
        case ProductSortOption.price:
          return a.price.compareTo(b.price);
        case ProductSortOption.stock:
          return a.stockCount.compareTo(b.stockCount);
        case ProductSortOption.rating:
          return b.rating.compareTo(a.rating); // Descendente
        case ProductSortOption.date:
          return b.createdAt.compareTo(a.createdAt); // Más reciente primero
        case ProductSortOption.popularity:
          return (b.rating * b.reviewCount).compareTo(a.rating * a.reviewCount);
      }
    });
  }

  // Establecer consulta de búsqueda
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // Aplicar filtros
  void applyFilters(ProductFilters newFilters) {
    _filters = newFilters;
    _applyFilters();
  }

  // Limpiar filtros
  void clearFilters() {
    _filters = const ProductFilters();
    _applyFilters();
  }

  // Cambiar modo de vista
  void setViewMode(ProductViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  // Crear producto
  Future<bool> createProduct(Product product) async {
    _setLoading(true);
    try {
      final newProduct = await _firebaseService.createProduct(product);
      _products.add(newProduct);
      await calculateStats();
      _applyFilters();
      return true;
    } catch (e) {
      debugPrint('Error creating product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar producto
  Future<bool> updateProduct(Product product) async {
    _setLoading(true);
    try {
      await _firebaseService.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        await calculateStats();
        _applyFilters();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar producto
  Future<bool> deleteProduct(String productId) async {
    _setLoading(true);
    try {
      await _firebaseService.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      // Solo remover de productos seleccionados si está en modo selección
      if (_isSelectionMode) {
        _selectedProducts.remove(productId);
      }
      await calculateStats();
      _applyFilters();
      return true;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Duplicar producto
  Future<bool> duplicateProduct(String productId) async {
    try {
      final originalProduct = _products.firstWhere((p) => p.id == productId);
      final duplicatedProduct = originalProduct.copyWith(
        id: '', // Firebase generará nuevo ID
        name: '${originalProduct.name} (Copia)',
        sku: '${originalProduct.sku}_copy',
        barcode: '${originalProduct.barcode}_copy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await createProduct(duplicatedProduct);
    } catch (e) {
      debugPrint('Error duplicating product: $e');
      return false;
    }
  }

  // Seleccionar producto para edición
  void selectProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  // Modo de selección múltiple
  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedProducts.clear();
    }
    notifyListeners();
  }

  // Seleccionar/deseleccionar producto
  void toggleProductSelection(String productId) {
    if (_selectedProducts.contains(productId)) {
      _selectedProducts.remove(productId);
    } else {
      _selectedProducts.add(productId);
    }
    notifyListeners();
  }

  // Seleccionar todos los productos
  void selectAllProducts() {
    _selectedProducts.addAll(_filteredProducts.map((p) => p.id));
    notifyListeners();
  }

  // Deseleccionar todos los productos
  void deselectAllProducts() {
    _selectedProducts.clear();
    notifyListeners();
  }

  // Eliminar productos seleccionados
  Future<bool> deleteSelectedProducts() async {
    _setLoading(true);
    try {
      bool allSuccess = true;
      for (final productId in _selectedProducts) {
        try {
          await _firebaseService.deleteProduct(productId);
        } catch (e) {
          debugPrint('Error deleting product $productId: $e');
          allSuccess = false;
        }
      }

      if (allSuccess) {
        _products.removeWhere((p) => _selectedProducts.contains(p.id));
        _selectedProducts.clear();
        await calculateStats();
        _applyFilters();
      }

      return allSuccess;
    } catch (e) {
      debugPrint('Error deleting selected products: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Obtener productos por categoría
  List<Product> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  // Obtener productos con stock bajo
  List<Product> getLowStockProducts() {
    return _products.where((p) => p.inStock && p.stockCount <= 5 && p.stockCount > 0).toList();
  }

  // Obtener productos agotados
  List<Product> getOutOfStockProducts() {
    return _products.where((p) => !p.inStock || p.stockCount == 0).toList();
  }

  // Método auxiliar para establecer estado de carga
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}