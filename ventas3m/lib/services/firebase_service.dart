import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project.dart';
import '../models/user.dart';
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

  Future<Project?> getProjectById(String projectId) async {
    try {
      final doc = await _firestore.collection('projects').doc(projectId).get();
      if (doc.exists) {
        return Project.fromJson(doc.data()!..['id'] = doc.id);
      }
      return null;
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
}