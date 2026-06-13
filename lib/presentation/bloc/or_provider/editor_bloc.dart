import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/project_model.dart';
import '../../../domain/entities/video_layer.dart';

// Events
abstract class EditorEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProject extends EditorEvent {
  final ProjectModel project;
  LoadProject(this.project);
  @override
  List<Object?> get props => [project];
}

class AddLayer extends EditorEvent {
  final VideoLayer layer;
  AddLayer(this.layer);
  @override
  List<Object?> get props => [layer];
}

class RemoveLayer extends EditorEvent {
  final String layerId;
  RemoveLayer(this.layerId);
  @override
  List<Object?> get props => [layerId];
}

class UpdateLayer extends EditorEvent {
  final VideoLayer layer;
  UpdateLayer(this.layer);
  @override
  List<Object?> get props => [layer];
}

class UpdatePlayhead extends EditorEvent {
  final Duration position;
  UpdatePlayhead(this.position);
  @override
  List<Object?> get props => [position];
}

class UpdateZoom extends EditorEvent {
  final double zoom;
  UpdateZoom(this.zoom);
  @override
  List<Object?> get props => [zoom];
}

class TogglePlayback extends EditorEvent {}

class SelectLayer extends EditorEvent {
  final String? layerId;
  SelectLayer(this.layerId);
  @override
  List<Object?> get props => [layerId];
}

// State
class EditorState extends Equatable {
  final ProjectModel? project;
  final Duration playheadPosition;
  final double zoom;
  final bool isPlaying;
  final String? selectedLayerId;
  final bool isLoading;
  final String? error;

  const EditorState({
    this.project,
    this.playheadPosition = Duration.zero,
    this.zoom = 1.0,
    this.isPlaying = false,
    this.selectedLayerId,
    this.isLoading = false,
    this.error,
  });

  EditorState copyWith({
    ProjectModel? project,
    Duration? playheadPosition,
    double? zoom,
    bool? isPlaying,
    String? selectedLayerId,
    bool? isLoading,
    String? error,
    bool clearSelectedLayer = false,
  }) {
    return EditorState(
      project: project ?? this.project,
      playheadPosition: playheadPosition ?? this.playheadPosition,
      zoom: zoom ?? this.zoom,
      isPlaying: isPlaying ?? this.isPlaying,
      selectedLayerId: clearSelectedLayer ? null : (selectedLayerId ?? this.selectedLayerId),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [project, playheadPosition, zoom, isPlaying, selectedLayerId, isLoading, error];
}

// Bloc
class EditorBloc extends Bloc<EditorEvent, EditorState> {
  EditorBloc() : super(const EditorState()) {
    on<LoadProject>((event, emit) {
      emit(state.copyWith(project: event.project, isLoading: false));
    });

    on<AddLayer>((event, emit) {
      if (state.project == null) return;
      final updatedLayers = [...state.project!.layers, event.layer];
      final maxEndTime = updatedLayers.fold<Duration>(
        Duration.zero,
        (max, layer) => layer.endTime > max ? layer.endTime : max,
      );
      emit(state.copyWith(
        project: state.project!.copyWith(
          layers: updatedLayers,
          totalDuration: maxEndTime,
          modifiedAt: DateTime.now(),
        ),
      ));
    });

    on<RemoveLayer>((event, emit) {
      if (state.project == null) return;
      final updatedLayers = state.project!.layers.where((l) => l.id != event.layerId).toList();
      final maxEndTime = updatedLayers.fold<Duration>(
        Duration.zero,
        (max, layer) => layer.endTime > max ? layer.endTime : max,
      );
      emit(state.copyWith(
        project: state.project!.copyWith(
          layers: updatedLayers,
          totalDuration: maxEndTime,
          modifiedAt: DateTime.now(),
        ),
        clearSelectedLayer: state.selectedLayerId == event.layerId,
      ));
    });

    on<UpdateLayer>((event, emit) {
      if (state.project == null) return;
      final updatedLayers = state.project!.layers.map((l) {
        return l.id == event.layer.id ? event.layer : l;
      }).toList();
      final maxEndTime = updatedLayers.fold<Duration>(
        Duration.zero,
        (max, layer) => layer.endTime > max ? layer.endTime : max,
      );
      emit(state.copyWith(
        project: state.project!.copyWith(
          layers: updatedLayers,
          totalDuration: maxEndTime,
          modifiedAt: DateTime.now(),
        ),
      ));
    });

    on<UpdatePlayhead>((event, emit) {
      emit(state.copyWith(playheadPosition: event.position));
    });

    on<UpdateZoom>((event, emit) {
      emit(state.copyWith(zoom: event.zoom.clamp(0.1, 10.0)));
    });

    on<TogglePlayback>((event, emit) {
      emit(state.copyWith(isPlaying: !state.isPlaying));
    });

    on<SelectLayer>((event, emit) {
      emit(state.copyWith(selectedLayerId: event.layerId, clearSelectedLayer: event.layerId == null));
    });
  }
}