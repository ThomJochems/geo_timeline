import '../../domain/models/event.dart';

abstract final class MockEvents {
  static final timeline = <Event>[
    Event(
      id: 'evt-001',
      title: 'Hunga Tonga-Hunga Ha'apai Eruption',
      description:
          'Large submarine volcanic eruption with a powerful atmospheric shockwave and regional tsunami observations.',
      category: EventCategory.volcano,
      startDate: DateTime(2022, 1, 15),
      endDate: DateTime(2022, 1, 16),
      latitude: -20.536,
      longitude: -175.382,
      locationName: 'Tonga volcanic arc',
      imagePath: null,
      createdAt: DateTime(2026, 6, 9),
      updatedAt: DateTime(2026, 6, 9),
    ),
    Event(
      id: 'evt-002',
      title: 'Tohoku Megathrust Earthquake',
      description:
          'Subduction-zone earthquake offshore Japan followed by widespread tsunami inundation.',
      category: EventCategory.earthquake,
      startDate: DateTime(2011, 3, 11),
      endDate: DateTime(2011, 3, 11),
      latitude: 38.297,
      longitude: 142.373,
      locationName: 'Offshore Honshu, Japan',
      imagePath: null,
      createdAt: DateTime(2026, 6, 9),
      updatedAt: DateTime(2026, 6, 9),
    ),
    Event(
      id: 'evt-003',
      title: 'Nyos CO2 Release',
      description:
          'Limnic gas emission event from Lake Nyos involving sudden carbon dioxide release.',
      category: EventCategory.gasEmission,
      startDate: DateTime(1986, 8, 21),
      endDate: DateTime(1986, 8, 22),
      latitude: 6.438,
      longitude: 10.299,
      locationName: 'Lake Nyos, Cameroon',
      imagePath: null,
      createdAt: DateTime(2026, 6, 9),
      updatedAt: DateTime(2026, 6, 9),
    ),
    Event(
      id: 'evt-004',
      title: 'Storegga Slide Tsunami',
      description:
          'Massive submarine landslide off Norway associated with tsunami deposits around the North Atlantic.',
      category: EventCategory.tsunami,
      startDate: DateTime(-6200),
      endDate: DateTime(-6200),
      latitude: 64.866,
      longitude: 1.289,
      locationName: 'Norwegian continental shelf',
      imagePath: null,
      createdAt: DateTime(2026, 6, 9),
      updatedAt: DateTime(2026, 6, 9),
    ),
  ]..sort((a, b) => b.startDate.compareTo(a.startDate));
}
