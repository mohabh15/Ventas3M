import 'package:flutter/material.dart';
import 'dart:async';
import '../models/product.dart';
import '../services/product_service.dart';
import 'settings_provider.dart';

class ProductsProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Product>>? _productsSubscription;
  SettingsProvider? _settingsProvider;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _settingsProvider != null;

  ProductsProvider() {
    _initializeProvider();
    _loadSampleProducts();
  }

  // Método para establecer el Settings Provider para sincronización
  void setSettingsProvider(SettingsProvider settingsProvider) {
    // Remover listener anterior si existe
    if (_settingsProvider != null) {
      _settingsProvider!.removeListener(_onProjectChanged);
    }

    _settingsProvider = settingsProvider;

    // Configurar listener para cambios en el proyecto activo
    _settingsProvider!.addListener(_onProjectChanged);

    // Si ya hay un proyecto activo, cargar productos inmediatamente
    if (_settingsProvider?.activeProjectId != null) {
      _onProjectChanged();
    }
  }

  

  void _initializeProvider() {
    // El provider se inicializará cuando se llame a setSettingsProvider
    // desde el contexto que tenga acceso al SettingsProvider
  }

  void setCurrentProject(String projectId) {
    if (projectId.isNotEmpty) {
      _setupProductsStream(projectId);
    } else {
      _productsSubscription?.cancel();
      _products = [];
      _error = 'No hay proyecto seleccionado';
      notifyListeners();
    }
  }

  void _onProjectChanged() {
    final newProjectId = _settingsProvider?.activeProjectId;
    
    if (newProjectId != null) {
      _setupProductsStream(newProjectId);
    } else {
      // Si no hay proyecto seleccionado, limpiar productos
      _productsSubscription?.cancel();
      _products = [];
      _error = 'No hay proyecto seleccionado';
      notifyListeners();
    }
  }

  void _setupProductsStream(String projectId) async {
    // Cancelar suscripción anterior si existe
    _productsSubscription?.cancel();
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Configurar el stream de productos para el proyecto actual
      _productsSubscription = _productService.getProductsStream(projectId).listen(
        (products) {
          _products = products;
          _error = null;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          _error = 'Error al cargar productos: $error';
          _products = [];
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Error al configurar stream de productos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProducts() async {
    final projectId = _settingsProvider?.activeProjectId;

    if (projectId == null) {
      _error = 'No hay proyecto seleccionado';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _productService.getProductsByProject(projectId);
      _error = null;
    } catch (e) {
      _error = 'Error al cargar productos: $e';
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    final projectId = _settingsProvider?.activeProjectId;
    
    if (projectId == null) {
      _error = 'No hay proyecto seleccionado';
      notifyListeners();
      return;
    }

    try {
      final productWithProject = Product(
        id: product.id,
        name: product.name,
        description: product.description,
        basePrice: product.basePrice,
        category: product.category,
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
        projectId: projectId,
      );
      
      await _productService.createProduct(productWithProject);
      _error = null;
    } catch (e) {
      _error = 'Error al añadir producto: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _productService.updateProduct(product);
      _error = null;
    } catch (e) {
      _error = 'Error al actualizar producto: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeProduct(String productId) async {
    try {
      await _productService.deleteProduct(productId);
      _error = null;
    } catch (e) {
      _error = 'Error al eliminar producto: $e';
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    if (_settingsProvider != null) {
      _settingsProvider!.removeListener(_onProjectChanged);
    }
    super.dispose();
  }

  // Método para cargar productos de ejemplo para demostración
  void _loadSampleProducts() {
    // Solo cargar productos de ejemplo si no hay productos reales
    if (_products.isEmpty && !_isLoading) {
      _products = [
        Product(
          id: 'laptop-gaming-001',
          name: 'Laptop Gaming',
          description: 'Laptop gaming de alto rendimiento con tarjeta gráfica dedicada',
          basePrice: 15999.0,
          category: 'Electrónica',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
          projectId: 'demo-project',
        ),
        Product(
          id: 'iphone-15-pro-002',
          name: 'iPhone 15 Pro',
          description: 'Smartphone premium con cámara avanzada y procesador A17 Pro',
          basePrice: 24999.0,
          category: 'Electrónica',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          projectId: 'demo-project',
        ),
        Product(
          id: 'audifonos-pro-003',
          name: 'Audífonos Pro',
          description: 'Audífonos inalámbricos con cancelación de ruido activa',
          basePrice: 3499.0,
          category: 'Electrónica',
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          updatedAt: DateTime.now().subtract(const Duration(days: 7)),
          projectId: 'demo-project',
        ),
        Product(
          id: 'ipad-air-004',
          name: 'iPad Air',
          description: 'Tablet ligera y potente perfecta para productividad y creatividad',
          basePrice: 12999.0,
          category: 'Electrónica',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          projectId: 'demo-project',
        ),
        Product(
          id: 'camara-dslr-005',
          name: 'Cámara DSLR',
          description: 'Cámara réflex digital profesional de 24 megapíxeles',
          basePrice: 18999.0,
          category: 'Electrónica',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 10)),
          projectId: 'demo-project',
        ),
        Product(
          id: 'playstation-5-006',
          name: 'PlayStation 5',
          description: 'Consola de videojuegos de nueva generación con soporte 4K',
          basePrice: 12499.0,
          category: 'Electrónica',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          projectId: 'demo-project',
        ),
      ];
      notifyListeners();
    }
  }
}