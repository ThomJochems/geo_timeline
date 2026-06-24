import 'package:flutter/foundation.dart';

enum EventCategory {
  earthquake,
  volcano,
  gasEmission,
  tsunami;

  String get label {
    return switch (this) {
      EventCategory.earthquake => 'Earthquake',
      EventCategory.volcano => 'Volcano',
      EventCategory.gasEmission => 'Gas Emission',
      EventCategory.tsunami => 'Tsunami',
    };
  }

  static EventCategory fromName(String name) {
    return EventCategory.values.firstWhere(
      (category) => category.name == name,
      orElse: () => EventCategory.earthquake,
    );
  }
}

@immutable
class Event {
  Event({
    required this.id,
    required this.title,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.locationName,
    String? imagePath,
    List<String> imagePaths = const [],
  }) : imagePaths = _normalizeImagePaths(imagePaths, imagePath);

  final String id;
  final String title;
  final String? description;
  final EventCategory category;
  final DateTime startDate;
  final DateTime endDate;
  final double latitude;
  final double longitude;
  final String? locationName;
  final List<String> imagePaths;
  final DateTime createdAt;
  final DateTime updatedAt;

  DateTime get occurredAt => startDate;
  String? get imagePath => imagePaths.isEmpty ? null : imagePaths.first;

  Event copyWith({
    String? id,
    String? title,
    String? description,
    EventCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    double? latitude,
    double? longitude,
    String? locationName,
    String? imagePath,
    List<String>? imagePaths,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDescription = false,
    bool clearLocationName = false,
    bool clearImagePaths = false,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : description ?? this.description,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: clearLocationName
          ? null
          : locationName ?? this.locationName,
      imagePaths: clearImagePaths
          ? const []
          : imagePaths ?? (imagePath == null ? this.imagePaths : [imagePath]),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'imagePath': imagePath,
      'imagePaths': imagePaths,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Event.fromJson(Map<dynamic, dynamic> json) {
    final startDateValue = json['startDate'] as String?;
    final endDateValue = json['endDate'] as String?;
    final legacyOccurredAtValue = json['occurredAt'] as String?;
    final fallbackDateValue = DateTime.now().toIso8601String();
    final imagePathsValue = json['imagePaths'];
    final legacyImagePath = json['imagePath'] as String?;
    final imagePaths = _normalizeImagePaths(
      imagePathsValue is List
          ? imagePathsValue.whereType<String>()
          : const <String>[],
      legacyImagePath,
    );

    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: EventCategory.fromName(json['category'] as String? ?? ''),
      startDate: DateTime.parse(
        startDateValue ?? legacyOccurredAtValue ?? fallbackDateValue,
      ),
      endDate: DateTime.parse(
        endDateValue ??
            startDateValue ??
            legacyOccurredAtValue ??
            fallbackDateValue,
      ),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      locationName: json['locationName'] as String?,
      imagePaths: imagePaths,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Event &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            title == other.title &&
            description == other.description &&
            category == other.category &&
            startDate == other.startDate &&
            endDate == other.endDate &&
            latitude == other.latitude &&
            longitude == other.longitude &&
            locationName == other.locationName &&
            listEquals(imagePaths, other.imagePaths) &&
            createdAt == other.createdAt &&
            updatedAt == other.updatedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    category,
    startDate,
    endDate,
    latitude,
    longitude,
    locationName,
    Object.hashAll(imagePaths),
    createdAt,
    updatedAt,
  );

  static List<String> _normalizeImagePaths(
    Iterable<String> imagePaths,
    String? legacyImagePath,
  ) {
    final normalizedPaths = imagePaths
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .toList(growable: false);

    if (normalizedPaths.isNotEmpty) {
      return List.unmodifiable(normalizedPaths);
    }

    final normalizedLegacyPath = legacyImagePath?.trim();
    if (normalizedLegacyPath == null || normalizedLegacyPath.isEmpty) {
      return const [];
    }

    return List.unmodifiable([normalizedLegacyPath]);
  }
}
