import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../services/auth_service.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void initialize() {}

  Future<List<Project>> getProjects() async {
    try {
      final userEmail = AuthService().currentUser?.email;     
      if (userEmail == null) return [];
      final snapshot = await _firestore.collection('projects').get();
      final projects = snapshot.docs.map((doc) => Project.fromJson(doc.data()..['id'] = doc.id)).toList();
      final filteredProjects = projects.where((project) => project.members.contains(userEmail)).toList();
      return filteredProjects;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createProject(Project project) async {
    try {
      final data = project.toJson()..remove('id');
      final docRef = await _firestore.collection('projects').add(data);
      await docRef.update({'id': docRef.id});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProject(Project project) async {
    await _firestore.collection('projects').doc(project.id).update(project.toJson());
  }

  Future<void> deleteProject(String projectId) async {
    await _firestore.collection('projects').doc(projectId).delete();
  }

  Future<List<User>> getUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => User.fromJson(doc.data()..['id'] = doc.id)).toList();
  }

  Future<void> createUser(User user) async {
    final docRef = await _firestore.collection('users').add(user.toJson());
    await docRef.update({'id': docRef.id});
  }

  Future<void> updateUser(User user) async {
    await _firestore.collection('users').doc(user.id).update(user.toJson());
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  Future<void> addMember(String projectId, String email) async {
    await _firestore.collection('projects').doc(projectId).update({
      'members': FieldValue.arrayUnion([email]),
    });
  }

  Future<void> removeMember(String projectId, String email) async {
    await _firestore.collection('projects').doc(projectId).update({
      'members': FieldValue.arrayRemove([email]),
    });
  }

  // Métodos para productos
  Future<List<Product>> getProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      return snapshot.docs.map((doc) => Product.fromMap(doc.data()..['id'] = doc.id)).toList();
    } catch (e) {
      debugPrint('Error getting products: $e');
      return [];
    }
  }

  Future<Product> createProduct(Product product) async {
    try {
      final data = product.toMap()..remove('id');
      final docRef = await _firestore.collection('products').add(data);
      await docRef.update({'id': docRef.id});
      return product.copyWith(id: docRef.id);
    } catch (e) {
      debugPrint('Error creating product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _firestore.collection('products').doc(product.id).update(product.toMap());
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      debugPrint('Error deleting product: $e');
      rethrow;
    }
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _firestore.collection('products')
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs.map((doc) => Product.fromMap(doc.data()..['id'] = doc.id)).toList();
    } catch (e) {
      debugPrint('Error getting products by category: $e');
      return [];
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final snapshot = await _firestore.collection('products')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();
      return snapshot.docs.map((doc) => Product.fromMap(doc.data()..['id'] = doc.id)).toList();
    } catch (e) {
      debugPrint('Error searching products: $e');
      return [];
    }
  }
}