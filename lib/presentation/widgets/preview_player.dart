import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import '../bloc/or_provider/editor_bloc.dart';

class PreviewPlayer extends StatefulWidget {
  const PreviewPlayer({super.key});

  @override
  State<PreviewPlayer> createState() => _PreviewPlayerState();
}

class _PreviewPlayerState extends State<PreviewPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _initializeVideo(String path) {
    if (_controller != null) {
      _controller!.dispose();
    }
    _controller = VideoPlayerController.file(File(path))
      ..initialize().then((_) {
        setState(() => _isInitialized = true);
        _controller!.setLooping(true);
      });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditorBloc, EditorState>(
      listenWhen: (previous, current) =>
          previous.playheadPosition != current.playheadPosition ||
          previous.isPlaying != current.isPlaying,
      listener: (context, state) {
        if (_controller != null && _isInitialized) {
          if (state.isPlaying) {
            _controller!.play();
            _controller!.seekTo(state.playheadPosition);
          } else {
            _controller!.pause();
            _controller!.seekTo(state.playheadPosition);
          }
        }
      },
      child: BlocBuilder<EditorBloc, EditorState>(
        builder: (context, state) {
          // Find the current layer at playhead position
          final currentLayer = state.project?.layers.where((layer) {
            return state.playheadPosition >= layer.startTime &&
                state.playheadPosition < layer.endTime;
          }).firstOrNull;

          return Container(
            color: Colors.black,
            child: Center(
              child: currentLayer != null
                  ? _buildVideoPreview(currentLayer.sourcePath, state)
                  : _buildPlaceholder(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoPreview(String path, EditorState state) {
    if (_controller?.dataSource != path) {
      _initializeVideo(path);
    }

    if (_isInitialized && _controller != null) {
      // Adjust for layer start time
      final currentLayer = state.project?.layers.where((layer) {
        return state.playheadPosition >= layer.startTime &&
            state.playheadPosition < layer.endTime;
      }).firstOrNull;

      if (currentLayer != null) {
        final relativePosition = state.playheadPosition - currentLayer.startTime;
        _controller!.seekTo(relativePosition);
      }

      return AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      );
    }

    return const CircularProgressIndicator();
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.movie_outlined,
          size: 64,
          color: Colors.white24,
        ),
        const SizedBox(height: 16),
        Text(
          'Add media to preview',
          style: TextStyle(color: Colors.white38),
        ),
      ],
    );
  }
}