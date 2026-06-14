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
    return BlocBuilder<EditorBloc, EditorState>(
      builder: (context, state) {
        // Find the current layer at playhead position
        final currentLayer = state.project?.layers.where((layer) {
          return state.playheadPosition >= layer.startTime &&
              state.playheadPosition < layer.endTime;
        }).firstOrNull;

        return Container(
          color: Colors.black,
          child: Center(
            child: currentLayer != null && currentLayer.sourcePath.isNotEmpty
                ? _buildVideoPreview(context, currentLayer.sourcePath, state)
                : _buildPlaceholder(),
          ),
        );
      },
    );
  }

  Widget _buildVideoPreview(BuildContext context, String path, EditorState state) {
    if (_controller?.dataSource != path) {
      _initializeVideo(path);
    }

    if (_isInitialized && _controller != null) {
      return AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      );
    }

    return const CircularProgressIndicator(color: Colors.white);
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.video_library_outlined,
          size: 80,
          color: Colors.white24,
        ),
        const SizedBox(height: 16),
        Text(
          'Add media to preview',
          style: TextStyle(color: Colors.white38, fontSize: 16),
        ),
      ],
    );
  }
}