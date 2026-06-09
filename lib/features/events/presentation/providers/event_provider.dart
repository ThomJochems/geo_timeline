import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/models/event.dart';
import '../../domain/repositories/event_repository.dart';

class EventProvider extends ChangeNotifier {
  EventProvider(this._eventRepository);

  final EventRepository _eventRepository;
  StreamSubscription<List<Event>>? _eventsSubscription;

  List<Event> _events = const [];
  Event? _selectedEvent;
  bool _isLoading = false;
  String? _errorMessage;

  List<Event> get events => _events;
  Event? get selectedEvent => _selectedEvent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasEvents => _events.isNotEmpty;

  Future<void> loadEvents() async {
    _setLoading(true);

    try {
      _events = await _eventRepository.getEvents();
      _eventsSubscription ??= _eventRepository.watchEvents().listen((events) {
        _events = events;
        _clearSelectionIfDeleted();
        notifyListeners();
      });
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> selectEvent(String id) async {
    try {
      _selectedEvent = await _eventRepository.getEventById(id);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
    }

    notifyListeners();
  }

  void clearSelectedEvent() {
    _selectedEvent = null;
    notifyListeners();
  }

  Future<void> saveEvent(Event event) async {
    try {
      final eventToSave = event.copyWith(updatedAt: DateTime.now());
      await _eventRepository.saveEvent(eventToSave);
      _selectedEvent = eventToSave;
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _eventRepository.deleteEvent(id);
      if (_selectedEvent?.id == id) {
        _selectedEvent = null;
      }
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearSelectionIfDeleted() {
    final selectedEvent = _selectedEvent;
    if (selectedEvent == null) {
      return;
    }

    if (!_events.any((event) => event.id == selectedEvent.id)) {
      _selectedEvent = null;
    }
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _eventRepository.close();
    super.dispose();
  }
}
