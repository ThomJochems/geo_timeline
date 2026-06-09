import '../models/event.dart';

abstract interface class EventRepository {
  Future<List<Event>> getEvents();

  Future<Event?> getEventById(String id);

  Future<void> saveEvent(Event event);

  Future<void> deleteEvent(String id);

  Stream<List<Event>> watchEvents();

  Future<void> close();
}
