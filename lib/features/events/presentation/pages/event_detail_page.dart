import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/models/event.dart';
import '../widgets/concept_ui.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key, this.event});

  final Event? event;

  @override
  Widget build(BuildContext context) {
    final selectedEvent = event;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(top: 8, left: 12, child: ConceptBackButton()),
            Positioned(
              top: 34,
              left: 160,
              right: 160,
              child: _DetailHeader(event: selectedEvent),
            ),
            Positioned.fill(
              top: 160,
              child: selectedEvent == null
                  ? const Center(child: Text('No event selected.'))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 56),
                      children: [
                        Center(
                          child: _DetailSectionCard(
                            title: _primarySectionTitle(selectedEvent),
                            date: selectedEvent.startDate,
                            body: selectedEvent.description ??
                                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla ac rhoncus purus. Ut vestibulum ipsum dictum nulla luctus, vel aliquet erat suscipit. Sed egestas accumsan orci a rhoncus.',
                            event: selectedEvent,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: _DetailSectionCard(
                            title: _secondarySectionTitle(selectedEvent),
                            date: selectedEvent.endDate,
                            body:
                                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla ac rhoncus purus. Ut vestibulum ipsum dictum nulla luctus, vel aliquet erat suscipit. Sed egestas accumsan orci a rhoncus.',
                            event: selectedEvent,
                          ),
                        ),
                      ],
                    ),
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
          ],
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.event});

  final Event? event;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          event?.title ?? 'Event detail',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.w400,
          ),
        ),
        if (event != null) ...[
          const SizedBox(height: 16),
          Text(
            _formatConceptRange(event!.startDate, event!.endDate),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              height: 1.28,
            ),
          ),
        ],
      ],
    );
  }
}

class _DetailSectionCard extends StatelessWidget {
  const _DetailSectionCard({
    required this.title,
    required this.date,
    required this.body,
    required this.event,
  });

  final String title;
  final DateTime date;
  final String body;
  final Event event;

  @override
  Widget build(BuildContext context) {
    final color = conceptEventColor(event.category);

    return Container(
      constraints: const BoxConstraints(maxWidth: 760, minHeight: 300),
      padding: const EdgeInsets.fromLTRB(52, 28, 16, 28),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(58),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final image = Image.asset(
            conceptEventAsset(event.category),
            width: constraints.maxWidth < 560 ? constraints.maxWidth : 250,
            height: 150,
            fit: BoxFit.cover,
          );
          final copy = _DetailSectionCopy(title: title, date: date, body: body);

          if (constraints.maxWidth < 560) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                const SizedBox(height: 20),
                ClipRect(child: image),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: copy),
              const SizedBox(width: 24),
              image,
            ],
          );
        },
      ),
    );
  }
}

class _DetailSectionCopy extends StatelessWidget {
  const _DetailSectionCopy({
    required this.title,
    required this.date,
    required this.body,
  });

  final String title;
  final DateTime date;
  final String body;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        height: 1.28,
        fontWeight: FontWeight.w400,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 25, height: 1.15),
          ),
          const SizedBox(height: 12),
          Text(DateFormat('HH:mm dd/MM/yyyy').format(date)),
          const SizedBox(height: 18),
          Text(body, maxLines: 8, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

String _primarySectionTitle(Event event) {
  return event.category == EventCategory.volcano ? 'First eruption' : event.title;
}

String _secondarySectionTitle(Event event) {
  return event.category == EventCategory.volcano ? 'Big lava stream' : 'Follow-up';
}

String _formatConceptRange(DateTime startDate, DateTime endDate) {
  final formatter = DateFormat('HH:mm dd/MM/yyyy');
  return '${formatter.format(startDate)}\n- ${formatter.format(endDate)}';
}
