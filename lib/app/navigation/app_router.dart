import 'package:flutter/material.dart';

import '../../features/events/domain/models/event.dart';
import '../../features/events/presentation/pages/create_event_page.dart';
import '../../features/events/presentation/pages/event_detail_page.dart';
import '../../features/events/presentation/pages/timeline_page.dart';
import '../../features/map/presentation/screens/map_page.dart';
import 'app_routes.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) {
        final arguments = settings.arguments;

        return switch (settings.name) {
          AppRoutes.timeline => const TimelinePage(),
          AppRoutes.map => const MapPage(),
          AppRoutes.createEvent => const CreateEventPage(),
          AppRoutes.eventDetail => EventDetailPage(
            event: arguments is Event ? arguments : null,
          ),
          _ => _RoutePlaceholder(routeName: settings.name),
        };
      },
    );
  }
}

class _RoutePlaceholder extends StatelessWidget {
  const _RoutePlaceholder({required this.routeName});

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    final title = switch (routeName) {
      AppRoutes.timeline => 'Timeline',
      AppRoutes.map => 'Map',
      AppRoutes.eventDetail => 'Event details',
      AppRoutes.createEvent => 'Create event',
      AppRoutes.settings => 'Settings',
      _ => 'Geo Timeline',
    };

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const SizedBox.expand(),
    );
  }
}
