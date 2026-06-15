import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../app/navigation/app_routes.dart';
import '../../data/mock/mock_events.dart';
import '../../domain/models/event.dart';
import '../providers/event_provider.dart';
import '../widgets/concept_ui.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final _horizontalController = ScrollController();

  EventCategory? _categoryFilter;
  double _zoom = 1;

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final canvasWidth = math.max(1180.0 * _zoom, constraints.maxWidth);
            final canvasHeight = math.max(650.0, constraints.maxHeight);

            return Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: canvasWidth,
                  height: canvasHeight,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Positioned(
                        top: 16,
                        left: 28,
                        child: ConceptButton(
                          label: _categoryFilter == null
                              ? 'Filter'
                              : _categoryFilter!.label,
                          onPressed: _openFilterSheet,
                        ),
                      ),
                      Positioned(
                        top: 6,
                        left: 170,
                        child: ConceptGlobeButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(AppRoutes.map);
                          },
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 36,
                        child: ConceptButton(
                          label: 'Create\nevent',
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(AppRoutes.createEvent);
                          },
                        ),
                      ),
                      ..._buildEventCards(visibleEvents, canvasWidth),
                      Positioned(
                        top: 238,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 1.5,
                          color: ConceptColors.blue,
                        ),
                      ),
                      Positioned(
                        right: 14,
                        top: 250,
                        child: _RightScrollAffordance(height: 150),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 31,
                          height: 168,
                          decoration: BoxDecoration(
                            color: ConceptColors.lightBlue,
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _TimeAxis(
                          zoom: _zoom,
                          onZoomIn: () {
                            setState(
                              () => _zoom =
                                  (_zoom + 0.15).clamp(1, 1.6).toDouble(),
                            );
                          },
                          onZoomOut: () {
                            setState(
                              () => _zoom =
                                  (_zoom - 0.15).clamp(1, 1.6).toDouble(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildEventCards(List<Event> events, double canvasWidth) {
    final cards = <Widget>[];

    for (final event in events) {
      final position = _positionForEvent(event, canvasWidth);

      cards.add(
        Positioned(
          left: position.left,
          top: position.top,
          child: _ConceptTimelineCard(
            event: event,
            width: position.width,
            height: position.height,
            tagAlignment: position.tagAlignment,
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRoutes.eventDetail,
                arguments: event,
              );
            },
          ),
        ),
      );
    }

    return cards;
  }

  _CardPosition _positionForEvent(Event event, double canvasWidth) {
    return switch (event.id) {
      'evt-001' => _CardPosition(
          left: 260,
          top: 76,
          width: 610,
          height: 150,
          tagAlignment: Alignment.topCenter,
        ),
      'evt-002' => _CardPosition(
          left: 240,
          top: 238,
          width: 520,
          height: 150,
          tagAlignment: Alignment.centerRight,
        ),
      'evt-003' => _CardPosition(
          left: 758,
          top: 238,
          width: 420,
          height: 150,
          tagAlignment: Alignment.centerLeft,
        ),
      'evt-004' => _CardPosition(
          left: 230,
          top: 395,
          width: 550,
          height: 150,
          tagAlignment: Alignment.bottomLeft,
        ),
      _ => _CardPosition(
          left: math.min(250 + eventsHashOffset(event), canvasWidth - 440),
          top: 555,
          width: 400,
          height: 140,
          tagAlignment: Alignment.topCenter,
        ),
    };
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

class _ConceptTimelineCard extends StatelessWidget {
  const _ConceptTimelineCard({
    required this.event,
    required this.width,
    required this.height,
    required this.tagAlignment,
    required this.onTap,
  });

  final Event event;
  final double width;
  final double height;
  final Alignment tagAlignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = conceptEventColor(event.category);
    final textColor = conceptEventTextColor(event.category);
    final isCompact = width < 460;

    return SizedBox(
      width: width,
      height: height + 34,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: tagAlignment == Alignment.topCenter ? 0 : 28,
            left: 0,
            child: Material(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(24),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: Container(
                  width: width,
                  height: height,
                  padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: textColor,
                            fontSize: isCompact ? 20 : 24,
                            height: 1.2,
                            fontWeight: FontWeight.w400,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                event.title,
                                maxLines: isCompact ? 2 : 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatConceptRange(
                                  event.startDate,
                                  event.endDate,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      ClipRect(
                        child: Image.asset(
                          conceptEventAsset(event.category),
                          width: isCompact ? 140 : 190,
                          height: isCompact ? 86 : 112,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _CardBadge(alignment: tagAlignment, color: backgroundColor),
        ],
      ),
    );
  }
}

class _CardBadge extends StatelessWidget {
  const _CardBadge({
    required this.alignment,
    required this.color,
  });

  final Alignment alignment;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 62,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Text(
        '9+',
        style: TextStyle(
          fontSize: 14,
          color: color.computeLuminance() < 0.35 ? Colors.white : Colors.black,
        ),
      ),
    );

    if (alignment == Alignment.centerRight) {
      return Positioned(right: 22, top: 86, child: child);
    }
    if (alignment == Alignment.bottomLeft) {
      return Positioned(left: 12, bottom: 0, child: child);
    }
    if (alignment == Alignment.centerLeft) {
      return const SizedBox.shrink();
    }

    return Positioned(top: 0, left: 88, child: child);
  }
}

class _TimeAxis extends StatelessWidget {
  const _TimeAxis({
    required this.zoom,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final double zoom;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 94,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 42,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _AxisTick(label: '23:00'),
                _AxisTick(label: '00:00'),
                _AxisTick(label: '01:00'),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 42,
              color: ConceptColors.blue,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${zoom.toStringAsFixed(1)}x',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(width: 14),
                  _ZoomButton(icon: Icons.remove, onPressed: onZoomOut),
                  const SizedBox(width: 8),
                  _ZoomButton(icon: Icons.add, onPressed: onZoomIn),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              width: 168,
              height: 36,
              decoration: BoxDecoration(
                color: ConceptColors.lightBlue,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AxisTick extends StatelessWidget {
  const _AxisTick({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 2, height: 22, color: ConceptColors.blue),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: ConceptColors.blue,
      ),
      icon: Icon(icon),
    );
  }
}

class _RightScrollAffordance extends StatelessWidget {
  const _RightScrollAffordance({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ConceptColors.blue,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: const Text(
        '...',
        style: TextStyle(color: Colors.white, fontSize: 22),
      ),
    );
  }
}

class _CardPosition {
  const _CardPosition({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.tagAlignment,
  });

  final double left;
  final double top;
  final double width;
  final double height;
  final Alignment tagAlignment;
}

double eventsHashOffset(Event event) {
  return (event.id.hashCode.abs() % 360).toDouble();
}

String _formatConceptRange(DateTime startDate, DateTime endDate) {
  final formatter = DateFormat('HH:mm dd/MM/yyyy');
  return '${formatter.format(startDate)}\n- ${formatter.format(endDate)}';
}
