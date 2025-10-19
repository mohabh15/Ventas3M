import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';

class NotificationPreferencesService {
  static const String _hasAskedNotificationPermission = 'hasAskedNotificationPermission';
  static const String _notificationsEnabled = 'notificationsEnabled';
  static const String _salesNotificationsEnabled = 'salesNotificationsEnabled';
  static const String _paymentNotificationsEnabled = 'paymentNotificationsEnabled';
  static const String _inventoryNotificationsEnabled = 'inventoryNotificationsEnabled';
  static const String _eventNotificationsEnabled = 'eventNotificationsEnabled';

  final SharedPreferences _prefs;
  final NotificationService _notificationService;

  NotificationPreferencesService._internal(this._prefs, this._notificationService);

  static Future<NotificationPreferencesService> create() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationService = NotificationService();
    return NotificationPreferencesService._internal(prefs, notificationService);
  }

  // Estado de permisos
  Future<bool> hasAskedForNotificationPermission() async {
    return _prefs.getBool(_hasAskedNotificationPermission) ?? false;
  }

  Future<void> setHasAskedForNotificationPermission(bool value) async {
    await _prefs.setBool(_hasAskedNotificationPermission, value);
  }

  // Estado general de notificaciones
  Future<bool> areNotificationsEnabled() async {
    return _prefs.getBool(_notificationsEnabled) ?? false;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool(_notificationsEnabled, value);

    if (value) {
      await _enableNotificationTopics();
    } else {
      await _disableNotificationTopics();
    }
  }

  // Tipos específicos de notificaciones
  Future<bool> areSalesNotificationsEnabled() async {
    return _prefs.getBool(_salesNotificationsEnabled) ?? true;
  }

  Future<void> setSalesNotificationsEnabled(bool value) async {
    await _prefs.setBool(_salesNotificationsEnabled, value);
    await _updateTopicSubscription('sales', value);
  }

  Future<bool> arePaymentNotificationsEnabled() async {
    return _prefs.getBool(_paymentNotificationsEnabled) ?? true;
  }

  Future<void> setPaymentNotificationsEnabled(bool value) async {
    await _prefs.setBool(_paymentNotificationsEnabled, value);
    await _updateTopicSubscription('payments', value);
  }

  Future<bool> areInventoryNotificationsEnabled() async {
    return _prefs.getBool(_inventoryNotificationsEnabled) ?? true;
  }

  Future<void> setInventoryNotificationsEnabled(bool value) async {
    await _prefs.setBool(_inventoryNotificationsEnabled, value);
    await _updateTopicSubscription('inventory', value);
  }

  Future<bool> areEventNotificationsEnabled() async {
    return _prefs.getBool(_eventNotificationsEnabled) ?? true;
  }

  Future<void> setEventNotificationsEnabled(bool value) async {
    await _prefs.setBool(_eventNotificationsEnabled, value);
    await _updateTopicSubscription('events', value);
  }

  // Verificar permisos del sistema
  Future<NotificationSettings> getSystemNotificationSettings() async {
    return await _notificationService.getNotificationSettings();
  }

  Future<bool> hasSystemPermission() async {
    try {
      final settings = await getSystemNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      return false;
    }
  }

  // Solicitar permisos del sistema
  Future<bool> requestSystemPermission() async {
    try {
      final settings = await _notificationService.requestPermission();
      final hasPermission = settings.authorizationStatus == AuthorizationStatus.authorized;

      if (hasPermission) {
        await setNotificationsEnabled(true);
      }

      return hasPermission;
    } catch (e) {
      return false;
    }
  }

  // Inicializar configuración por defecto
  Future<void> initializeDefaultSettings() async {
    if (!await hasAskedForNotificationPermission()) {
      // Configuración por defecto para nuevas instalaciones
      await setNotificationsEnabled(true);
      await setSalesNotificationsEnabled(true);
      await setPaymentNotificationsEnabled(true);
      await setInventoryNotificationsEnabled(true);
      await setEventNotificationsEnabled(true);
    }
  }

  // Obtener todas las preferencias actuales
  Future<Map<String, dynamic>> getAllPreferences() async {
    return {
      'hasAskedPermission': await hasAskedForNotificationPermission(),
      'notificationsEnabled': await areNotificationsEnabled(),
      'salesNotifications': await areSalesNotificationsEnabled(),
      'paymentNotifications': await arePaymentNotificationsEnabled(),
      'inventoryNotifications': await areInventoryNotificationsEnabled(),
      'eventNotifications': await areEventNotificationsEnabled(),
      'systemPermission': await hasSystemPermission(),
    };
  }

  // Métodos privados auxiliares
  Future<void> _enableNotificationTopics() async {
    if (await areSalesNotificationsEnabled()) {
      await _updateTopicSubscription('sales', true);
    }
    if (await arePaymentNotificationsEnabled()) {
      await _updateTopicSubscription('payments', true);
    }
    if (await areInventoryNotificationsEnabled()) {
      await _updateTopicSubscription('inventory', true);
    }
    if (await areEventNotificationsEnabled()) {
      await _updateTopicSubscription('events', true);
    }
  }

  Future<void> _disableNotificationTopics() async {
    await _updateTopicSubscription('sales', false);
    await _updateTopicSubscription('payments', false);
    await _updateTopicSubscription('inventory', false);
    await _updateTopicSubscription('events', false);
  }

  Future<void> _updateTopicSubscription(String topic, bool subscribe) async {
    try {
      if (subscribe) {
        await _notificationService.subscribeToTopic(topic);
      } else {
        await _notificationService.unsubscribeFromTopic(topic);
      }
    } catch (e) {
      // Manejar errores silenciosamente para no interrumpir la experiencia del usuario
    }
  }
}