import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/events/data/event_repository.dart';
import '../features/events/presentation/state/event_provider.dart';
import 'navigation/app_router.dart';
import 'theme/app_theme.dart';

class GeoTimelineApp extends StatelessWidget {
  const GeoTimelineApp({
    required this.eventRepository,
    super.key,
  });

  final EventRepository eventRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<EventRepository>.value(value: eventRepository),
        ChangeNotifierProvider<EventProvider>(
          create: (_) => EventProvider(eventRepository)..loadEvents(),
        ),
      ],
      child: MaterialApp(
        title: 'Geo Timeline',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        initialRoute: AppRouter.initialRoute,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
