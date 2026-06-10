import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/models/event.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key, this.event});

  final Event? event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event detail')),
        body: const Center(child: Text('No event selected.')),
      );
    }

    final categoryColor = _categoryColor(event!.category, theme.colorScheme);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                event!.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: _EventHeaderImage(imagePath: event!.imagePath),
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.fadeTitle,
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                _CategoryChip(category: event!.category, color: categoryColor),
                const SizedBox(height: 12),
                _InfoSection(
                  icon: Icons.description_outlined,
                  title: 'Description',
                  child: event!.description == null || event!.description!.trim().isEmpty
                      ? Text(
                          'No description provided.',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        )
                      : Text(event!.description!),
                ),
                const SizedBox(height: 16),
                _InfoSection(
                  icon: Icons.calendar_month_outlined,
                  title: 'Dates',
                  child: Text(
                    _formatDateRange(event!.startDate, event!.endDate),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
                _InfoSection(
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  child: Text(
                    event!.locationName ??
                        '${event!.latitude.toStringAsFixed(3)}, ${event!.longitude.toStringAsFixed(3)}',
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventHeaderImage extends StatelessWidget {
  const _EventHeaderImage({required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (imagePath == null || imagePath!.trim().isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.35),
              theme.colorScheme.secondary.withValues(alpha: 0.25),
              theme.colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            size: 56,
            color: Colors.white70,
          ),
        ),
      );
    }

    // NOTE: imagePath comes from ImagePicker on the device, so this is a local file.
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(
          File(imagePath!),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.35),
                    theme.colorScheme.secondary.withValues(alpha: 0.25),
                    theme.colorScheme.surface,
                  ],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 56,
                  color: Colors.white70,
                ),
              ),
            );
          },
        ),
        // Readability overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.45),
                Colors.black.withValues(alpha: 0.10),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.color});

  final EventCategory category;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Text(
            category.label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
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

String _formatFullDate(DateTime date) {
  // If you ever support BCE properly, keep parity with timeline formatting.
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

