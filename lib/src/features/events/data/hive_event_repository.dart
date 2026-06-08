import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/storage_keys.dart';
import '../domain/event.dart';
import 'event_repository.dart';

class HiveEventRepository implements EventRepository {
  late final Box<Event> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Event>(StorageKeys.eventsBox);
  }

  @override
  Future<List<Event>> fetchEvents() async {
    final events = _box.values.toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

    return events;
  }

  @override
  Future<Event?> fetchEventById(String id) async {
    return _box.get(id);
  }

  @override
  Future<void> saveEvent(Event event) async {
    await _box.put(event.id, event);
  }

  @override
  Future<void> deleteEvent(String id) async {
    await _box.delete(id);
  }
}
