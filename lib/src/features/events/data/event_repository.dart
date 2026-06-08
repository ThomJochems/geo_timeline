import '../domain/event.dart';

abstract interface class EventRepository {
  Future<List<Event>> fetchEvents();

  Future<Event?> fetchEventById(String id);

  Future<void> saveEvent(Event event);

  Future<void> deleteEvent(String id);
}
