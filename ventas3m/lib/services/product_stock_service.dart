import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/product.dart';

class ProductStockService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener todos los stocks de un producto específico
  Future<List<ProductStock>> getStockByProduct(String productId) async {
    try {
      final snapshot = await _firestore
          .collection('productStock')
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ProductStock.fromJson(doc.data()..['id'] = doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obtener todos los stocks de un proyecto
  Future<List<ProductStock>> getStockByProject(String projectId) async {
    try {
      final snapshot = await _firestore
          .collection('productStock')
          .where('projectId', isEqualTo: projectId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ProductStock.fromJson(doc.data()..['id'] = doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obtener un stock específico
  Future<ProductStock?> getStock(String stockId) async {
    try {
      final doc = await _firestore.collection('productStock').doc(stockId).get();
      if (doc.exists) {
        return ProductStock.fromJson(doc.data()!..['id'] = doc.id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Crear un nuevo stock
  Future<String> createStock(ProductStock stock) async {
    try {
      final data = stock.toJson()..remove('id'); // Remover ID temporal
      final docRef = await _firestore.collection('productStock').add(data);

      // Actualizar el ID con el ID real de Firestore
      await docRef.update({'id': docRef.id});

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Actualizar un stock existente
  Future<void> updateStock(ProductStock stock) async {
    try {
      await _firestore
          .collection('productStock')
          .doc(stock.id)
          .update(stock.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // Eliminar un stock
  Future<void> deleteStock(String stockId) async {
    try {
      await _firestore.collection('productStock').doc(stockId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Reducir cantidad de un stock específico
  Future<bool> reduceStockQuantity(String stockId, int quantityToReduce) async {
    try {
      final stock = await getStock(stockId);
      if (stock == null) {
        throw Exception('Stock no encontrado');
      }

      if (stock.quantity < quantityToReduce) {
        throw Exception('Cantidad insuficiente en el stock seleccionado. Disponible: ${stock.quantity}');
      }

      final newQuantity = stock.quantity - quantityToReduce;
      final updatedStock = stock.copyWith(
        quantity: newQuantity,
        updatedAt: DateTime.now(),
      );

      await updateStock(updatedStock);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Aumentar cantidad de un stock específico
  Future<bool> increaseStockQuantity(String stockId, int quantityToIncrease) async {
    try {
      final stock = await getStock(stockId);
      if (stock == null) {
        throw Exception('Stock no encontrado');
      }

      final newQuantity = stock.quantity + quantityToIncrease;
      final updatedStock = stock.copyWith(
        quantity: newQuantity,
        updatedAt: DateTime.now(),
      );

      await updateStock(updatedStock);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Obtener stock por responsable
  Future<List<ProductStock>> getStockByResponsible(String projectId, String responsibleId) async {
    try {
      final snapshot = await _firestore
          .collection('productStock')
          .where('projectId', isEqualTo: projectId)
          .where('responsibleId', isEqualTo: responsibleId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ProductStock.fromJson(doc.data()..['id'] = doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obtener stock por proveedor
  Future<List<ProductStock>> getStockByProvider(String projectId, String providerId) async {
    try {
      final snapshot = await _firestore
          .collection('productStock')
          .where('projectId', isEqualTo: projectId)
          .where('providerId', isEqualTo: providerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ProductStock.fromJson(doc.data()..['id'] = doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Calcular stock total de un producto
  Future<int> getTotalStockForProduct(String productId) async {
    try {
      final stocks = await getStockByProduct(productId);
      int total = 0;
      for (var stock in stocks) {
        total += stock.quantity;
      }
      return total;
    } catch (e) {
      rethrow;
    }
  }

  // Stream de stock de un producto en tiempo real
  Stream<List<ProductStock>> getStockStreamByProduct(String productId) {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('productStock')
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductStock.fromJson(doc.data()..['id'] = doc.id))
            .toList());
  }

  // Stream de stock de un proyecto en tiempo real
  Stream<List<ProductStock>> getStockStreamByProject(String projectId) {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('productStock')
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductStock.fromJson(doc.data()..['id'] = doc.id))
            .toList());
  }
}