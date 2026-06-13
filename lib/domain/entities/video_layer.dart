import 'package:equatable/equatable.dart';

enum LayerType { video, audio, text }

class VideoLayer extends Equatable {
  final String id;
  final LayerType type;
  final String sourcePath;
  final Duration startTime;
  final Duration endTime;
  final Duration originalDuration;
  final double volume;
  final double speed;
  final Map<String, dynamic> effects;
  final Map<String, dynamic> transform;

  const VideoLayer({
    required this.id,
    required this.type,
    required this.sourcePath,
    required this.startTime,
    required this.endTime,
    required this.originalDuration,
    this.volume = 1.0,
    this.speed = 1.0,
    this.effects = const {},
    this.transform = const {},
  });

  Duration get duration => endTime - startTime;

  VideoLayer copyWith({
    String? id,
    LayerType? type,
    String? sourcePath,
    Duration? startTime,
    Duration? endTime,
    Duration? originalDuration,
    double? volume,
    double? speed,
    Map<String, dynamic>? effects,
    Map<String, dynamic>? transform,
  }) {
    return VideoLayer(
      id: id ?? this.id,
      type: type ?? this.type,
      sourcePath: sourcePath ?? this.sourcePath,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      originalDuration: originalDuration ?? this.originalDuration,
      volume: volume ?? this.volume,
      speed: speed ?? this.speed,
      effects: effects ?? this.effects,
      transform: transform ?? this.transform,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.index,
    'sourcePath': sourcePath,
    'startTime': startTime.inMilliseconds,
    'endTime': endTime.inMilliseconds,
    'originalDuration': originalDuration.inMilliseconds,
    'volume': volume,
    'speed': speed,
    'effects': effects,
    'transform': transform,
  };

  factory VideoLayer.fromJson(Map<String, dynamic> json) => VideoLayer(
    id: json['id'],
    type: LayerType.values[json['type']],
    sourcePath: json['sourcePath'],
    startTime: Duration(milliseconds: json['startTime']),
    endTime: Duration(milliseconds: json['endTime']),
    originalDuration: Duration(milliseconds: json['originalDuration']),
    volume: json['volume'] ?? 1.0,
    speed: json['speed'] ?? 1.0,
    effects: json['effects'] ?? {},
    transform: json['transform'] ?? {},
  );

  @override
  List<Object?> get props => [id, type, sourcePath, startTime, endTime, volume, speed, effects, transform];
}