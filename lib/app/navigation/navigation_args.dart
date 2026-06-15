class MapPageArgs {
  const MapPageArgs({
    this.visibleEventIds,
    this.focusEventId,
  });

  final Set<String>? visibleEventIds;
  final String? focusEventId;
}

class TimelinePageArgs {
  const TimelinePageArgs({this.focusEventId});

  final String? focusEventId;
}
