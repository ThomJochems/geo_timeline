import '../../data/mock/mock_events.dart';
import '../../domain/models/event.dart';

List<Event> timelineEventsWithSaved(List<Event> savedEvents) {
  return [...MockEvents.timeline, ...savedEvents]..sort(compareEventsByStart);
}

List<Event> filterEventsByCategory(
  List<Event> events,
  EventCategory? category,
) {
  if (category == null) {
    return events;
  }

  return events
      .where((event) => event.category == category)
      .toList(growable: false);
}

int compareEventsByStart(Event first, Event second) {
  return first.startDate.compareTo(second.startDate);
}
