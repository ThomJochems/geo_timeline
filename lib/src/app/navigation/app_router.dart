import 'package:flutter/material.dart';

import 'app_route.dart';

class AppRouter {
  const AppRouter._();

  static String get initialRoute => AppRoute.timeline.path;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final route = AppRoute.fromPath(settings.name);

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => _PendingScreen(route: route),
    );
  }
}

class _PendingScreen extends StatelessWidget {
  const _PendingScreen({required this.route});

  final AppRoute? route;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          route == null ? 'Route not found' : 'Screen pending: ${route!.name}',
        ),
      ),
    );
  }
}
