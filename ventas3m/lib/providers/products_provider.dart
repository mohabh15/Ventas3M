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
}