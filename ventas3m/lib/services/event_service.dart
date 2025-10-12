import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Event> _events = [];

  List<Event> get events => List.unmodifiable(_events);

  void addEvent(Event event) {
    _events.add(event);
  }

  void removeEvent(String eventId) {
    _events.removeWhere((event) => event.id == eventId);
  }

  Event? getEventById(String eventId) {
    try {
      return _events.firstWhere((event) => event.id == eventId);
    } catch (e) {
      return null;
    }
  }

  void updateEvent(Event updatedEvent) {
    final index = _events.indexWhere((event) => event.id == updatedEvent.id);
    if (index != -1) {
      _events[index] = updatedEvent;
    }
  }

  List<Event> getEventsByDateRange(DateTime startDate, DateTime endDate) {
    return _events.where((event) {
      return event.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             event.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  void clearAllEvents() {
    _events.clear();
  }

  int get eventsCount => _events.length;

  void loadEvents(List<Event> events) {
    _events = List.from(events);
  }

  // ========== MÉTODOS DE FIREBASE/FIRESTORE ==========

  /// Crea un nuevo evento en Firestore
  Future<String> createEventInFirestore(Event event, String userId) async {
    try {
      final data = event.toMap();
      data.remove('id'); // Firestore generará el ID automáticamente

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .add(data);

      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear evento en Firestore: $e');
    }
  }

  /// Obtiene todos los eventos de un usuario desde Firestore
  Future<List<Event>> getEventsFromFirestore(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data()..['id'] = doc.id;
        return Event.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener eventos desde Firestore: $e');
    }
  }

  /// Obtiene un evento específico desde Firestore
  Future<Event?> getEventFromFirestore(String userId, String eventId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!..['id'] = doc.id;
      return Event.fromMap(data);
    } catch (e) {
      throw Exception('Error al obtener evento desde Firestore: $e');
    }
  }

  /// Actualiza un evento en Firestore
  Future<void> updateEventInFirestore(Event event, String userId) async {
    try {
      final data = event.toMap();
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(event.id)
          .update(data);
    } catch (e) {
      throw Exception('Error al actualizar evento en Firestore: $e');
    }
  }

  /// Elimina un evento de Firestore
  Future<void> deleteEventFromFirestore(String userId, String eventId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .delete();
    } catch (e) {
      throw Exception('Error al eliminar evento de Firestore: $e');
    }
  }

  /// Escucha cambios en tiempo real de los eventos de un usuario
  Stream<List<Event>> listenToEvents(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('events')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data()..['id'] = doc.id;
        return Event.fromMap(data);
      }).toList();
    });
  }

  /// Crea evento y actualiza lista local
  Future<Event> createEventWithLocalUpdate(Event event, String userId) async {
    final eventId = await createEventInFirestore(event, userId);
    final createdEvent = event.copyWith(id: eventId);

    // Actualizar lista local
    _events.add(createdEvent);

    return createdEvent;
  }
}