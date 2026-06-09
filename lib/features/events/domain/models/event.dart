import 'package:flutter/foundation.dart';

@immutable
class Event {
  const Event({
    required this.id,
    required this.title,
    required this.occurredAt,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.locationName,
    this.imagePath,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime occurredAt;
  final double latitude;
  final double longitude;
  final String? locationName;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? occurredAt,
    double? latitude,
    double? longitude,
    String? locationName,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDescription = false,
    bool clearLocationName = false,
    bool clearImagePath = false,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : description ?? this.description,
      occurredAt: occurredAt ?? this.occurredAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: clearLocationName ? null : locationName ?? this.locationName,
      imagePath: clearImagePath ? null : imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'occurredAt': occurredAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Event.fromJson(Map<dynamic, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      locationName: json['locationName'] as String?,
      imagePath: json['imagePath'] as String?,
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
            occurredAt == other.occurredAt &&
            latitude == other.latitude &&
            longitude == other.longitude &&
            locationName == other.locationName &&
            imagePath == other.imagePath &&
            createdAt == other.createdAt &&
            updatedAt == other.updatedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    occurredAt,
    latitude,
    longitude,
    locationName,
    imagePath,
    createdAt,
    updatedAt,
  );
}
