import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/navigation/app_routes.dart';
import '../../../events/data/mock/mock_events.dart';
import '../../../events/domain/models/event.dart';
import '../../../events/presentation/widgets/concept_ui.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  EventCategory? _categoryFilter;
  bool _isHoveringCluster = false;

  @override
  Widget build(BuildContext context) {
    final events = MockEvents.timeline;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(ConceptAssets.map, fit: BoxFit.cover),
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
                label: 'Create\nevent',
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.createEvent);
                },
              ),
            ),
            Positioned(
              top: 78,
              right: 140,
              child: IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
                iconSize: 64,
                color: ConceptColors.blue,
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            Align(
              alignment: const Alignment(-0.62, -0.25),
              child: _isVisible(events[1])
                  ? _MapClockMarker(
                      event: events[1],
                      wedgeColor: conceptEventColor(events[1].category),
                    )
                  : const SizedBox.shrink(),
            ),
            Align(
              alignment: const Alignment(-0.12, -0.42),
              child: _isVisible(events[2])
                  ? _MapClockMarker(
                      event: events[2],
                      wedgeColor: conceptEventColor(events[2].category),
                    )
                  : const SizedBox.shrink(),
            ),
            Align(
              alignment: const Alignment(0.58, 0.10),
              child: _isVisible(events.first)
                  ? MouseRegion(
                      onEnter: (_) => setState(() => _isHoveringCluster = true),
                      onExit: (_) => setState(() => _isHoveringCluster = false),
                      child: _HoverCluster(
                        events: events,
                        expanded: _isHoveringCluster,
                        isVisible: _isVisible,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 145,
                  height: 24,
                  decoration: BoxDecoration(
                    color: ConceptColors.blue,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isVisible(Event event) {
    return _categoryFilter == null || event.category == _categoryFilter;
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

class _HoverCluster extends StatelessWidget {
  const _HoverCluster({
    required this.events,
    required this.expanded,
    required this.isVisible,
  });

  final List<Event> events;
  final bool expanded;
  final bool Function(Event event) isVisible;

  @override
  Widget build(BuildContext context) {
    if (!expanded) {
      return _MapClockMarker(
        event: events.first,
        wedgeColor: conceptEventColor(events.first.category),
        showCount: true,
      );
    }

    return SizedBox(
      width: 420,
      height: 300,
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 110,
            child: Text(
              'When hovering:',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          ),
          Positioned(
            left: 24,
            top: 80,
            child: isVisible(events[1])
                ? _MapClockMarker(
                    event: events[1],
                    wedgeColor: conceptEventColor(events[1].category),
                  )
                : const SizedBox.shrink(),
          ),
          Positioned(
            left: 178,
            top: 48,
            child: _MapClockMarker(
              event: events.first,
              wedgeColor: conceptEventColor(events.first.category),
              showCount: true,
            ),
          ),
          Positioned(
            left: 210,
            top: 200,
            child: isVisible(events[3])
                ? _MapClockMarker(
                    event: events[3],
                    wedgeColor: conceptEventColor(events[3].category),
                  )
                : const SizedBox.shrink(),
          ),
          Positioned(
            left: 298,
            top: 150,
            child: isVisible(events[2])
                ? _MapClockMarker(
                    event: events[2],
                    wedgeColor: conceptEventColor(events[2].category),
                  )
                : const SizedBox.shrink(),
          ),
          const Positioned(
            left: 180,
            top: 150,
            child: Icon(Icons.circle, size: 26, color: ConceptColors.blue),
          ),
          const Positioned(
            left: 226,
            top: 148,
            child: Icon(
              Icons.arrow_right_alt,
              size: 54,
              color: ConceptColors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapClockMarker extends StatelessWidget {
  const _MapClockMarker({
    required this.event,
    required this.wedgeColor,
    this.showCount = false,
  });

  final Event event;
  final Color wedgeColor;
  final bool showCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.eventDetail, arguments: event);
      },
      child: SizedBox(
        width: 126,
        height: 126,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: const Size.square(126),
              painter: _ClockMarkerPainter(color: wedgeColor),
            ),
            const Positioned(top: 8, left: 60, child: Text('0')),
            const Positioned(right: 18, top: 56, child: Text('6')),
            const Positioned(bottom: 12, left: 58, child: Text('12')),
            const Positioned(left: 14, top: 56, child: Text('18')),
            if (showCount)
              const Positioned(
                right: -18,
                top: 8,
                child: Text('9+', style: TextStyle(fontSize: 20)),
              ),
          ],
        ),
      ),
    );
  }
}

class _ClockMarkerPainter extends CustomPainter {
  const _ClockMarkerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;
    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final wedgePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, outlinePaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 1),
      -2.75,
      1.05,
      true,
      wedgePaint,
    );

    for (final angle in const [0.0, 1.5708, 3.1416, 4.7124]) {
      final outer = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      final inner = Offset(
        center.dx + math.cos(angle) * (radius - 14),
        center.dy + math.sin(angle) * (radius - 14),
      );
      canvas.drawLine(inner, outer, outlinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ClockMarkerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
