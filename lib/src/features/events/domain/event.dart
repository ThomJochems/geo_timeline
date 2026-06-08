import 'package:hive/hive.dart';

class Event {
  const Event({
    required this.id,
    required this.title,
    required this.occurredAt,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.latitude,
    this.longitude,
    this.locationName,
    this.imagePath,
    this.tags = const <String>[],
  });

  static const int typeId = 1;

  final String id;
  final String title;
  final String? description;
  final DateTime occurredAt;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final String? imagePath;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasCoordinates => latitude != null && longitude != null;

  factory Event.create({
    required String title,
    required DateTime occurredAt,
    String? description,
    double? latitude,
    double? longitude,
    String? locationName,
    String? imagePath,
    List<String> tags = const <String>[],
  }) {
    final now = DateTime.now();

    return Event(
      id: now.microsecondsSinceEpoch.toString(),
      title: title,
      description: description,
      occurredAt: occurredAt,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      imagePath: imagePath,
      tags: tags,
      createdAt: now,
      updatedAt: now,
    );
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? occurredAt,
    double? latitude,
    double? longitude,
    String? locationName,
    String? imagePath,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      occurredAt: occurredAt ?? this.occurredAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      imagePath: imagePath ?? this.imagePath,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'title': title,
      'description': description,
      'occurredAt': occurredAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'imagePath': imagePath,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Event.fromJson(Map<String, Object?> json) {
    return Event(
      id: json['id']! as String,
      title: json['title']! as String,
      description: json['description'] as String?,
      occurredAt: DateTime.parse(json['occurredAt']! as String),
      latitude: _optionalDouble(json['latitude']),
      longitude: _optionalDouble(json['longitude']),
      locationName: json['locationName'] as String?,
      imagePath: json['imagePath'] as String?,
      tags: List<String>.from(json['tags'] as List<Object?>? ?? const []),
      createdAt: DateTime.parse(json['createdAt']! as String),
      updatedAt: DateTime.parse(json['updatedAt']! as String),
    );
  }

  static double? _optionalDouble(Object? value) {
    return switch (value) {
      null => null,
      final num number => number.toDouble(),
      _ => throw FormatException('Expected a numeric coordinate, got $value'),
    };
  }
}

class EventAdapter extends TypeAdapter<Event> {
  @override
  int get typeId => Event.typeId;

  @override
  Event read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };

    return Event(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      occurredAt: fields[3] as DateTime,
      latitude: fields[4] as double?,
      longitude: fields[5] as double?,
      locationName: fields[6] as String?,
      imagePath: fields[7] as String?,
      tags: List<String>.from(fields[8] as List? ?? const []),
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.occurredAt)
      ..writeByte(4)
      ..write(obj.latitude)
      ..writeByte(5)
      ..write(obj.longitude)
      ..writeByte(6)
      ..write(obj.locationName)
      ..writeByte(7)
      ..write(obj.imagePath)
      ..writeByte(8)
      ..write(obj.tags)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }
}
