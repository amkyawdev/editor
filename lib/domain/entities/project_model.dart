import 'package:equatable/equatable.dart';
import 'video_layer.dart';

class ProjectModel extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final Duration totalDuration;
  final List<VideoLayer> layers;
  final int width;
  final int height;
  final int frameRate;
  final String? thumbnailPath;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.modifiedAt,
    required this.totalDuration,
    this.layers = const [],
    this.width = 1920,
    this.height = 1080,
    this.frameRate = 30,
    this.thumbnailPath,
  });

  ProjectModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? modifiedAt,
    Duration? totalDuration,
    List<VideoLayer>? layers,
    int? width,
    int? height,
    int? frameRate,
    String? thumbnailPath,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      totalDuration: totalDuration ?? this.totalDuration,
      layers: layers ?? this.layers,
      width: width ?? this.width,
      height: height ?? this.height,
      frameRate: frameRate ?? this.frameRate,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'modifiedAt': modifiedAt.toIso8601String(),
    'totalDuration': totalDuration.inMilliseconds,
    'layers': layers.map((l) => l.toJson()).toList(),
    'width': width,
    'height': height,
    'frameRate': frameRate,
    'thumbnailPath': thumbnailPath,
  };

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
    id: json['id'],
    name: json['name'],
    createdAt: DateTime.parse(json['createdAt']),
    modifiedAt: DateTime.parse(json['modifiedAt']),
    totalDuration: Duration(milliseconds: json['totalDuration']),
    layers: (json['layers'] as List?)?.map((l) => VideoLayer.fromJson(l)).toList() ?? [],
    width: json['width'] ?? 1920,
    height: json['height'] ?? 1080,
    frameRate: json['frameRate'] ?? 30,
    thumbnailPath: json['thumbnailPath'],
  );

  @override
  List<Object?> get props => [id, name, createdAt, modifiedAt, totalDuration, layers, width, height, frameRate];
}