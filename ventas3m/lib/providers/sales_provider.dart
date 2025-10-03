import 'package:flutter/material.dart';
import '../models/sale.dart';

class SalesProvider extends ChangeNotifier {
  List<Sale> _sales = [];
  bool _isLoading = false;
  String? _error;

  List<Sale> get sales => _sales;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSales() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simular carga de datos
      await Future.delayed(const Duration(seconds: 1));
      // Por ahora, devolver lista vacía
      _sales = [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addSale(Sale sale) {
    _sales.add(sale);
    notifyListeners();
  }

  void removeSale(String id) {
    _sales.removeWhere((sale) => sale.id == id);
    notifyListeners();
  }

  void clearSales() {
    _sales.clear();
    notifyListeners();
  }
}