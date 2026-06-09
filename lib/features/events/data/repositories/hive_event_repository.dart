import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/event.dart';
import '../../domain/repositories/event_repository.dart';

class HiveEventRepository implements EventRepository {
  static const _boxName = 'events';

  Box<Map>? _box;
  final StreamController<List<Event>> _eventsController =
      StreamController<List<Event>>.broadcast();

  Future<void> initialize() async {
    _box = await Hive.openBox<Map>(_boxName);
    _emitEvents();
  }

  Box<Map> get _eventBox {
    final box = _box;
    if (box == null || !box.isOpen) {
      throw StateError('HiveEventRepository has not been initialized.');
    }
    return box;
  }

  @override
  Future<List<Event>> getEvents() async {
    return _sortedEvents();
  }

  @override
  Future<Event?> getEventById(String id) async {
    final json = _eventBox.get(id);
    if (json == null) {
      return null;
    }

    return Event.fromJson(json);
  }

  @override
  Future<void> saveEvent(Event event) async {
    await _eventBox.put(event.id, event.toJson());
    _emitEvents();
  }

  @override
  Future<void> deleteEvent(String id) async {
    await _eventBox.delete(id);
    _emitEvents();
  }

  @override
  Stream<List<Event>> watchEvents() {
    return _eventsController.stream;
  }

  @override
  Future<void> close() async {
    await _eventsController.close();
    await _box?.close();
  }

  void _emitEvents() {
    if (!_eventsController.isClosed) {
      _eventsController.add(_sortedEvents());
    }
  }

  List<Event> _sortedEvents() {
    final events = _eventBox.values.map(Event.fromJson).toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

    return List.unmodifiable(events);
  }
}
