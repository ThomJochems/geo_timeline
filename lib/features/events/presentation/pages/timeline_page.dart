import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../app/navigation/app_routes.dart';
import '../../../../app/navigation/navigation_args.dart';
import '../../domain/models/event.dart';
import '../providers/event_provider.dart';
import '../utils/event_list_utils.dart';
import '../widgets/concept_ui.dart';

abstract final class _TimelineLayout {
  static const axisHeight = 94.0;
  static const cardTop = 100.0;
  static const cardHeight = 150.0;
  static const cardGap = 16.0;
  static const horizontalLineTop = 238.0;
  static const tickTop = 228.0;
  static const baseHeight = 300.0;
}

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key, this.focusEventId});

  final String? focusEventId;

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final _horizontalController = ScrollController();
  final _verticalController = ScrollController();

  EventCategory? _categoryFilter;
  double _visibleHours = 4;
  double _horizontalOffset = 0;
  bool _hasPositionedInitialView = false;

  @override
  void initState() {
    super.initState();
    _horizontalController.addListener(_handleHorizontalScroll);
  }

  @override
  void dispose() {
    _horizontalController.removeListener(_handleHorizontalScroll);
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savedEvents = context.watch<EventProvider>().events;
    final events = timelineEventsWithSaved(savedEvents);
    final visibleEvents = filterEventsByCategory(events, _categoryFilter);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final range = _TimelineRange.fromEvents(events);
            final pixelsPerHour = constraints.maxWidth / _visibleHours;
            final canvasWidth = math.max(
              constraints.maxWidth,
              range.totalHours * pixelsPerHour,
            );
            final cardLayouts = _layoutEventCards(
              visibleEvents,
              range,
              pixelsPerHour,
            );
            final canvasHeight = math.max(
              constraints.maxHeight,
              _TimelineLayout.baseHeight +
                  cardLayouts.laneCount *
                      (_TimelineLayout.cardHeight + _TimelineLayout.cardGap),
            );
            _positionInitialView(range, pixelsPerHour, constraints.maxWidth);
            final offscreenCounts = _offscreenEventCounts(
              cardLayouts.layouts,
              _horizontalOffset,
              constraints.maxWidth,
            );
            final visibleEventIds = _visibleTimelineEventIds(
              cardLayouts.layouts,
              _horizontalOffset,
              constraints.maxWidth,
            );

            return Stack(
              children: [
                Positioned.fill(
                  child: ScrollConfiguration(
                    behavior: const _TimelineScrollBehavior(),
                    child: Scrollbar(
                      controller: _horizontalController,
                      thumbVisibility: true,
                      notificationPredicate: (notification) =>
                          notification.metrics.axis == Axis.horizontal,
                      child: SingleChildScrollView(
                        controller: _horizontalController,
                        scrollDirection: Axis.horizontal,
                        child: Scrollbar(
                          controller: _verticalController,
                          thumbVisibility: true,
                          notificationPredicate: (notification) =>
                              notification.metrics.axis == Axis.vertical,
                          child: SingleChildScrollView(
                            controller: _verticalController,
                            child: SizedBox(
                              width: canvasWidth,
                              height: canvasHeight,
                              child: Stack(
                                clipBehavior: Clip.hardEdge,
                                children: [
                                  Positioned(
                                    top: _TimelineLayout.horizontalLineTop,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 1.5,
                                      color: ConceptColors.blue,
                                    ),
                                  ),
                                  ..._buildHourTicks(
                                    range,
                                    pixelsPerHour,
                                    canvasHeight,
                                  ),
                                  ..._buildEventCards(cardLayouts.layouts),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: _TimeAxis(
                                      range: range,
                                      pixelsPerHour: pixelsPerHour,
                                      width: canvasWidth,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
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
                      Navigator.of(context).pushNamed(
                        AppRoutes.map,
                        arguments: MapPageArgs(visibleEventIds: visibleEventIds),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 36,
                  child: ConceptButton(
                    label: 'Create event',
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.createEvent);
                    },
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _TimelineZoomPanel(
                    visibleHours: _visibleHours,
                    onZoomIn: _zoomIn,
                    onZoomOut: _zoomOut,
                  ),
                ),
                if (offscreenCounts.left > 0)
                  Positioned(
                    left: 18,
                    top: constraints.maxHeight / 2 - 28,
                    child: _OffscreenEventIndicator(
                      count: offscreenCounts.left,
                      icon: Icons.chevron_left,
                    ),
                  ),
                if (offscreenCounts.right > 0)
                  Positioned(
                    right: 18,
                    top: constraints.maxHeight / 2 - 28,
                    child: _OffscreenEventIndicator(
                      count: offscreenCounts.right,
                      icon: Icons.chevron_right,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleHorizontalScroll() {
    if (_horizontalOffset == _horizontalController.offset) {
      return;
    }

    setState(() => _horizontalOffset = _horizontalController.offset);
  }

  _TimelineCardLayoutResult _layoutEventCards(
    List<Event> events,
    _TimelineRange range,
    double pixelsPerHour,
  ) {
    final laneEnds = <double>[];
    final layouts = <_TimelineCardLayout>[];

    for (var index = 0; index < events.length; index++) {
      final event = events[index];
      final left = range.hoursFromStart(event.startDate) * pixelsPerHour;
      final durationHours = math.max(
        0.75,
        event.endDate.difference(event.startDate).inMinutes / 60,
      );
      final width = math.max(280.0, durationHours * pixelsPerHour);
      final right = left + width;
      var lane = laneEnds.indexWhere((laneEnd) => left >= laneEnd + 12);

      if (lane == -1) {
        lane = laneEnds.length;
        laneEnds.add(right);
      } else {
        laneEnds[lane] = right;
      }

      layouts.add(
        _TimelineCardLayout(
          event: event,
          left: left,
          top: _TimelineLayout.cardTop +
              lane *
                  (_TimelineLayout.cardHeight + _TimelineLayout.cardGap),
          width: width,
          height: _TimelineLayout.cardHeight,
        ),
      );
    }

    return _TimelineCardLayoutResult(
      layouts: layouts,
      laneCount: math.max(1, laneEnds.length),
    );
  }

  List<Widget> _buildEventCards(List<_TimelineCardLayout> layouts) {
    return [
      for (final layout in layouts)
        Positioned(
          left: layout.left,
          top: layout.top,
          child: _ConceptTimelineCard(
            event: layout.event,
            width: layout.width,
            height: layout.height,
            onTap: () {
              Navigator.of(
                context,
              ).pushNamed(AppRoutes.eventDetail, arguments: layout.event);
            },
          ),
        ),
    ];
  }

  List<Widget> _buildHourTicks(
    _TimelineRange range,
    double pixelsPerHour,
    double canvasHeight,
  ) {
    final tickInterval = _tickIntervalHours(_visibleHours);
    final ticks = <Widget>[];

    for (var hours = 0.0; hours <= range.totalHours; hours += tickInterval) {
      final date = range.start.add(Duration(minutes: (hours * 60).round()));
      final x = hours * pixelsPerHour;

      ticks.add(
        Positioned(
          left: x,
          top: _TimelineLayout.tickTop,
          bottom: _TimelineLayout.axisHeight,
          child: _TimelineTick(
            label: _formatTick(date, tickInterval),
            isMajor: date.hour == 0,
            height:
                canvasHeight -
                _TimelineLayout.tickTop -
                _TimelineLayout.axisHeight,
          ),
        ),
      );
    }

    return ticks;
  }

  void _zoomIn() {
    _setVisibleHours(_visibleHours / 1.35);
  }

  void _zoomOut() {
    _setVisibleHours(_visibleHours * 1.35);
  }

  void _setVisibleHours(double nextVisibleHours) {
    final oldVisibleHours = _visibleHours;
    final viewportWidth = context.size?.width ?? 1;
    final currentCenterHour =
        (_horizontalController.offset + viewportWidth / 2) /
        (viewportWidth / oldVisibleHours);

    setState(() {
      _visibleHours = nextVisibleHours.clamp(1, 168).toDouble();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_horizontalController.hasClients) {
        return;
      }

      final newPixelsPerHour = viewportWidth / _visibleHours;
      final nextOffset =
          currentCenterHour * newPixelsPerHour - viewportWidth / 2;
      _horizontalController.jumpTo(
        nextOffset
            .clamp(
              _horizontalController.position.minScrollExtent,
              _horizontalController.position.maxScrollExtent,
            )
            .toDouble(),
      );
    });
  }

  void _positionInitialView(
    _TimelineRange range,
    double pixelsPerHour,
    double viewportWidth,
  ) {
    if (_hasPositionedInitialView) {
      return;
    }

    _hasPositionedInitialView = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_horizontalController.hasClients) {
        return;
      }

      final firstEventOffset = range.firstEventHours * pixelsPerHour;
      final focusEventOffset =
          widget.focusEventId == null
              ? firstEventOffset
              : range.hoursFromStartByEventId(widget.focusEventId!) *
                    pixelsPerHour;
      final nextOffset = focusEventOffset - viewportWidth * 0.18;

      _horizontalController.jumpTo(
        nextOffset
            .clamp(
              _horizontalController.position.minScrollExtent,
              _horizontalController.position.maxScrollExtent,
            )
            .toDouble(),
      );
    });
  }

  ({int left, int right}) _offscreenEventCounts(
    List<_TimelineCardLayout> layouts,
    double viewportLeft,
    double viewportWidth,
  ) {
    final viewportRight = viewportLeft + viewportWidth;
    var left = 0;
    var right = 0;

    for (final layout in layouts) {
      if (layout.right < viewportLeft) {
        left++;
      } else if (layout.left > viewportRight) {
        right++;
      }
    }

    return (left: left, right: right);
  }

  Set<String> _visibleTimelineEventIds(
    List<_TimelineCardLayout> layouts,
    double viewportLeft,
    double viewportWidth,
  ) {
    final viewportRight = viewportLeft + viewportWidth;

    return {
      for (final layout in layouts)
        if (layout.left <= viewportRight && layout.right >= viewportLeft)
          layout.event.id,
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
    required this.onTap,
  });

  final Event event;
  final double width;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = conceptEventColor(event.category);
    final textColor = conceptEventTextColor(event.category);
    final isCompact = width < 460;
    final hasImage = event.imagePath != null && event.imagePath!.isNotEmpty;

    return SizedBox(
      width: width,
      height: height,
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
                          _formatConceptRange(event.startDate, event.endDate),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                if (hasImage) ...[
                  const SizedBox(width: 18),
                  ClipRect(
                    child: Image.file(
                      File(event.imagePath!),
                      width: isCompact ? 140 : 190,
                      height: isCompact ? 86 : 112,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OffscreenEventIndicator extends StatelessWidget {
  const _OffscreenEventIndicator({
    required this.count,
    required this.icon,
  });

  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineCardLayoutResult {
  const _TimelineCardLayoutResult({
    required this.layouts,
    required this.laneCount,
  });

  final List<_TimelineCardLayout> layouts;
  final int laneCount;
}

class _TimelineCardLayout {
  const _TimelineCardLayout({
    required this.event,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final Event event;
  final double left;
  final double top;
  final double width;
  final double height;

  double get right => left + width;
}

class _TimeAxis extends StatelessWidget {
  const _TimeAxis({
    required this.range,
    required this.pixelsPerHour,
    required this.width,
  });

  final _TimelineRange range;
  final double pixelsPerHour;
  final double width;

  @override
  Widget build(BuildContext context) {
    final tickInterval = _tickIntervalHours(width / pixelsPerHour);

    return SizedBox(
      width: width,
      height: _TimelineLayout.axisHeight,
      child: Stack(
        children: [
          Positioned.fill(
            bottom: 42,
            child: Stack(
              children: [
                for (
                  var hours = 0.0;
                  hours <= range.totalHours;
                  hours += tickInterval
                )
                  Positioned(
                    left: hours * pixelsPerHour,
                    bottom: 0,
                    child: _AxisTick(
                      label: _formatTick(
                        range.start.add(
                          Duration(minutes: (hours * 60).round()),
                        ),
                        tickInterval,
                      ),
                    ),
                  ),
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
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineZoomPanel extends StatelessWidget {
  const _TimelineZoomPanel({
    required this.visibleHours,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final double visibleHours;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      color: ConceptColors.blue,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '${_formatHours(visibleHours)} visible',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(width: 14),
          _ZoomButton(icon: Icons.remove, onPressed: onZoomOut),
          const SizedBox(width: 8),
          _ZoomButton(icon: Icons.add, onPressed: onZoomIn),
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
    return Transform.translate(
      offset: const Offset(-32, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 2, height: 22, color: ConceptColors.blue),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineTick extends StatelessWidget {
  const _TimelineTick({
    required this.label,
    required this.isMajor,
    required this.height,
  });

  final String label;
  final bool isMajor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: isMajor ? 2 : 1,
              color: ConceptColors.blue.withValues(
                alpha: isMajor ? 0.28 : 0.12,
              ),
            ),
          ),
          if (isMajor)
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
        ],
      ),
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

class _TimelineRange {
  const _TimelineRange({
    required this.start,
    required this.end,
    required this.firstEventStart,
    required this.eventStartsById,
  });

  factory _TimelineRange.fromEvents(List<Event> events) {
    if (events.isEmpty) {
      final now = DateTime.now();
      return _TimelineRange(
        start: now.subtract(const Duration(days: 30)),
        end: now.add(const Duration(days: 30)),
        firstEventStart: now,
        eventStartsById: const {},
      );
    }

    final first = events
        .map((event) => event.startDate)
        .reduce((value, element) => value.isBefore(element) ? value : element);
    final last = events
        .map((event) => event.endDate)
        .reduce((value, element) => value.isAfter(element) ? value : element);

    return _TimelineRange(
      start: first.subtract(const Duration(days: 30)),
      end: last.add(const Duration(days: 30)),
      firstEventStart: first,
      eventStartsById: {
        for (final event in events) event.id: event.startDate,
      },
    );
  }

  final DateTime start;
  final DateTime end;
  final DateTime firstEventStart;
  final Map<String, DateTime> eventStartsById;

  double get totalHours => math.max(1.0, end.difference(start).inMinutes / 60);

  double get firstEventHours => hoursFromStart(firstEventStart);

  double hoursFromStartByEventId(String eventId) {
    return hoursFromStart(eventStartsById[eventId] ?? firstEventStart);
  }

  double hoursFromStart(DateTime date) {
    return date.difference(start).inMinutes / 60;
  }
}

class _TimelineScrollBehavior extends MaterialScrollBehavior {
  const _TimelineScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

double _tickIntervalHours(double visibleHours) {
  if (visibleHours <= 3) {
    return 0.5;
  }
  if (visibleHours <= 8) {
    return 1;
  }
  if (visibleHours <= 24) {
    return 3;
  }
  if (visibleHours <= 72) {
    return 12;
  }
  return 24;
}

String _formatTick(DateTime date, double tickInterval) {
  if (tickInterval >= 24) {
    return DateFormat('dd/MM').format(date);
  }
  if (date.hour == 0 && date.minute == 0) {
    return DateFormat('dd/MM').format(date);
  }
  return DateFormat('HH:mm').format(date);
}

String _formatHours(double hours) {
  if (hours < 24) {
    return '${hours.toStringAsFixed(hours < 10 ? 1 : 0)}h';
  }

  return '${(hours / 24).toStringAsFixed(1)}d';
}

String _formatConceptRange(DateTime startDate, DateTime endDate) {
  final formatter = DateFormat('HH:mm dd/MM/yyyy');
  return '${formatter.format(startDate)}\n- ${formatter.format(endDate)}';
}
