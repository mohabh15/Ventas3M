import 'package:flutter/material.dart';
import 'dart:async';
import '../models/product.dart';
import '../services/product_stock_service.dart';
import 'settings_provider.dart';

class ProductStockProvider extends ChangeNotifier {
  final ProductStockService _stockService = ProductStockService();

  Map<String, List<ProductStock>> _productStocks = {};
  Map<String, int> _productTotalStocks = {};
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<ProductStock>>? _stocksSubscription;
  SettingsProvider? _settingsProvider;

  Map<String, List<ProductStock>> get productStocks => _productStocks;
  Map<String, int> get productTotalStocks => _productTotalStocks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _settingsProvider != null;

  ProductStockProvider() {
    _initializeProvider();
    // Solo usar datos reales de Firebase, no datos de ejemplo
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

    // Si ya hay un proyecto activo, cargar stocks inmediatamente
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
      _setupStocksStream(projectId);
    } else {
      _stocksSubscription?.cancel();
      _productStocks.clear();
      _productTotalStocks.clear();
      _error = 'No hay proyecto seleccionado';
      notifyListeners();
    }
  }

  void _onProjectChanged() {
    final newProjectId = _settingsProvider?.activeProjectId;

    if (newProjectId != null) {
      _setupStocksStream(newProjectId);
    } else {
      // Si no hay proyecto seleccionado, limpiar stocks
      _stocksSubscription?.cancel();
      _productStocks.clear();
      _productTotalStocks.clear();
      _error = 'No hay proyecto seleccionado';
      notifyListeners();
    }
  }

  void _setupStocksStream(String projectId) async {
    // Cancelar suscripción anterior si existe
    _stocksSubscription?.cancel();

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Configurar el stream de stocks para el proyecto actual
      _stocksSubscription = _stockService.getStockStreamByProject(projectId).listen(
        (stocks) {
          // Filtrar solo stocks válidos del proyecto actual
          final validStocks = stocks.where((stock) =>
            stock.projectId == projectId &&
            stock.productId.isNotEmpty &&
            stock.id.isNotEmpty
          ).toList();

          _processStocksData(validStocks);
          _error = null;
          _isLoading = false;
          // Notificar cambios cuando llegan nuevos datos del stream
          notifyListeners();
        },
        onError: (error) {
          _error = 'Error al cargar stocks: $error';
          _productStocks.clear();
          _productTotalStocks.clear();
          _isLoading = false;
          notifyListeners();
        },
        onDone: () {
          // Manejar cuando el stream se cierra
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Error al configurar stream de stocks: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _processStocksData(List<ProductStock> stocks) {
    // Limpiar datos anteriores antes de procesar nuevos
    _productStocks.clear();
    _productTotalStocks.clear();

    // Organizar stocks por producto
    final stocksByProduct = <String, List<ProductStock>>{};
    final totalStocksByProduct = <String, int>{};

    for (var stock in stocks) {
      // Solo procesar stocks válidos
      if (stock.productId.isNotEmpty && stock.projectId.isNotEmpty && stock.id.isNotEmpty) {
        // Agrupar por productId
        if (stocksByProduct.containsKey(stock.productId)) {
          stocksByProduct[stock.productId]!.add(stock);
        } else {
          stocksByProduct[stock.productId] = [stock];
        }

        // Calcular totales
        totalStocksByProduct[stock.productId] =
            (totalStocksByProduct[stock.productId] ?? 0) + stock.quantity;
      }
    }

    _productStocks = stocksByProduct;
    _productTotalStocks = totalStocksByProduct;

  }

  Future<void> loadStocks() async {
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
      final stocks = await _stockService.getStockByProject(projectId);
      _processStocksData(stocks);
      _error = null;
    } catch (e) {
      _error = 'Error al cargar stocks: $e';
      _productStocks.clear();
      _productTotalStocks.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addStock(ProductStock stock) async {
    final projectId = _settingsProvider?.activeProjectId;

    if (projectId == null) {
      _error = 'No hay proyecto seleccionado';
      notifyListeners();
      return;
    }

    try {
      final stockWithProject = ProductStock(
        id: stock.id,
        productId: stock.productId,
        quantity: stock.quantity,
        responsibleId: stock.responsibleId,
        providerId: stock.providerId,
        price: stock.price,
        purchaseDate: stock.purchaseDate,
        createdAt: stock.createdAt,
        updatedAt: stock.updatedAt,
        projectId: projectId,
      );

      await _stockService.createStock(stockWithProject);
      _error = null;

      // Combinar el nuevo stock con los datos existentes para mantener consistencia
      try {
        final currentStocks = <ProductStock>[];

        // Obtener todos los stocks actuales del mapa
        for (var stocks in _productStocks.values) {
          currentStocks.addAll(stocks);
        }

        // Añadir el nuevo stock
        currentStocks.add(stockWithProject);

        // Filtrar solo stocks válidos del proyecto actual
        final validStocks = currentStocks.where((stock) =>
          stock.projectId == projectId &&
          stock.productId.isNotEmpty &&
          stock.id.isNotEmpty
        ).toList();

        _processStocksData(validStocks);
      } catch (e) {
        // Si falla, intentar recargar completamente desde Firestore
        try {
          final updatedStocks = await _stockService.getStockByProject(projectId);

          // Filtrar solo stocks válidos del proyecto actual
          final validStocks = updatedStocks.where((stock) =>
            stock.projectId == projectId &&
            stock.productId.isNotEmpty &&
            stock.id.isNotEmpty
          ).toList();

          _processStocksData(validStocks);
        } catch (e2) {
          // Si falla la recarga directa, intentar recargar el stream
          if (_settingsProvider?.activeProjectId != null) {
            _setupStocksStream(_settingsProvider!.activeProjectId!);
          }
        }
      }

      // Notificar a los listeners después de añadir stock exitosamente
      // Esto asegura que la UI se actualice inmediatamente
      notifyListeners();
    } catch (e) {
      _error = 'Error al añadir stock: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateStock(ProductStock stock) async {
    try {
      await _stockService.updateStock(stock);
      _error = null;
    } catch (e) {
      _error = 'Error al actualizar stock: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeStock(String stockId) async {
    try {
      await _stockService.deleteStock(stockId);
      _error = null;
    } catch (e) {
      _error = 'Error al eliminar stock: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Obtener stocks de un producto específico
  List<ProductStock>? getStocksForProduct(String productId) {
    return _productStocks[productId];
  }

  // Obtener stock total de un producto específico
  int getTotalStockForProduct(String productId) {
    return _productTotalStocks[productId] ?? 0;
  }

  @override
  void dispose() {
    _stocksSubscription?.cancel();
    if (_settingsProvider != null) {
      _settingsProvider!.removeListener(_onProjectChanged);
    }
    super.dispose();
  }

}