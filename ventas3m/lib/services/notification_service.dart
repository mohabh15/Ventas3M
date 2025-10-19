import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getter público para acceder al FirebaseMessaging (necesario para el AuthProvider)
  FirebaseMessaging get firebaseMessaging => _firebaseMessaging;

  // Inicialización del servicio
  Future<void> initialize() async {
    try {
      // Solicitar permisos de notificación
      await requestPermission();

      // Configurar handlers para mensajes
      _setupMessageHandlers();
    } catch (e) {
      throw NotificationException('Error al inicializar notificaciones: ${e.toString()}');
    }
  }

  // Inicializar con userId para guardar token automáticamente
  Future<void> initializeWithUser(String userId) async {
    try {
      // Solicitar permisos de notificación
      await requestPermission();

      // Obtener y guardar token FCM inicial
      await getAndSaveToken(userId);

      // Configurar handlers para mensajes
      _setupMessageHandlers();
    } catch (e) {
      throw NotificationException('Error al inicializar notificaciones con usuario: ${e.toString()}');
    }
  }

  // Solicitar permisos de notificación
  Future<NotificationSettings> requestPermission() async {
    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      return settings;
    } catch (e) {
      throw NotificationException('Error al solicitar permisos: ${e.toString()}');
    }
  }

  // Obtener token FCM
  Future<String?> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      throw NotificationException('Error al obtener token FCM: ${e.toString()}');
    }
  }

  // Guardar token FCM en Firestore
  Future<void> saveTokenToFirestore(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    } catch (e) {
      throw NotificationException('Error al guardar token FCM: ${e.toString()}');
    }
  }

  // Obtener token y guardarlo automáticamente
  Future<String?> getAndSaveToken(String userId) async {
    try {
      String? token = await getToken();
      if (token != null && userId.isNotEmpty) {
        await saveTokenToFirestore(userId, token);
      }
      return token;
    } catch (e) {
      throw NotificationException('Error al obtener y guardar token FCM: ${e.toString()}');
    }
  }

  // Obtener APNs token para iOS (opcional)
  Future<String?> getAPNSToken() async {
    try {
      String? token = await _firebaseMessaging.getAPNSToken();
      return token;
    } catch (e) {
      throw NotificationException('Error al obtener token APNs: ${e.toString()}');
    }
  }

  // Verificar permisos actuales
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      return await _firebaseMessaging.getNotificationSettings();
    } catch (e) {
      throw NotificationException('Error al obtener configuración de permisos: ${e.toString()}');
    }
  }

  // Suscribirse a un tópico
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      throw NotificationException('Error al suscribirse al tópico $topic: ${e.toString()}');
    }
  }

  // Desuscribirse de un tópico
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      throw NotificationException('Error al desuscribirse del tópico $topic: ${e.toString()}');
    }
  }

  // Configurar handlers para mensajes
  void _setupMessageHandlers() {
    // Handler para mensajes en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    // Handler para cuando se toca una notificación y la app está en background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageOpenedApp(message);
    });

    // Handler para cuando se lanza la app desde una notificación terminada
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleInitialMessage(message);
      }
    });

    // Handler para cuando el token FCM cambia
    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      _handleTokenRefresh(token);
    });
  }

  // Manejar actualización de token FCM
  void _handleTokenRefresh(String token) {
    // Obtener el usuario actual y actualizar el token
    // Esto requiere acceso al AuthService, pero para mantener la separación de responsabilidades,
    // se puede manejar desde el AuthProvider o desde donde se inicialice el NotificationService
  }

  // Método para actualizar token con userId específico
  Future<void> updateTokenForUser(String userId, String token) async {
    try {
      await saveTokenToFirestore(userId, token);
    } catch (e) {
      throw NotificationException('Error al actualizar token para usuario: ${e.toString()}');
    }
  }

  // Manejar mensaje en foreground
  void _handleForegroundMessage(RemoteMessage message) {
    // Aquí puedes implementar la lógica para mostrar notificaciones locales
    // o actualizar el estado de la aplicación cuando llega un mensaje
  }

  // Manejar cuando se toca una notificación y la app se abre
  void _handleMessageOpenedApp(RemoteMessage message) {
    // Aquí puedes navegar a una pantalla específica basada en el mensaje
  }

  // Manejar cuando la app se lanza desde una notificación
  void _handleInitialMessage(RemoteMessage message) {
    // Aquí puedes navegar a una pantalla específica basada en el mensaje
  }

  // Método auxiliar para manejar excepciones de Firebase Messaging
  NotificationException _handleFirebaseMessagingException(dynamic e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          return NotificationException('Permisos denegados para notificaciones');
        case 'not-available':
          return NotificationException('Servicio de mensajería no disponible');
        case 'disabled':
          return NotificationException('Servicio de mensajería deshabilitado');
        default:
          return NotificationException('Error de Firebase Messaging: ${e.message}');
      }
    } else {
      return NotificationException('Error inesperado: ${e.toString()}');
    }
  }
}

// Excepción personalizada para errores de notificaciones
class NotificationException implements Exception {
  final String message;
  const NotificationException(this.message);

  @override
  String toString() => message;
}