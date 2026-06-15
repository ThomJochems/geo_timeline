import '../../domain/models/event.dart';

abstract final class MockEvents {
  static final timeline = <Event>[
    Event(
      id: 'evt-001',
      title: 'Eruption of mt. Vesuvius',
      description:
          'A major eruption sequence with elevated ash and lava activity recorded overnight.',
      category: EventCategory.volcano,
      startDate: DateTime(2026, 3, 11, 22, 7),
      endDate: DateTime(2026, 3, 12, 1, 39),
      latitude: 40.821,
      longitude: 14.426,
      locationName: 'Mount Vesuvius, Italy',
      imagePath: null,
      createdAt: DateTime(2026, 6, 9),
      updatedAt: DateTime(2026, 6, 9),
    ),
    Event(
      id: 'evt-002',
      title: 'Earthquake off the coast of Sicily',
      description:
          'Seismic activity detected offshore with a compact waveform burst and short aftershock window.',
      category: EventCategory.earthquake,
      startDate: DateTime(2026, 3, 11, 23, 4),
      endDate: DateTime(2026, 3, 12, 0, 45),
      latitude: 37.599,
      longitude: 14.015,
      locationName: 'Off the coast of Sicily',
      imagePath: null,
      createdAt: DateTime(2026, 6, 9),
      updatedAt: DateTime(2026, 6, 9),
    ),
    Event(
      id: 'evt-003',
      title: 'High SO2',
      description:
          'High sulphur dioxide concentration measured near an active volcanic plume.',
      category: EventCategory.gasEmission,
      startDate: DateTime(2026, 3, 12, 0, 45),
      endDate: DateTime(2026, 3, 12, 2, 10),
      latitude: 37.734,
      longitude: 15.004,
      locationName: 'Eastern Sicily',
      imagePath: null,
      createdAt: DateTime(2026, 6, 9),
      updatedAt: DateTime(2026, 6, 9),
    ),
    Event(
      id: 'evt-004',
      title: 'Eruption of mt. Etna',
      description:
          'First eruption pulse followed by a larger lava stream on the southeastern flank.',
      category: EventCategory.volcano,
      startDate: DateTime(2026, 3, 11, 22, 7),
      endDate: DateTime(2026, 3, 11, 23, 59),
      latitude: 37.751,
      longitude: 14.993,
      locationName: 'Mount Etna, Italy',
      imagePath: null,
      createdAt: DateTime(2026, 6, 9),
      updatedAt: DateTime(2026, 6, 9),
    ),
  ]..sort((a, b) => b.startDate.compareTo(a.startDate));
}
