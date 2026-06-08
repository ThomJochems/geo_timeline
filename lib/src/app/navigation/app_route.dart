enum AppRoute {
  timeline('/'),
  map('/map'),
  eventDetails('/events/details'),
  eventForm('/events/form'),
  settings('/settings');

  const AppRoute(this.path);

  final String path;

  static AppRoute? fromPath(String? path) {
    for (final route in AppRoute.values) {
      if (route.path == path) {
        return route;
      }
    }
    return null;
  }
}
