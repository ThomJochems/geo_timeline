import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app/geo_timeline_app.dart';
import 'features/events/data/repositories/hive_event_repository.dart';
import 'features/events/domain/repositories/event_repository.dart';
import 'features/events/presentation/providers/event_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  final eventRepository = HiveEventRepository();
  await eventRepository.initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider<EventRepository>.value(value: eventRepository),
        ChangeNotifierProvider(
          create: (_) => EventProvider(eventRepository)..loadEvents(),
        ),
      ],
      child: const GeoTimelineApp(),
    ),
  );
}
