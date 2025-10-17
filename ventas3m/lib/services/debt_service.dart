import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/debt.dart';

class DebtService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _debtsCollection => _firestore.collection('debts');

  // CRUD Operations
  Future<String> createDebt(Debt debt) async {
    try {
      final data = debt.toMap()..remove('id');
      final docRef = await _debtsCollection.add(data);

      await docRef.update({'id': docRef.id});

      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear deuda: $e');
    }
  }

  Future<Debt?> getDebtById(String id) async {
    try {
      final doc = await _debtsCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          return Debt.fromMap(data..['id'] = doc.id);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener deuda: $e');
    }
  }

  Future<List<Debt>> getDebts() async {
    try {
      final snapshot = await _debtsCollection
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>..['id'] = doc.id;
        return Debt.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener deudas: $e');
    }
  }

  Future<void> updateDebt(String id, Debt debt) async {
    try {
      await _debtsCollection.doc(id).update({
        ...debt.toMap(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error al actualizar deuda: $e');
    }
  }

  Future<void> deleteDebt(String id) async {
    try {
      await _debtsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar deuda: $e');
    }
  }

  // Debt-specific Operations
  Future<void> markAsPaid(String debtId) async {
    try {
      await _debtsCollection.doc(debtId).update({
        'status': DebtStatus.paid.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error al marcar deuda como pagada: $e');
    }
  }

  Future<void> markAsCancelled(String debtId) async {
    try {
      await _debtsCollection.doc(debtId).update({
        'status': DebtStatus.cancelled.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error al cancelar deuda: $e');
    }
  }

  Future<void> markAsOverdue(String debtId) async {
    try {
      await _debtsCollection.doc(debtId).update({
        'status': DebtStatus.overdue.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error al marcar deuda como vencida: $e');
    }
  }

  // Query Operations
  Stream<List<Debt>> getDebtsByProject(String projectId) {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _debtsCollection
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>..['id'] = doc.id;
        return Debt.fromMap(data);
      }).toList();
    });
  }

  Stream<List<Debt>> getDebtsByUser(String userEmail) {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _debtsCollection
        .where('debtor', isEqualTo: userEmail)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>..['id'] = doc.id;
        return Debt.fromMap(data);
      }).toList();
    });
  }

  Stream<List<Debt>> getDebtsByDebtor(String debtorEmail) {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _debtsCollection
        .where('debtor', isEqualTo: debtorEmail)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>..['id'] = doc.id;
        return Debt.fromMap(data);
      }).toList();
    });
  }

  Stream<List<Debt>> getDebtsWhereUserIsCreditor(String userEmail) {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _debtsCollection
        .where('debtor', isEqualTo: userEmail)
        .where('debtType', isEqualTo: DebtType.aCobrar.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>..['id'] = doc.id;
        return Debt.fromMap(data);
      }).toList();
    });
  }

  Stream<List<Debt>> getPendingDebts() {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _debtsCollection
        .where('status', isEqualTo: DebtStatus.pending.name)
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>..['id'] = doc.id;
        return Debt.fromMap(data);
      }).toList();
    });
  }

  Stream<List<Debt>> getPaidDebts() {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _debtsCollection
        .where('status', isEqualTo: DebtStatus.paid.name)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>..['id'] = doc.id;
        return Debt.fromMap(data);
      }).toList();
    });
  }

  Stream<List<Debt>> getOverdueDebts() {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _debtsCollection
        .where('status', isEqualTo: DebtStatus.overdue.name)
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>..['id'] = doc.id;
        return Debt.fromMap(data);
      }).toList();
    });
  }

  Stream<List<Debt>> getRecentDebts({int limit = 10}) {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _debtsCollection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>..['id'] = doc.id;
        return Debt.fromMap(data);
      }).toList();
    });
  }

  Stream<List<Debt>> getDebtsByDateRange(DateTime start, DateTime end) {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _debtsCollection
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThanOrEqualTo: end.toIso8601String())
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>..['id'] = doc.id;
        return Debt.fromMap(data);
      }).toList();
    });
  }

  // Aggregation Operations
  Future<double> getTotalDebtAmount(String projectId) async {
    try {
      final snapshot = await _debtsCollection
          .where('projectId', isEqualTo: projectId)
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          final amount = (data['amount'] ?? 0).toDouble();
          total += amount;
        }
      }
      return total;
    } catch (e) {
      throw Exception('Error al calcular total de deudas: $e');
    }
  }

  Future<double> getTotalPendingAmount(String projectId) async {
    try {
      final snapshot = await _debtsCollection
          .where('projectId', isEqualTo: projectId)
          .where('status', isEqualTo: DebtStatus.pending.name)
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          final amount = (data['amount'] ?? 0).toDouble();
          total += amount;
        }
      }
      return total;
    } catch (e) {
      throw Exception('Error al calcular total pendiente: $e');
    }
  }

  Future<double> getTotalPaidAmount(String projectId) async {
    try {
      final snapshot = await _debtsCollection
          .where('projectId', isEqualTo: projectId)
          .where('status', isEqualTo: DebtStatus.paid.name)
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          final amount = (data['amount'] ?? 0).toDouble();
          total += amount;
        }
      }
      return total;
    } catch (e) {
      throw Exception('Error al calcular total pagado: $e');
    }
  }

  Future<int> getDebtCount(String projectId) async {
    try {
      final snapshot = await _debtsCollection
          .where('projectId', isEqualTo: projectId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Error al contar deudas: $e');
    }
  }

  Future<int> getPendingDebtCount(String projectId) async {
    try {
      final snapshot = await _debtsCollection
          .where('projectId', isEqualTo: projectId)
          .where('status', isEqualTo: DebtStatus.pending.name)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Error al contar deudas pendientes: $e');
    }
  }

  // Métodos de agregación para deudas según nuestra posición
  Future<double> getTotalDebtAmountWhereWeAreDebtor(String projectId, String userEmail) async {
    try {
      final snapshot = await _debtsCollection
          .where('projectId', isEqualTo: projectId)
          .where('debtor', isEqualTo: userEmail)
          .where('debtType', isEqualTo: DebtType.aPagar.name)
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          final amount = (data['amount'] ?? 0).toDouble();
          total += amount;
        }
      }
      return total;
    } catch (e) {
      throw Exception('Error al calcular total de deudas a pagar: $e');
    }
  }

  Future<double> getTotalDebtAmountWhereWeAreCreditor(String projectId, String userEmail) async {
    try {
      final snapshot = await _debtsCollection
          .where('projectId', isEqualTo: projectId)
          .where('debtor', isEqualTo: userEmail)
          .where('debtType', isEqualTo: DebtType.aCobrar.name)
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          final amount = (data['amount'] ?? 0).toDouble();
          total += amount;
        }
      }
      return total;
    } catch (e) {
      throw Exception('Error al calcular total de deudas por cobrar: $e');
    }
  }

  Future<double> getTotalPendingAmountWhereWeAreDebtor(String projectId, String userEmail) async {
    try {
      final snapshot = await _debtsCollection
          .where('projectId', isEqualTo: projectId)
          .where('debtor', isEqualTo: userEmail)
          .where('debtType', isEqualTo: DebtType.aPagar.name)
          .where('status', isEqualTo: DebtStatus.pending.name)
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          final amount = (data['amount'] ?? 0).toDouble();
          total += amount;
        }
      }
      return total;
    } catch (e) {
      throw Exception('Error al calcular total pendiente a pagar: $e');
    }
  }

  Future<double> getTotalPendingAmountWhereWeAreCreditor(String projectId, String userEmail) async {
    try {
      final snapshot = await _debtsCollection
          .where('projectId', isEqualTo: projectId)
          .where('debtor', isEqualTo: userEmail)
          .where('debtType', isEqualTo: DebtType.aCobrar.name)
          .where('status', isEqualTo: DebtStatus.pending.name)
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          final amount = (data['amount'] ?? 0).toDouble();
          total += amount;
        }
      }
      return total;
    } catch (e) {
      throw Exception('Error al calcular total pendiente por cobrar: $e');
    }
  }

  // Real-time listeners
  Stream<List<Debt>> listenToProjectDebts(String projectId) {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _debtsCollection
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>..['id'] = doc.id;
        return Debt.fromMap(data);
      }).toList();
    });
  }

  Stream<List<Debt>> listenToUserDebts(String userEmail) {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _debtsCollection
        .where('debtor', isEqualTo: userEmail)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>..['id'] = doc.id;
        return Debt.fromMap(data);
      }).toList();
    });
  }

  // Métodos para obtener deudas según nuestra posición (deudor o acreedor)
  Stream<List<Debt>> getDebtsWhereWeAreDebtor(String userEmail) {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _debtsCollection
        .where('debtor', isEqualTo: userEmail)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>..['id'] = doc.id;
        return Debt.fromMap(data);
      }).toList();
    });
  }

  Stream<List<Debt>> getDebtsWhereWeAreCreditor(String userEmail) {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _debtsCollection
        .where('debtor', isEqualTo: userEmail)
        .where('debtType', isEqualTo: DebtType.aCobrar.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>..['id'] = doc.id;
        return Debt.fromMap(data);
      }).toList();
    });
  }

  Stream<List<Debt>> getPendingDebtsWhereWeAreDebtor(String userEmail) {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _debtsCollection
        .where('debtor', isEqualTo: userEmail)
        .where('status', isEqualTo: DebtStatus.pending.name)
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>..['id'] = doc.id;
        return Debt.fromMap(data);
      }).toList();
    });
  }

  Stream<List<Debt>> getPendingDebtsWhereWeAreCreditor(String userEmail) {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _debtsCollection
        .where('debtor', isEqualTo: userEmail)
        .where('debtType', isEqualTo: DebtType.aCobrar.name)
        .where('status', isEqualTo: DebtStatus.pending.name)
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>..['id'] = doc.id;
        return Debt.fromMap(data);
      }).toList();
    });
  }
}