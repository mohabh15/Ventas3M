import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream para escuchar cambios de autenticación
  Stream<firebase_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Obtener usuario actual
  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  // Método de login con email y contraseña
  Future<User> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw AuthException('Error al iniciar sesión');
      }

      // Actualizar última fecha de login en Firestore
      await _updateLastLogin(userCredential.user!.uid);

      return await _getUserFromFirebase(userCredential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Error inesperado durante el login: ${e.toString()}');
    }
  }

  // Método de login con Google
  Future<User> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException('Inicio de sesión con Google cancelado');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw AuthException('Error al iniciar sesión con Google');
      }

      // Actualizar última fecha de login en Firestore
      await _updateLastLogin(userCredential.user!.uid);

      return await _getUserFromFirebase(userCredential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Error inesperado durante el login con Google: ${e.toString()}');
    }
  }

  // Método de registro
  Future<User> register(String email, String password, String name, {String? phone}) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw AuthException('Error al crear la cuenta');
      }

      // Crear perfil de usuario en Firestore
      final user = User(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
        isEmailVerified: userCredential.user!.emailVerified,
      );

      await _firestore.collection('users').doc(user.id).set(user.toMap());

      // Enviar email de verificación
      await userCredential.user!.sendEmailVerification();

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Error inesperado durante el registro: ${e.toString()}');
    }
  }

  // Método de logout
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Error durante el logout: ${e.toString()}');
    }
  }

  // Verificar sesión actual
  Future<User?> checkCurrentSession() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        await _updateLastLogin(firebaseUser.uid);
        return await _getUserFromFirebase(firebaseUser);
      }
      return null;
    } catch (e) {
      throw AuthException('Error al verificar sesión: ${e.toString()}');
    }
  }

  // Enviar email de recuperación de contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Error al enviar email de recuperación: ${e.toString()}');
    }
  }

  // Actualizar perfil de usuario
  Future<User> updateProfile(String userId, {String? name, String? phone, String? photoUrl}) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      final updateData = <String, dynamic>{};

      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;

      updateData['lastLoginAt'] = DateTime.now();

      await userDoc.update(updateData);

      final updatedDoc = await userDoc.get();
      return User.fromMap(updatedDoc.data()!);
    } catch (e) {
      throw AuthException('Error al actualizar perfil: ${e.toString()}');
    }
  }

  // Método auxiliar para obtener usuario desde Firebase
  Future<User> _getUserFromFirebase(firebase_auth.User firebaseUser) async {
    try {
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        return User.fromMap({
          ...userData,
          'id': firebaseUser.uid,
          'isEmailVerified': firebaseUser.emailVerified,
        });
      } else {
        // Crear usuario básico si no existe en Firestore
        final basicUser = User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'Usuario',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL,
          isEmailVerified: firebaseUser.emailVerified,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(firebaseUser.uid).set(basicUser.toMap());
        return basicUser;
      }
    } catch (e) {
      throw AuthException('Error al obtener datos del usuario: ${e.toString()}');
    }
  }

  // Método auxiliar para actualizar última fecha de login
  Future<void> _updateLastLogin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastLoginAt': DateTime.now(),
      });
    } catch (e) {
      // No lanzar error aquí, solo warning silencioso para debugging
      // Warning: Could not update last login time (removed print for production)
    }
  }

  // Método auxiliar para manejar excepciones de Firebase Auth
  AuthException _handleFirebaseAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException('Usuario no encontrado');
      case 'wrong-password':
        return AuthException('Contraseña incorrecta');
      case 'email-already-in-use':
        return AuthException('El email ya está registrado');
      case 'weak-password':
        return AuthException('La contraseña es muy débil');
      case 'invalid-email':
        return AuthException('Email inválido');
      case 'user-disabled':
        return AuthException('Usuario deshabilitado');
      case 'too-many-requests':
        return AuthException('Demasiados intentos. Intente más tarde');
      case 'network-request-failed':
        return AuthException('Error de conexión. Verifique su conexión a internet');
      default:
        return AuthException('Error de autenticación: ${e.message}');
    }
  }
}

// Excepción personalizada para errores de autenticación
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}