import 'package:flutter/material.dart';
import '../models/debt.dart';
import '../services/debt_service.dart';

class DebtProvider extends ChangeNotifier {
  final DebtService _debtService = DebtService();

  List<Debt> _debts = [];
  List<Debt> _filteredDebts = [];
  bool _isLoading = false;
  String? _error;
  String? _currentProjectId;
  DebtStatus? _currentFilter;

  List<Debt> get debts => _debts;
  List<Debt> get filteredDebts => _filteredDebts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Debt> get pendingDebts => _debts.where((debt) => debt.isPending).toList();
  List<Debt> get paidDebts => _debts.where((debt) => debt.isPaid).toList();
  List<Debt> get cancelledDebts => _debts.where((debt) => debt.isCancelled).toList();
  List<Debt> get overdueDebts => _debts.where((debt) => debt.isOverdue).toList();

  double get totalDebtAmount => _debts.fold(0.0, (sum, debt) => sum + debt.amount);
  double get totalPendingAmount => pendingDebts.fold(0.0, (sum, debt) => sum + debt.amount);
  double get totalPaidAmount => paidDebts.fold(0.0, (sum, debt) => sum + debt.amount);

  Future<void> loadDebts(String projectId) async {
    _isLoading = true;
    _error = null;
    _currentProjectId = projectId;
    notifyListeners();

    try {
      _debts = await _debtService.getDebts();
      _filteredDebts = _debts;
      _applyCurrentFilter();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createDebt(Debt debt) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final debtId = await _debtService.createDebt(debt);
      final createdDebt = debt.copyWith(id: debtId);
      _debts.add(createdDebt);
      _applyFiltersAndSort();
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

  Future<bool> updateDebt(Debt debt) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _debtService.updateDebt(debt.id, debt);

      final index = _debts.indexWhere((d) => d.id == debt.id);
      if (index != -1) {
        _debts[index] = debt;
        _applyFiltersAndSort();
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

  Future<bool> deleteDebt(String debtId) async {
    if (_currentProjectId == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _debtService.deleteDebt(debtId);

      _debts.removeWhere((debt) => debt.id == debtId);
      _applyFiltersAndSort();

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

  Future<bool> markAsPaid(String debtId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _debtService.markAsPaid(debtId);

      final index = _debts.indexWhere((d) => d.id == debtId);
      if (index != -1) {
        _debts[index] = _debts[index].copyWith(status: DebtStatus.paid);
        _applyFiltersAndSort();
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

  Future<bool> markAsCancelled(String debtId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _debtService.markAsCancelled(debtId);

      final index = _debts.indexWhere((d) => d.id == debtId);
      if (index != -1) {
        _debts[index] = _debts[index].copyWith(status: DebtStatus.cancelled);
        _applyFiltersAndSort();
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

  void filterByStatus(DebtStatus? status) {
    _currentFilter = status;
    _applyCurrentFilter();
  }

  void searchDebts(String query) {
    if (query.trim().isEmpty) {
      _filteredDebts = _debts;
    } else {
      _filteredDebts = _debts.where((debt) {
        return debt.description.toLowerCase().contains(query.toLowerCase()) ||
               debt.debtor.toLowerCase().contains(query.toLowerCase()) ||
               debt.creditor.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  List<Debt> getDebtsByDebtor(String debtor) {
    return _debts.where((debt) => debt.debtor == debtor).toList();
  }

  List<Debt> getDebtsByCreditor(String creditor) {
    return _debts.where((debt) => debt.creditor == creditor).toList();
  }

  List<Debt> getDebtsByDateRange(DateTime startDate, DateTime endDate) {
    return _debts.where((debt) {
      return debt.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             debt.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Nuevos métodos para obtener deudas según nuestra posición
  Stream<List<Debt>> getDebtsWhereWeAreDebtor(String userEmail) {
    return _debtService.getDebtsWhereWeAreDebtor(userEmail);
  }

  Stream<List<Debt>> getDebtsWhereWeAreCreditor(String userEmail) {
    return _debtService.getDebtsWhereWeAreCreditor(userEmail);
  }

  Stream<List<Debt>> getPendingDebtsWhereWeAreDebtor(String userEmail) {
    return _debtService.getPendingDebtsWhereWeAreDebtor(userEmail);
  }

  Stream<List<Debt>> getPendingDebtsWhereWeAreCreditor(String userEmail) {
    return _debtService.getPendingDebtsWhereWeAreCreditor(userEmail);
  }

  Future<double> getTotalDebtAmountWhereWeAreDebtor(String projectId, String userEmail) async {
    return _debtService.getTotalDebtAmountWhereWeAreDebtor(projectId, userEmail);
  }

  Future<double> getTotalDebtAmountWhereWeAreCreditor(String projectId, String userEmail) async {
    return _debtService.getTotalDebtAmountWhereWeAreCreditor(projectId, userEmail);
  }

  Future<double> getTotalPendingAmountWhereWeAreDebtor(String projectId, String userEmail) async {
    return _debtService.getTotalPendingAmountWhereWeAreDebtor(projectId, userEmail);
  }

  Future<double> getTotalPendingAmountWhereWeAreCreditor(String projectId, String userEmail) async {
    return _debtService.getTotalPendingAmountWhereWeAreCreditor(projectId, userEmail);
  }

  Map<String, dynamic> getDebtStats() {
    return {
      'totalDebts': _debts.length,
      'totalAmount': totalDebtAmount,
      'totalPendingAmount': totalPendingAmount,
      'totalPaidAmount': totalPaidAmount,
      'pendingCount': pendingDebts.length,
      'paidCount': paidDebts.length,
      'cancelledCount': cancelledDebts.length,
      'overdueCount': overdueDebts.length,
    };
  }

  Stream<List<Debt>> listenToProjectDebts() {
    if (_currentProjectId == null) {
      return Stream.value([]);
    }
    return _debtService.listenToProjectDebts(_currentProjectId!);
  }

  void clearDebts() {
    _debts.clear();
    _filteredDebts.clear();
    _error = null;
    _currentProjectId = null;
    _currentFilter = null;
    notifyListeners();
  }

  void setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void _applyCurrentFilter() {
    if (_currentFilter == null) {
      _filteredDebts = _debts;
    } else {
      _filteredDebts = _debts.where((debt) => debt.status == _currentFilter).toList();
    }
    notifyListeners();
  }

  void _applyFiltersAndSort() {
    _applyCurrentFilter();
  }
}