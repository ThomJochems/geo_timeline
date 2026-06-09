import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/navigation/app_routes.dart';
import '../../data/mock/mock_events.dart';
import '../../domain/models/event.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final events = MockEvents.timeline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoTimeline'),
        actions: [
          IconButton(
            tooltip: 'Open map',
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.map),
            icon: const Icon(Icons.map_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return _TimelineEntry(
              event: events[index],
              isFirst: index == 0,
              isLast: index == events.length - 1,
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.eventDetail,
                  arguments: events[index],
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.createEvent),
        icon: const Icon(Icons.add),
        label: const Text('Add event'),
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.event,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final Event event;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _categoryColor(event.category, theme.colorScheme);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 76,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                _formatTimelineDate(event.startDate),
                textAlign: TextAlign.right,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: 2,
                    color: isFirst
                        ? Colors.transparent
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 3,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast
                        ? Colors.transparent
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _EventCard(
                event: event,
                categoryColor: categoryColor,
                onTap: onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.categoryColor,
    required this.onTap,
  });

  final Event event;
  final Color categoryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _CategoryChip(
                    category: event.category,
                    color: categoryColor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _formatDateRange(event.startDate, event.endDate),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (event.description case final description?) ...[
                const SizedBox(height: 12),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      event.locationName ??
                          '${event.latitude.toStringAsFixed(3)}, ${event.longitude.toStringAsFixed(3)}',
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.color,
  });

  final EventCategory category;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Color _categoryColor(EventCategory category, ColorScheme colorScheme) {
  return switch (category) {
    EventCategory.earthquake => colorScheme.error,
    EventCategory.volcano => const Color(0xFFC15A14),
    EventCategory.gasEmission => const Color(0xFF5B6F20),
    EventCategory.tsunami => const Color(0xFF116A9A),
  };
}

String _formatDateRange(DateTime startDate, DateTime endDate) {
  if (_isSameDay(startDate, endDate)) {
    return _formatFullDate(startDate);
  }

  return '${_formatFullDate(startDate)} - ${_formatFullDate(endDate)}';
}

String _formatTimelineDate(DateTime date) {
  if (date.year <= 0) {
    return '${date.year.abs() + 1} BCE';
  }

  return DateFormat.y().format(date);
}

String _formatFullDate(DateTime date) {
  if (date.year <= 0) {
    return '${date.day}/${date.month}/${date.year.abs() + 1} BCE';
  }

  return DateFormat.yMMMd().format(date);
}

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
