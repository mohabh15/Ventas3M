import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();

  // Estado privado
  List<Expense> _expenses = [];
  List<Expense> _filteredExpenses = [];
  Expense? _selectedExpense;
  bool _isLoading = false;
  Map<String, dynamic> _filters = {};

  // Constructor
  ExpenseProvider() {
    loadExpenses();
  }

  // Getters públicos
  List<Expense> get expenses => _expenses;
  List<Expense> get filteredExpenses => _filteredExpenses;
  Expense? get selectedExpense => _selectedExpense;
  bool get isLoading => _isLoading;
  double get totalExpenses => _calculateTotal(_expenses);
  double get totalFilteredExpenses => _calculateTotal(_filteredExpenses);

  // Métodos principales
  Future<void> loadExpenses() async {
    _setLoading(true);
    try {
      final expensesStream = _expenseService.getAllExpenses();
      expensesStream.listen((expenses) {
        _expenses = expenses;
        _applyFilters();
        _setLoading(false);
      });
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> loadExpensesByProject(String projectId) async {
    _setLoading(true);
    try {
      final expensesStream = _expenseService.getExpensesByProject(projectId);
      expensesStream.listen((expenses) {
        _expenses = expenses;
        _applyFilters();
        _setLoading(false);
      });
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> loadExpensesByCategory(String category) async {
    _setLoading(true);
    try {
      final expensesStream = _expenseService.getExpensesByCategory(category);
      expensesStream.listen((expenses) {
        _expenses = expenses;
        _applyFilters();
        _setLoading(false);
      });
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> loadExpensesByDateRange(DateTime start, DateTime end) async {
    _setLoading(true);
    try {
      final expensesStream = _expenseService.getExpensesByDateRange(start, end);
      expensesStream.listen((expenses) {
        _expenses = expenses;
        _applyFilters();
        _setLoading(false);
      });
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> createExpense(Expense expense) async {
    _setLoading(true);
    try {
      await _expenseService.createExpense(expense);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> updateExpense(String id, Expense expense) async {
    _setLoading(true);
    try {
      await _expenseService.updateExpense(id, expense);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    _setLoading(true);
    try {
      await _expenseService.deleteExpense(id);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  void selectExpense(Expense expense) {
    _selectedExpense = expense;
    notifyListeners();
  }

  void clearSelection() {
    _selectedExpense = null;
    notifyListeners();
  }

  void setFilter(Map<String, dynamic> filter) {
    _filters = filter;
    _applyFilters();
  }

  void clearFilters() {
    _filters.clear();
    _applyFilters();
  }

  void _applyFilters() {
    if (_filters.isEmpty) {
      _filteredExpenses = List.from(_expenses);
    } else {
      _filteredExpenses = _expenses.where((expense) {
        bool matches = true;

        if (_filters.containsKey('projectId') && _filters['projectId'] != null) {
          matches = matches && expense.projectId == _filters['projectId'];
        }

        if (_filters.containsKey('category') && _filters['category'] != null) {
          matches = matches && expense.category == _filters['category'];
        }

        if (_filters.containsKey('providerId') && _filters['providerId'] != null) {
          matches = matches && expense.providerId == _filters['providerId'];
        }

        if (_filters.containsKey('paymentMethod') && _filters['paymentMethod'] != null) {
          matches = matches && expense.paymentMethod == _filters['paymentMethod'];
        }

        if (_filters.containsKey('isRecurring') && _filters['isRecurring'] != null) {
          matches = matches && expense.isRecurring == _filters['isRecurring'];
        }

        if (_filters.containsKey('startDate') && _filters['startDate'] != null) {
          matches = matches && expense.date.isAfter(_filters['startDate']);
        }

        if (_filters.containsKey('endDate') && _filters['endDate'] != null) {
          matches = matches && expense.date.isBefore(_filters['endDate'].add(const Duration(days: 1)));
        }

        return matches;
      }).toList();
    }
    notifyListeners();
  }

  // Métodos auxiliares privados
  double _calculateTotal(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Getters adicionales
  List<String> get categories {
    return _expenses.map((expense) => expense.category).toSet().toList();
  }

  List<Expense> get recurringExpenses {
    return _expenses.where((expense) => expense.isRecurring).toList();
  }

  List<Expense> get expensesWithReceipt {
    return _expenses.where((expense) => expense.hasReceipt).toList();
  }

  Map<String, double> get expensesByCategory {
    final Map<String, double> result = {};
    for (var expense in _expenses) {
      result[expense.category] = (result[expense.category] ?? 0) + expense.amount;
    }
    return result;
  }

  Map<String, double> get expensesByPaymentMethod {
    final Map<String, double> result = {};
    for (var expense in _expenses) {
      final method = expense.paymentMethod.toString().split('.').last;
      result[method] = (result[method] ?? 0) + expense.amount;
    }
    return result;
  }
}