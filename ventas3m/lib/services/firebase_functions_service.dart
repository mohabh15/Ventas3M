import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';

class FirebaseFunctionsService {
  // Inicializar FirebaseFunctions con región específica (us-central1 por defecto)
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  // Método para obtener la instancia de funciones (útil para testing o configuración dinámica)
  FirebaseFunctions get functions => _functions;

  // Método para crear instancia con región específica si es necesario
  static FirebaseFunctions getFunctionsForRegion(String region) {
    return FirebaseFunctions.instanceFor(region: region);
  }

  /// Envía una notificación push a un dispositivo individual
  Future<void> sendNotification(
    String token,
    String title,
    String body, {
    Map<String, dynamic>? data,
  }) async {
    try {
      // Verificar autenticación antes de llamar a la función
      await _ensureAuthenticated();

      final callable = _functions.httpsCallable('sendNotification');
      await callable.call({
        'token': token,
        'title': title,
        'body': body,
        'data': data ?? {},
      });
    } catch (e) {
      throw FirebaseFunctionsException('Error al enviar notificación individual: ${e.toString()}');
    }
  }

  /// Envía una notificación push a múltiples dispositivos
  Future<void> sendNotificationToMultiple(
    List<String> tokens,
    String title,
    String body, {
    Map<String, dynamic>? data,
  }) async {
    try {
      // Verificar autenticación antes de llamar a la función
      await _ensureAuthenticated();

      final callable = _functions.httpsCallable('sendNotificationToMultiple');
      await callable.call({
        'tokens': tokens,
        'title': title,
        'body': body,
        'data': data ?? {},
      });
    } catch (e) {
      throw FirebaseFunctionsException('Error al enviar notificación múltiple: ${e.toString()}');
    }
  }

  /// Notifica que se agregó una nueva venta (llamada automática desde triggers)
  Future<void> notifySaleAdded(
    String projectId,
    Map<String, dynamic> saleData,
  ) async {
    try {
      // Verificar autenticación antes de llamar a la función
      await _ensureAuthenticated();

      final callable = _functions.httpsCallable('notifySaleAdded');
      await callable.call({
        'projectId': projectId,
        'saleData': saleData,
      });
    } catch (e) {
      throw FirebaseFunctionsException('Error al notificar venta agregada: ${e.toString()}');
    }
  }

  /// Envía notificación de venta completada
  Future<void> notifySaleCompleted(
    String projectId,
    String saleId,
    Map<String, dynamic> saleData,
  ) async {
    try {
      await _ensureAuthenticated();

      final callable = _functions.httpsCallable('notifySaleCompleted');
      await callable.call({
        'projectId': projectId,
        'saleId': saleId,
        'saleData': saleData,
      });
    } catch (e) {
      throw FirebaseFunctionsException('Error al notificar venta completada: ${e.toString()}');
    }
  }

  /// Envía notificación de pago recibido
  Future<void> notifyPaymentReceived(
    String projectId,
    String saleId,
    double amount,
    String paymentMethod,
  ) async {
    try {
      await _ensureAuthenticated();

      final callable = _functions.httpsCallable('notifyPaymentReceived');
      await callable.call({
        'projectId': projectId,
        'saleId': saleId,
        'amount': amount,
        'paymentMethod': paymentMethod,
      });
    } catch (e) {
      throw FirebaseFunctionsException('Error al notificar pago recibido: ${e.toString()}');
    }
  }

  /// Envía notificación de deuda pendiente
  Future<void> notifyDebtReminder(
    String projectId,
    String saleId,
    double debtAmount,
    String customerName,
  ) async {
    try {
      await _ensureAuthenticated();

      final callable = _functions.httpsCallable('notifyDebtReminder');
      await callable.call({
        'projectId': projectId,
        'saleId': saleId,
        'debtAmount': debtAmount,
        'customerName': customerName,
      });
    } catch (e) {
      throw FirebaseFunctionsException('Error al enviar recordatorio de deuda: ${e.toString()}');
    }
  }

  /// Envía notificación de stock bajo
  Future<void> notifyLowStock(
    String projectId,
    String productId,
    String productName,
    int currentStock,
    int minStock,
  ) async {
    try {
      await _ensureAuthenticated();

      final callable = _functions.httpsCallable('notifyLowStock');
      await callable.call({
        'projectId': projectId,
        'productId': productId,
        'productName': productName,
        'currentStock': currentStock,
        'minStock': minStock,
      });
    } catch (e) {
      throw FirebaseFunctionsException('Error al notificar stock bajo: ${e.toString()}');
    }
  }

  /// Verifica si el usuario está autenticado antes de llamar funciones
  Future<void> _ensureAuthenticated() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseFunctionsException('Usuario no autenticado');
    }

    // Verificar que el token de autenticación sea válido
    try {
      final token = await user.getIdToken();
      if (token == null || token.isEmpty) {
        throw FirebaseFunctionsException('Token de autenticación inválido');
      }
    } catch (e) {
      throw FirebaseFunctionsException('Error al obtener token de autenticación: ${e.toString()}');
    }
  }

  /// Método de diagnóstico para verificar la configuración de Firebase Functions
  Future<Map<String, dynamic>> diagnoseConfiguration() async {
    final Map<String, dynamic> diagnosis = {
      'firebaseInitialized': false,
      'functionsRegion': 'us-central1',
      'userAuthenticated': false,
      'authTokenValid': false,
      'functionsInstanceValid': false,
    };

    try {
      // Verificar inicialización de Firebase
      diagnosis['firebaseInitialized'] = true; // Firebase ya está inicializado en main.dart

      // Verificar autenticación del usuario
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      diagnosis['userAuthenticated'] = user != null;

      if (user != null) {
        try {
          final token = await user.getIdToken();
          diagnosis['authTokenValid'] = token != null && token.isNotEmpty;
        } catch (e) {
          diagnosis['authTokenError'] = e.toString();
        }
      }

      // Verificar instancia de funciones
      try {
        diagnosis['functionsInstanceValid'] = _functions != null;
      } catch (e) {
        diagnosis['functionsInstanceError'] = e.toString();
      }

    } catch (e) {
      diagnosis['diagnosisError'] = e.toString();
    }

    return diagnosis;
  }

  /// Método auxiliar para manejar excepciones de Firebase Functions
  FirebaseFunctionsException _handleFirebaseFunctionsException(dynamic e) {
    if (e is FirebaseFunctionsException) {
      return e;
    } else if (e is firebase_auth.FirebaseException) {
      switch (e.code) {
        case 'unauthenticated':
          return FirebaseFunctionsException('Usuario no autenticado para llamar funciones. Verifique que el usuario esté correctamente logueado.');
        case 'permission-denied':
          return FirebaseFunctionsException('Permisos insuficientes para llamar funciones. Contacte al administrador.');
        case 'not-found':
          return FirebaseFunctionsException('Función no encontrada. Verifique que las Cloud Functions estén desplegadas.');
        case 'already-exists':
          return FirebaseFunctionsException('Recurso ya existe');
        case 'resource-exhausted':
          return FirebaseFunctionsException('Límite de funciones excedido. Intente nuevamente en unos minutos.');
        case 'failed-precondition':
          return FirebaseFunctionsException('Condición previa no cumplida. Verifique los parámetros de la función.');
        case 'aborted':
          return FirebaseFunctionsException('Operación abortada');
        case 'out-of-range':
          return FirebaseFunctionsException('Parámetros fuera de rango');
        case 'unimplemented':
          return FirebaseFunctionsException('Función no implementada');
        case 'internal':
          return FirebaseFunctionsException('Error interno del servidor');
        case 'unavailable':
          return FirebaseFunctionsException('Servicio no disponible. Verifique su conexión a internet.');
        case 'data-loss':
          return FirebaseFunctionsException('Pérdida de datos');
        case 'deadline-exceeded':
          return FirebaseFunctionsException('Tiempo de espera excedido. La función tardó demasiado en responder.');
        default:
          return FirebaseFunctionsException('Error de Firebase Functions: ${e.message ?? e.code}');
      }
    } else if (e is Exception) {
      // Manejar errores específicos de conexión y región
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('no firebase app') || errorMessage.contains('app not initialized')) {
        return FirebaseFunctionsException('Firebase no está inicializado correctamente');
      } else if (errorMessage.contains('region') || errorMessage.contains('instancefor')) {
        return FirebaseFunctionsException('Error de configuración de región de Firebase Functions');
      } else if (errorMessage.contains('network') || errorMessage.contains('connection')) {
        return FirebaseFunctionsException('Error de conexión de red. Verifique su conexión a internet.');
      }
      return FirebaseFunctionsException('Error de Firebase Functions: ${e.toString()}');
    } else {
      return FirebaseFunctionsException('Error inesperado: ${e.toString()}');
    }
  }
}

/// Excepción personalizada para errores de Firebase Functions
class FirebaseFunctionsException implements Exception {
  final String message;
  const FirebaseFunctionsException(this.message);

  @override
  String toString() => message;
}