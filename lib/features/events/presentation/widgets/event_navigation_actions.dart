import 'package:flutter/material.dart';

import '../../../../app/navigation/app_routes.dart';
import '../../../../app/navigation/navigation_args.dart';
import '../../domain/models/event.dart';

class EventNavigationActions extends StatelessWidget {
  const EventNavigationActions({required this.event, super.key});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pushNamed(
              AppRoutes.map,
              arguments: MapPageArgs(focusEventId: event.id),
            );
          },
          icon: const Icon(Icons.map_outlined),
          label: const Text('Show on map'),
        ),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pushNamed(
              AppRoutes.timeline,
              arguments: TimelinePageArgs(focusEventId: event.id),
            );
          },
          icon: const Icon(Icons.timeline_outlined),
          label: const Text('Show on timeline'),
        ),
      ],
    );
  }
}
