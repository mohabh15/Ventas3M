import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/sale.dart';
import '../models/sale_status.dart';
import '../models/payment_method.dart';
import 'firebase_functions_service.dart';

class SaleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctionsService _functionsService = FirebaseFunctionsService();
  List<Sale> _sales = [];

  List<Sale> get sales => List.unmodifiable(_sales);

  void addSale(Sale sale) {
    _sales.add(sale);
  }

  void removeSale(String saleId) {
    _sales.removeWhere((sale) => sale.id == saleId);
  }

  Sale? getSaleById(String saleId) {
    try {
      return _sales.firstWhere((sale) => sale.id == saleId);
    } catch (e) {
      return null;
    }
  }

  void updateSale(Sale updatedSale) {
    final index = _sales.indexWhere((sale) => sale.id == updatedSale.id);
    if (index != -1) {
      _sales[index] = updatedSale;
    }
  }

  List<Sale> getSalesByProject(String projectId) {
    return _sales.where((sale) => sale.projectId == projectId).toList();
  }

  List<Sale> getSalesByProduct(String productId) {
    return _sales.where((sale) => sale.productId == productId).toList();
  }

  List<Sale> getSalesBySeller(String sellerId) {
    return _sales.where((sale) => sale.sellerId == sellerId).toList();
  }

  List<Sale> getSalesByCustomer(String customerName) {
    return _sales.where((sale) => sale.customerName == customerName).toList();
  }

  List<Sale> getSalesByStatus(SaleStatus status) {
    return _sales.where((sale) => sale.status == status).toList();
  }

  List<Sale> getSalesByPaymentMethod(PaymentMethod paymentMethod) {
    return _sales.where((sale) => sale.paymentMethod == paymentMethod).toList();
  }

  List<Sale> getPendingSales() {
    return getSalesByStatus(SaleStatus.pending);
  }

  List<Sale> getCompletedSales() {
    return getSalesByStatus(SaleStatus.completed);
  }

  List<Sale> getCancelledSales() {
    return getSalesByStatus(SaleStatus.cancelled);
  }

  List<Sale> getRefundedSales() {
    return getSalesByStatus(SaleStatus.refunded);
  }

  List<Sale> getSalesWithDebt() {
    return _sales.where((sale) => sale.hasDebt).toList();
  }

  List<Sale> getSalesByDateRange(DateTime startDate, DateTime endDate) {
    return _sales.where((sale) {
      return sale.saleDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             sale.saleDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  double getTotalSalesAmount(String projectId) {
    return getSalesByProject(projectId)
        .where((sale) => sale.isCompleted)
        .fold(0.0, (accumulator, sale) => accumulator + sale.totalAmount);
  }

  double getTotalProfit(String projectId) {
    return getSalesByProject(projectId)
        .where((sale) => sale.isCompleted)
        .fold(0.0, (accumulator, sale) => accumulator + sale.profit);
  }

  double getTotalDebt(String projectId) {
    return getSalesByProject(projectId)
        .where((sale) => sale.hasDebt)
        .fold(0.0, (accumulator, sale) => accumulator + (sale.debt ?? 0.0));
  }

  int getTotalUnitsSold(String projectId) {
    return getSalesByProject(projectId)
        .where((sale) => sale.isCompleted)
        .fold(0, (accumulator, sale) => accumulator + sale.quantity);
  }

  Map<String, double> getSalesByPaymentMethodReport(String projectId) {
    final projectSales = getSalesByProject(projectId);
    final report = <String, double>{};

    for (final paymentMethod in PaymentMethod.values) {
      final methodSales = projectSales
          .where((sale) => sale.paymentMethod == paymentMethod && sale.isCompleted)
          .fold(0.0, (accumulator, sale) => accumulator + sale.totalAmount);
      report[paymentMethod.displayName] = methodSales;
    }

    return report;
  }

  Map<String, double> getDailySalesReport(String projectId, int days) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    final dailySales = <String, double>{};

    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final dateStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
      final daySales = getSalesByDateRange(date, date.add(const Duration(days: 1)))
          .where((sale) => sale.projectId == projectId && sale.isCompleted)
          .fold(0.0, (accumulator, sale) => accumulator + sale.totalAmount);
      dailySales[dateStr] = daySales;
    }

    return dailySales;
  }

  void clearAllSales() {
    _sales.clear();
  }

  int get salesCount => _sales.length;

  void loadSales(List<Sale> sales) {
    _sales = List.from(sales);
  }

  // ========== MÉTODOS DE FIREBASE/FIRESTORE ==========

  /// Crea una nueva venta en Firestore
  Future<String> createSaleInFirestore(Sale sale) async {
    try {
      final data = sale.toMap();
      data.remove('id'); // Firestore generará el ID automáticamente

      final docRef = await _firestore
          .collection('projects')
          .doc(sale.projectId)
          .collection('sales')
          .add(data);

      // Notificar a través de Firebase Functions que se agregó una venta
      try {
        await _functionsService.notifySaleAdded(sale.projectId, {
          'id': docRef.id,
          'customerName': sale.customerName,
          'totalAmount': sale.totalAmount,
          'saleDate': sale.saleDate.toIso8601String(),
          'status': sale.status.toString(),
        });
      } catch (functionsError) {
        // Log error pero no fallar la operación principal
        print('Error al notificar venta agregada: $functionsError');
      }

      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear venta en Firestore: $e');
    }
  }

  /// Obtiene todas las ventas de un proyecto desde Firestore
  Future<List<Sale>> getSalesFromFirestore(String projectId) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('sales')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data()..['id'] = doc.id;
        return Sale.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener ventas desde Firestore: $e');
    }
  }

  /// Obtiene una venta específica desde Firestore
  Future<Sale?> getSaleFromFirestore(String projectId, String saleId) async {
    try {
      final doc = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('sales')
          .doc(saleId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!..['id'] = doc.id;
      return Sale.fromMap(data);
    } catch (e) {
      throw Exception('Error al obtener venta desde Firestore: $e');
    }
  }

  /// Actualiza una venta en Firestore
  Future<void> updateSaleInFirestore(Sale sale) async {
    try {
      final data = sale.toMap();
      await _firestore
          .collection('projects')
          .doc(sale.projectId)
          .collection('sales')
          .doc(sale.id)
          .update(data);
    } catch (e) {
      throw Exception('Error al actualizar venta en Firestore: $e');
    }
  }

  /// Elimina una venta de Firestore
  Future<void> deleteSaleFromFirestore(String projectId, String saleId) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('sales')
          .doc(saleId)
          .delete();
    } catch (e) {
      throw Exception('Error al eliminar venta de Firestore: $e');
    }
  }

  /// Escucha cambios en tiempo real de las ventas de un proyecto
  Stream<List<Sale>> listenToSales(String projectId) {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('projects')
        .doc(projectId)
        .collection('sales')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data()..['id'] = doc.id;
        return Sale.fromMap(data);
      }).toList();
    });
  }

  /// Crea venta con validación de stock
  Future<Sale> createSaleWithStockValidation(Sale sale) async {
    // Aquí se integraría con el servicio de stock para validar disponibilidad
    // Por ahora, solo creamos la venta
    final saleId = await createSaleInFirestore(sale);
    final createdSale = sale.copyWith(id: saleId);

    // Actualizar lista local
    _sales.add(createdSale);

    return createdSale;
  }

  /// Marca una venta como completada y envía notificaciones
  Future<void> completeSale(String projectId, String saleId) async {
    try {
      // Obtener la venta actual
      final sale = await getSaleFromFirestore(projectId, saleId);
      if (sale == null) {
        throw Exception('Venta no encontrada');
      }

      // Actualizar estado a completada
      final completedSale = sale.copyWith(status: SaleStatus.completed);
      await updateSaleInFirestore(completedSale);

      // Actualizar lista local
      updateSale(completedSale);

      // Enviar notificación a través de Firebase Functions
      try {
        await _functionsService.notifySaleCompleted(projectId, saleId, {
          'customerName': sale.customerName,
          'totalAmount': sale.totalAmount,
          'saleDate': sale.saleDate.toIso8601String(),
        });
      } catch (functionsError) {
        print('Error al notificar venta completada: $functionsError');
      }
    } catch (e) {
      throw Exception('Error al completar venta: $e');
    }
  }

  /// Registra un pago recibido y envía notificaciones
  Future<void> registerPayment(String projectId, String saleId, double amount, String paymentMethod) async {
    try {
      // Obtener la venta actual
      final sale = await getSaleFromFirestore(projectId, saleId);
      if (sale == null) {
        throw Exception('Venta no encontrada');
      }

      // Actualizar deuda si existe
      double remainingDebt = (sale.debt ?? 0.0) - amount;
      if (remainingDebt < 0) remainingDebt = 0.0;

      final updatedSale = sale.copyWith(debt: remainingDebt > 0 ? remainingDebt : null);
      await updateSaleInFirestore(updatedSale);

      // Actualizar lista local
      updateSale(updatedSale);

      // Enviar notificación a través de Firebase Functions
      try {
        await _functionsService.notifyPaymentReceived(
          projectId,
          saleId,
          amount,
          paymentMethod,
        );
      } catch (functionsError) {
        print('Error al notificar pago recibido: $functionsError');
      }
    } catch (e) {
      throw Exception('Error al registrar pago: $e');
    }
  }

  /// Envía recordatorio de deuda para una venta específica
  Future<void> sendDebtReminder(String projectId, String saleId) async {
    try {
      // Obtener la venta actual
      final sale = await getSaleFromFirestore(projectId, saleId);
      if (sale == null) {
        throw Exception('Venta no encontrada');
      }

      if (sale.debt == null || sale.debt! <= 0) {
        throw Exception('La venta no tiene deuda pendiente');
      }

      // Enviar recordatorio a través de Firebase Functions
      await _functionsService.notifyDebtReminder(
        projectId,
        saleId,
        sale.debt!,
        sale.customerName,
      );
    } catch (e) {
      throw Exception('Error al enviar recordatorio de deuda: $e');
    }
  }

  /// Envía notificaciones personalizadas usando Firebase Functions
  Future<void> sendCustomNotification(
    String title,
    String body, {
    String? token,
    List<String>? tokens,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (token != null && token.isNotEmpty) {
        await _functionsService.sendNotification(token, title, body, data: data);
      } else if (tokens != null && tokens.isNotEmpty) {
        await _functionsService.sendNotificationToMultiple(tokens, title, body, data: data);
      } else {
        throw Exception('Debe proporcionar al menos un token o una lista de tokens');
      }
    } catch (e) {
      throw Exception('Error al enviar notificación personalizada: $e');
    }
  }

  /// Obtiene estadísticas de ventas desde Firestore
  Future<Map<String, dynamic>> getSalesStatsFromFirestore(String projectId) async {
    try {
      final sales = await getSalesFromFirestore(projectId);
      final completedSales = sales.where((sale) => sale.isCompleted).toList();

      return {
        'totalSales': sales.length,
        'totalAmount': completedSales.fold(0.0, (accumulator, sale) => accumulator + sale.totalAmount),
        'totalProfit': completedSales.fold(0.0, (accumulator, sale) => accumulator + sale.profit),
        'totalDebt': sales.where((sale) => sale.hasDebt).fold(0.0, (accumulator, sale) => accumulator + (sale.debt ?? 0.0)),
        'completedSales': completedSales.length,
        'pendingSales': sales.where((sale) => sale.isPending).length,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }
}