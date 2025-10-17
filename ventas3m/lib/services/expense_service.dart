import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/expense.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CRUD Operations
  Future<String> createExpense(Expense expense) async {
    try {
      final data = expense.toMap()..remove('id');
      final docRef = await _firestore.collection('expenses').add(data);

      await docRef.update({'id': docRef.id});

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<Expense?> getExpense(String id) async {
    try {
      final doc = await _firestore.collection('expenses').doc(id).get();
      if (doc.exists) {
        return Expense.fromMap(doc.data()!..addAll({'id': doc.id}));
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Expense>> getAllExpenses() {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('expenses')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromMap(doc.data()..addAll({'id': doc.id})))
            .toList());
  }

  Stream<List<Expense>> getExpensesByProject(String projectId) {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('expenses')
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromMap(doc.data()..addAll({'id': doc.id})))
            .toList());
  }

  Stream<List<Expense>> getExpensesByProvider(String providerId) {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('expenses')
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromMap(doc.data()..addAll({'id': doc.id})))
            .toList());
  }

  Stream<List<Expense>> getExpensesByCategory(String category) {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('expenses')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromMap(doc.data()..addAll({'id': doc.id})))
            .toList());
  }

  Stream<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('expenses')
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThanOrEqualTo: end.toIso8601String())
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromMap(doc.data()..addAll({'id': doc.id})))
            .toList());
  }

  Future<void> updateExpense(String id, Expense expense) async {
    try {
      await _firestore
          .collection('expenses')
          .doc(id)
          .update(expense.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _firestore.collection('expenses').doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Additional Operations
  Future<List<String>> getExpenseCategories() async {
    try {
      final snapshot = await _firestore.collection('expenses').get();

      return snapshot.docs
          .map((doc) => (doc.data()['category'] ?? '') as String)
          .where((category) => category.isNotEmpty)
          .toSet()
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<double> getTotalExpensesByProject(String projectId) async {
    try {
      final snapshot = await _firestore
          .collection('expenses')
          .where('projectId', isEqualTo: projectId)
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        final amount = (doc.data()['amount'] ?? 0).toDouble();
        total += amount;
      }
      return total;
    } catch (e) {
      rethrow;
    }
  }

  Future<double> getTotalExpensesByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('expenses')
          .where('category', isEqualTo: category)
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        final amount = (doc.data()['amount'] ?? 0).toDouble();
        total += amount;
      }
      return total;
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Expense>> getRecurringExpenses() {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('expenses')
        .where('isRecurring', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromMap(doc.data()..addAll({'id': doc.id})))
            .toList());
  }

  Stream<List<Expense>> getExpensesByUser(String userId) {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('expenses')
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromMap(doc.data()..addAll({'id': doc.id})))
            .toList());
  }
}