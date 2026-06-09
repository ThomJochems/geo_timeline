import 'package:flutter/material.dart';

import 'app_routes.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => _RoutePlaceholder(routeName: settings.name),
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
      AppRoutes.eventDetails => 'Event details',
      AppRoutes.eventEditor => 'Event editor',
      AppRoutes.settings => 'Settings',
      _ => 'Geo Timeline',
    };

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const SizedBox.expand(),
    );
  }
}
