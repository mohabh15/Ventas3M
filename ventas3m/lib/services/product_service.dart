import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Obtener todos los productos de un proyecto
  Future<List<Product>> getProductsByProject(String projectId) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('projectId', isEqualTo: projectId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data()..['id'] = doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obtener un producto específico
  Future<Product?> getProduct(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return Product.fromJson(doc.data()!..['id'] = doc.id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Crear un nuevo producto
  Future<String> createProduct(Product product) async {
    try {
      final data = product.toJson()..remove('id'); // Remover ID temporal
      final docRef = await _firestore.collection('products').add(data);
      
      // Actualizar el ID con el ID real de Firestore
      await docRef.update({'id': docRef.id});
      
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Actualizar un producto existente
  Future<void> updateProduct(Product product) async {
    try {
      await _firestore
          .collection('products')
          .doc(product.id)
          .update(product.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // Eliminar un producto
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Obtener productos por categoría
  Future<List<Product>> getProductsByCategory(String projectId, String category) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('projectId', isEqualTo: projectId)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data()..['id'] = doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obtener todas las categorías únicas de un proyecto
  Future<List<String>> getCategoriesByProject(String projectId) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('projectId', isEqualTo: projectId)
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['category'] as String)
          .toSet()
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Búsqueda de productos por nombre o descripción
  Future<List<Product>> searchProducts(String projectId, String query) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('projectId', isEqualTo: projectId)
          .get();

      final products = snapshot.docs
          .map((doc) => Product.fromJson(doc.data()..['id'] = doc.id))
          .toList();

      // Filtrar localmente por nombre o descripción
      return products.where((product) =>
          product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Stream de productos en tiempo real
  Stream<List<Product>> getProductsStream(String projectId) {
    // Verificar si hay usuario autenticado antes de crear el stream
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('products')
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromJson(doc.data()..['id'] = doc.id))
            .toList());
  }
}