import 'package:flutter/foundation.dart';

import '../../data/event_repository.dart';
import '../../domain/event.dart';

enum EventStatus {
  initial,
  loading,
  ready,
  failure,
}

class EventProvider extends ChangeNotifier {
  EventProvider(this._eventRepository);

  final EventRepository _eventRepository;

  EventStatus _status = EventStatus.initial;
  List<Event> _events = const <Event>[];
  String? _errorMessage;
  String? _selectedEventId;

  EventStatus get status => _status;
  List<Event> get events => List.unmodifiable(_events);
  String? get errorMessage => _errorMessage;
  String? get selectedEventId => _selectedEventId;
  Event? get selectedEvent =>
      _selectedEventId == null ? null : eventById(_selectedEventId!);

  bool get isLoading => _status == EventStatus.loading;
  bool get hasEvents => _events.isNotEmpty;

  Event? eventById(String id) {
    for (final event in _events) {
      if (event.id == id) {
        return event;
      }
    }
    return null;
  }

  Future<void> loadEvents() async {
    _setStatus(EventStatus.loading);

    try {
      _events = await _eventRepository.fetchEvents();
      _errorMessage = null;
      _setStatus(EventStatus.ready);
    } catch (error) {
      _errorMessage = error.toString();
      _setStatus(EventStatus.failure);
    }
  }

  Future<void> saveEvent(Event event) async {
    try {
      final updatedEvent = event.copyWith(updatedAt: DateTime.now());

      await _eventRepository.saveEvent(updatedEvent);
      await loadEvents();
    } catch (error) {
      _errorMessage = error.toString();
      _setStatus(EventStatus.failure);
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _eventRepository.deleteEvent(id);

      if (_selectedEventId == id) {
        _selectedEventId = null;
      }

      await loadEvents();
    } catch (error) {
      _errorMessage = error.toString();
      _setStatus(EventStatus.failure);
    }
  }

  void selectEvent(String? id) {
    _selectedEventId = id;
    notifyListeners();
  }

  void _setStatus(EventStatus status) {
    _status = status;
    notifyListeners();
  }
}
