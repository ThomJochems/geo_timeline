import 'package:flutter/material.dart';

import '../../domain/models/event.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key, this.event});

  final Event? event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event?.title ?? 'Event detail')),
      body: const SizedBox.expand(),
    );
  }
}
