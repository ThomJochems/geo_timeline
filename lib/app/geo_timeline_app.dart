import 'package:flutter/material.dart';

import 'navigation/app_router.dart';
import 'navigation/app_routes.dart';
import 'theme/app_theme.dart';

class GeoTimelineApp extends StatelessWidget {
  const GeoTimelineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geo Timeline',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.timeline,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
