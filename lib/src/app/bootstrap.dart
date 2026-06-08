import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../features/events/data/hive_event_repository.dart';
import '../features/events/domain/event.dart';
import 'geo_timeline_app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(Event.typeId)) {
    Hive.registerAdapter(EventAdapter());
  }

  final eventRepository = HiveEventRepository();
  await eventRepository.init();

  runApp(GeoTimelineApp(eventRepository: eventRepository));
}
