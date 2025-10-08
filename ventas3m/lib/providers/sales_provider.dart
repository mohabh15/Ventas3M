import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../models/payment_method.dart';
import '../services/sale_service.dart';

class SalesProvider extends ChangeNotifier {
  final SaleService _saleService = SaleService();

  List<Sale> _sales = [];
  bool _isLoading = false;
  String? _error;
  String? _currentProjectId;

  List<Sale> get sales => _sales;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters adicionales
  List<Sale> get completedSales => _sales.where((sale) => sale.isCompleted).toList();
  List<Sale> get pendingSales => _sales.where((sale) => sale.isPending).toList();
  List<Sale> get salesWithDebt => _sales.where((sale) => sale.hasDebt).toList();

  double get totalSalesAmount => completedSales.fold(0.0, (accumulator, sale) => accumulator + sale.totalAmount);
  double get totalProfit => completedSales.fold(0.0, (accumulator, sale) => accumulator + sale.profit);
  double get totalDebt => salesWithDebt.fold(0.0, (accumulator, sale) => accumulator + (sale.debt ?? 0.0));

  /// Carga ventas desde Firestore para un proyecto específico
  Future<void> loadSales(String projectId) async {
    _isLoading = true;
    _error = null;
    _currentProjectId = projectId;
    notifyListeners();

    try {
      _sales = await _saleService.getSalesFromFirestore(projectId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crea una nueva venta con validación completa
  Future<bool> createSale(Sale sale) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Crear venta en Firestore
      final createdSale = await _saleService.createSaleWithStockValidation(sale);

      // Actualizar lista local
      _sales.add(createdSale);

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Actualiza una venta existente
  Future<bool> updateSale(Sale sale) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _saleService.updateSaleInFirestore(sale);

      // Actualizar en lista local
      final index = _sales.indexWhere((s) => s.id == sale.id);
      if (index != -1) {
        _sales[index] = sale;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Elimina una venta
  Future<bool> deleteSale(String saleId) async {
    if (_currentProjectId == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _saleService.deleteSaleFromFirestore(_currentProjectId!, saleId);

      // Remover de lista local
      _sales.removeWhere((sale) => sale.id == saleId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Obtiene ventas por diferentes criterios
  List<Sale> getSalesByProduct(String productId) {
    return _sales.where((sale) => sale.productId == productId).toList();
  }

  List<Sale> getSalesBySeller(String sellerId) {
    return _sales.where((sale) => sale.sellerId == sellerId).toList();
  }

  List<Sale> getSalesByCustomer(String customerName) {
    return _sales.where((sale) => sale.customerName.toLowerCase().contains(customerName.toLowerCase())).toList();
  }

  List<Sale> getSalesByPaymentMethod(PaymentMethod paymentMethod) {
    return _sales.where((sale) => sale.paymentMethod == paymentMethod).toList();
  }

  List<Sale> getSalesByDateRange(DateTime startDate, DateTime endDate) {
    return _sales.where((sale) {
      return sale.saleDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             sale.saleDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Obtiene estadísticas de ventas
  Map<String, dynamic> getSalesStats() {
    return {
      'totalSales': _sales.length,
      'totalAmount': totalSalesAmount,
      'totalProfit': totalProfit,
      'totalDebt': totalDebt,
      'completedSales': completedSales.length,
      'pendingSales': pendingSales.length,
      'salesWithDebt': salesWithDebt.length,
    };
  }

  /// Escucha cambios en tiempo real
  Stream<List<Sale>> listenToSales() {
    if (_currentProjectId == null) {
      return Stream.value([]);
    }
    return _saleService.listenToSales(_currentProjectId!);
  }

  /// Limpia todas las ventas y errores
  void clearSales() {
    _sales.clear();
    _error = null;
    _currentProjectId = null;
    notifyListeners();
  }

  /// Establece error manualmente
  void setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
}