import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();
  List<Event> get _events => _eventService.events;

  bool _isLoading = false;
  String? _error;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Event> get recentEvents {
    final sortedEvents = _events.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return sortedEvents.take(5).toList();
  }

  /// Carga eventos desde Firestore para un usuario específico
  Future<void> loadEvents(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final events = await _eventService.getEventsFromFirestore(userId);
      _eventService.loadEvents(events);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crea un nuevo evento
  Future<bool> createEvent(Event event, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final createdEvent = await _eventService.createEventWithLocalUpdate(event, userId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Actualiza un evento existente
  Future<bool> updateEvent(Event event, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _eventService.updateEventInFirestore(event, userId);
      _eventService.updateEvent(event);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Elimina un evento
  Future<bool> deleteEvent(String eventId, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _eventService.deleteEventFromFirestore(userId, eventId);
      _eventService.removeEvent(eventId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}