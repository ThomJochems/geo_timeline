import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../app/navigation/app_routes.dart';
import '../../../events/data/mock/mock_events.dart';
import '../../../events/domain/models/event.dart';
import '../../../events/presentation/providers/event_provider.dart';
import '../../../events/presentation/widgets/concept_ui.dart';

const _clockMarkerSize = 112.0;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _mapController = MapController();

  MapCamera? _camera;
  MapCamera? _pendingCamera;
  bool _cameraUpdateScheduled = false;
  EventCategory? _categoryFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncCamera());
  }

  @override
  Widget build(BuildContext context) {
    final savedEvents = context.watch<EventProvider>().events;
    final events = [...MockEvents.timeline, ...savedEvents]
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final visibleEvents = _categoryFilter == null
        ? events
        : events
              .where((event) => event.category == _categoryFilter)
              .toList(growable: false);
    final clusters = _clusterEvents(visibleEvents, _camera);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(15, 0),
                initialZoom: 2,
                minZoom: 1,
                maxZoom: 18,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onPositionChanged: (camera, _) => _setCamera(camera),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.example.geo_timeline',
                ),
                MarkerLayer(
                  markers: [
                    for (final cluster in clusters)
                      Marker(
                        point: cluster.center,
                        width: cluster.events.length > 1 ? 360 : 128,
                        height: cluster.events.length > 1 ? 360 : 128,
                        child: _ClusterMapMarker(
                          cluster: cluster,
                          onEventTap: (event) {
                            _openEventDetail(event);
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 18,
              left: 20,
              child: ConceptButton(
                label: _categoryFilter?.label ?? 'Filter',
                onPressed: _openFilterSheet,
              ),
            ),
            Positioned(
              top: 14,
              right: 24,
              child: ConceptButton(
                label: 'Create event',
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.createEvent);
                },
              ),
            ),
            Positioned(
              left: 20,
              bottom: 20,
              child: _MapZoomControls(
                onZoomIn: () => _changeZoom(1),
                onZoomOut: () => _changeZoom(-1),
              ),
            ),
            Positioned(
              top: 82,
              right: 140,
              child: IconButton.filled(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
                iconSize: 40,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.88),
                  foregroundColor: ConceptColors.blue,
                ),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeZoom(double delta) {
    final camera = _mapController.camera;
    _mapController.move(
      camera.center,
      (camera.zoom + delta).clamp(1, 18).toDouble(),
    );
  }

  void _syncCamera() {
    if (!mounted) {
      return;
    }

    try {
      _setCamera(_mapController.camera);
    } on StateError {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncCamera());
    }
  }

  void _setCamera(MapCamera camera) {
    if (!mounted) {
      return;
    }

    _pendingCamera = camera;

    if (_cameraUpdateScheduled) {
      return;
    }

    _cameraUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cameraUpdateScheduled = false;

      final nextCamera = _pendingCamera;
      _pendingCamera = null;

      if (!mounted || nextCamera == null || _camera == nextCamera) {
        return;
      }

      setState(() => _camera = nextCamera);
    });
  }

  void _openEventDetail(Event event) {
    Navigator.of(context).pushNamed(AppRoutes.eventDetail, arguments: event);
  }

  Future<void> _openFilterSheet() async {
    final selectedCategory = await showModalBottomSheet<EventCategory?>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ChoiceChip(
                  label: const Text('All events'),
                  selected: _categoryFilter == null,
                  onSelected: (_) => Navigator.pop(context),
                ),
                for (final category in EventCategory.values)
                  ChoiceChip(
                    label: Text(category.label),
                    selected: _categoryFilter == category,
                    onSelected: (_) => Navigator.pop(context, category),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) {
      return;
    }

    setState(() => _categoryFilter = selectedCategory);
  }
}

class _ClusterMapMarker extends StatefulWidget {
  const _ClusterMapMarker({required this.cluster, required this.onEventTap});

  final _EventCluster cluster;
  final ValueChanged<Event> onEventTap;

  @override
  State<_ClusterMapMarker> createState() => _ClusterMapMarkerState();
}

class _ClusterMapMarkerState extends State<_ClusterMapMarker> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final events = widget.cluster.events;

    if (events.length == 1) {
      return Center(
        child: _EventDurationClock(
          event: events.first,
          size: 112,
          onTap: () => widget.onEventTap(events.first),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isExpanded = true),
      onExit: (_) => setState(() => _isExpanded = false),
      child: GestureDetector(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _isExpanded
              ? _ExpandedCluster(
                  events: events,
                  onEventTap: widget.onEventTap,
                )
              : _CollapsedCluster(
                  event: events.first,
                  count: events.length,
                ),
        ),
      ),
    );
  }
}

class _CollapsedCluster extends StatelessWidget {
  const _CollapsedCluster({
    required this.event,
    required this.count,
  });

  final Event event;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Tooltip(
        message: '$count overlapping events',
        child: SizedBox(
          width: 128,
          height: 142,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(top: 0, child: _ClusterCountBadge(count: count)),
              Positioned(
                bottom: 0,
                child: _EventDurationClock(event: event, size: 112),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpandedCluster extends StatelessWidget {
  const _ExpandedCluster({
    required this.events,
    required this.onEventTap,
  });

  final List<Event> events;
  final ValueChanged<Event> onEventTap;

  @override
  Widget build(BuildContext context) {
    const clusterSize = 360.0;
    const center = Offset(clusterSize / 2, clusterSize / 2);
    const orbitRadius = 122.0;
    const clockSize = 92.0;

    return SizedBox.square(
      dimension: clusterSize,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ClusterConnectorPainter(
                count: events.length,
                radius: orbitRadius,
                clockSize: clockSize,
              ),
            ),
          ),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF7FAF8), Color(0xFFDCE9E3)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(color: Colors.white, width: 5),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 7),
                ],
              ),
            ),
          ),
          for (var index = 0; index < events.length; index++)
            Positioned(
              left:
                  center.dx +
                  math.cos(_clusterAngle(index, events.length)) * orbitRadius -
                  clockSize / 2,
              top:
                  center.dy +
                  math.sin(_clusterAngle(index, events.length)) * orbitRadius -
                  clockSize / 2,
              child: _EventDurationClock(
                event: events[index],
                size: clockSize,
                onTap: () => onEventTap(events[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _EventDurationClock extends StatelessWidget {
  const _EventDurationClock({
    required this.event,
    required this.size,
    this.onTap,
  });

  final Event event;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final labelScale = size / 112;
    final color = conceptEventColor(event.category);

    return Tooltip(
      message:
          '${event.title}\n${event.category.label}\n${_formatDuration(event)}',
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size.square(size),
                painter: _DurationDialPainter(event: event, color: color),
              ),
              Positioned(
                top: 8 * labelScale,
                left: 51 * labelScale,
                child: _DialLabel('0', scale: labelScale),
              ),
              Positioned(
                right: 15 * labelScale,
                top: 49 * labelScale,
                child: _DialLabel('6', scale: labelScale),
              ),
              Positioned(
                bottom: 12 * labelScale,
                left: 47 * labelScale,
                child: _DialLabel('12', scale: labelScale),
              ),
              Positioned(
                left: 13 * labelScale,
                top: 49 * labelScale,
                child: _DialLabel('18', scale: labelScale),
              ),
              if (event.endDate.difference(event.startDate).inHours >= 9)
                Positioned(
                  right: -2 * labelScale,
                  top: 6 * labelScale,
                  child: Text(
                    '9+',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17 * labelScale,
                      fontWeight: FontWeight.w600,
                      shadows: const [
                        Shadow(color: Colors.white, blurRadius: 4),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialLabel extends StatelessWidget {
  const _DialLabel(this.text, {this.scale = 1});

  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.black,
        fontSize: 18 * scale,
        fontWeight: FontWeight.w500,
        shadows: const [Shadow(color: Colors.white, blurRadius: 4)],
      ),
    );
  }
}

class _ClusterCountBadge extends StatelessWidget {
  const _ClusterCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ClusterConnectorPainter extends CustomPainter {
  const _ClusterConnectorPainter({
    required this.count,
    required this.radius,
    required this.clockSize,
  });

  final int count;
  final double radius;
  final double clockSize;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = ConceptColors.blue.withValues(alpha: 0.55)
      ..strokeWidth = 2;

    for (var index = 0; index < count; index++) {
      final angle = _clusterAngle(index, count);
      final end = Offset(
        center.dx + math.cos(angle) * (radius - clockSize / 2 + 8),
        center.dy + math.sin(angle) * (radius - clockSize / 2 + 8),
      );
      canvas.drawLine(center, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ClusterConnectorPainter oldDelegate) {
    return oldDelegate.count != count ||
        oldDelegate.radius != radius ||
        oldDelegate.clockSize != clockSize;
  }
}

class _DurationDialPainter extends CustomPainter {
  const _DurationDialPainter({required this.event, required this.color});

  final Event event;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 3;
    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.58)
      ..style = PaintingStyle.fill;
    final wedgePaint = Paint()
      ..color = color.withValues(alpha: 0.92)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, fillPaint);

    final startHour = event.startDate.hour + event.startDate.minute / 60;
    final durationHours =
        event.endDate.difference(event.startDate).inMinutes / 60;
    final sweepHours = durationHours.clamp(0.25, 24).toDouble();
    final startAngle = -math.pi / 2 + startHour / 24 * math.pi * 2;
    final sweepAngle = sweepHours / 24 * math.pi * 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      true,
      wedgePaint,
    );

    canvas.drawCircle(center, radius, outlinePaint);

    for (final hour in const [0, 6, 12, 18]) {
      final angle = -math.pi / 2 + hour / 24 * math.pi * 2;
      final outer = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      final inner = Offset(
        center.dx + math.cos(angle) * (radius - 12),
        center.dy + math.sin(angle) * (radius - 12),
      );

      canvas.drawLine(inner, outer, outlinePaint);
    }

    canvas.drawCircle(center, 3.5, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant _DurationDialPainter oldDelegate) {
    return oldDelegate.event != event || oldDelegate.color != color;
  }
}

class _MapZoomControls extends StatelessWidget {
  const _MapZoomControls({required this.onZoomIn, required this.onZoomOut});

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Zoom out',
            onPressed: onZoomOut,
            icon: const Icon(Icons.remove),
          ),
          IconButton(
            tooltip: 'Zoom in',
            onPressed: onZoomIn,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

String _formatDuration(Event event) {
  final minutes = event.endDate.difference(event.startDate).inMinutes;
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;

  if (hours == 0) {
    return '$remainingMinutes min';
  }

  if (remainingMinutes == 0) {
    return '$hours h';
  }

  return '$hours h $remainingMinutes min';
}

List<_EventCluster> _clusterEvents(List<Event> events, MapCamera? camera) {
  if (camera == null ||
      camera.nonRotatedSize == MapCamera.kImpossibleSize ||
      camera.nonRotatedSize.isEmpty) {
    return [
      for (final event in events) _EventCluster(events: [event]),
    ];
  }

  final parentIndexes = List.generate(events.length, (index) => index);
  final screenOffsets = [
    for (final event in events)
      camera.latLngToScreenOffset(LatLng(event.latitude, event.longitude)),
  ];

  int findRoot(int index) {
    var root = index;
    while (parentIndexes[root] != root) {
      root = parentIndexes[root];
    }

    while (parentIndexes[index] != index) {
      final next = parentIndexes[index];
      parentIndexes[index] = root;
      index = next;
    }

    return root;
  }

  void join(int firstIndex, int secondIndex) {
    final firstRoot = findRoot(firstIndex);
    final secondRoot = findRoot(secondIndex);

    if (firstRoot != secondRoot) {
      parentIndexes[secondRoot] = firstRoot;
    }
  }

  for (var firstIndex = 0; firstIndex < events.length; firstIndex++) {
    for (
      var secondIndex = firstIndex + 1;
      secondIndex < events.length;
      secondIndex++
    ) {
      final distance =
          (screenOffsets[firstIndex] - screenOffsets[secondIndex]).distance;

      if (distance < _clockMarkerSize) {
        join(firstIndex, secondIndex);
      }
    }
  }

  final groupedEvents = <int, List<Event>>{};
  for (var index = 0; index < events.length; index++) {
    groupedEvents.putIfAbsent(findRoot(index), () => []).add(events[index]);
  }

  return [
    for (final clusterEvents in groupedEvents.values)
      _EventCluster(events: clusterEvents),
  ];
}

double _clusterAngle(int index, int count) {
  return -math.pi / 2 + (math.pi * 2 * index / count);
}

class _EventCluster {
  const _EventCluster({required this.events});

  final List<Event> events;

  LatLng get center {
    final latitudeSum = events.fold<double>(
      0,
      (sum, event) => sum + event.latitude,
    );
    final longitudeSum = events.fold<double>(
      0,
      (sum, event) => sum + event.longitude,
    );

    return LatLng(latitudeSum / events.length, longitudeSum / events.length);
  }
}
