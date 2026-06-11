import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../events/data/mock/mock_events.dart';
import '../../../events/domain/models/event.dart';
import '../../../../app/navigation/app_routes.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Set<Marker> _markersFromEvents(List<Event> events) {
    return events.map((event) {
      return Marker(
        markerId: MarkerId(event.id),
        position: LatLng(event.latitude, event.longitude),
        infoWindow: InfoWindow(
          title: event.title,
          snippet: event.category.label,
        ),
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.eventDetail,
            arguments: event,
          );
        },
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final events = MockEvents.timeline;

    final initialPosition =
        events.isNotEmpty ? LatLng(events.first.latitude, events.first.longitude) : const LatLng(0, 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialPosition,
          zoom: events.isNotEmpty ? 3.5 : 1.0,
        ),
        markers: _markersFromEvents(events),
        myLocationEnabled: false,
        zoomControlsEnabled: false,
      ),
    );
  }
}

