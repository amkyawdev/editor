import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/or_provider/editor_bloc.dart';
import '../../../domain/entities/video_layer.dart';

class TimelineWidget extends StatelessWidget {
  const TimelineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: Column(
        children: [
          _buildTimeRuler(context),
          Expanded(
            child: _buildTimelineContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRuler(BuildContext context) {
    return BlocBuilder<EditorBloc, EditorState>(
      builder: (context, state) {
        final totalDuration = state.project?.totalDuration ?? const Duration(seconds: 10);
        final pixelsPerSecond = 100.0 * state.zoom;
        final totalWidth = totalDuration.inMilliseconds / 1000 * pixelsPerSecond;

        return Container(
          height: 30,
          color: const Color(0xFF252538),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: totalWidth.clamp(MediaQuery.of(context).size.width, double.infinity),
              child: CustomPaint(
                painter: TimeRulerPainter(
                  totalDuration: totalDuration,
                  pixelsPerSecond: pixelsPerSecond,
                  playheadPosition: state.playheadPosition,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineContent(BuildContext context) {
    return BlocBuilder<EditorBloc, EditorState>(
      builder: (context, state) {
        final layers = state.project?.layers ?? [];

        return GestureDetector(
          onTapUp: (details) => _handleTap(context, details, state),
          onHorizontalDragUpdate: (details) => _handleDrag(context, details, state),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Track labels
                SizedBox(
                  width: 80,
                  child: Column(
                    children: layers.map((layer) => _buildTrackLabel(layer)).toList(),
                  ),
                ),
                // Track content
                SizedBox(
                  width: _calculateTotalWidth(context, state),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          // Layers
                          ...layers.map((layer) => _buildLayerBlock(context, layer, state)),
                          // Playhead
                          _buildPlayhead(state),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrackLabel(VideoLayer layer) {
    IconData icon;
    switch (layer.type) {
      case LayerType.video:
        icon = Icons.videocam;
        break;
      case LayerType.audio:
        icon = Icons.audiotrack;
        break;
      case LayerType.text:
        icon = Icons.text_fields;
        break;
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white12),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white54),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Layer',
              style: const TextStyle(fontSize: 12, color: Colors.white54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerBlock(BuildContext context, VideoLayer layer, EditorState state) {
    final pixelsPerSecond = 100.0 * state.zoom;
    final left = layer.startTime.inMilliseconds / 1000 * pixelsPerSecond;
    final width = layer.duration.inMilliseconds / 1000 * pixelsPerSecond;
    final isSelected = state.selectedLayerId == layer.id;

    Color color;
    switch (layer.type) {
      case LayerType.video:
        color = Colors.blue;
        break;
      case LayerType.audio:
        color = Colors.green;
        break;
      case LayerType.text:
        color = Colors.orange;
        break;
    }

    return Positioned(
      top: 4,
      left: left,
      child: GestureDetector(
        onTap: () => context.read<EditorBloc>().add(SelectLayer(layer.id)),
        child: Container(
          width: width,
          height: 52,
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            borderRadius: BorderRadius.circular(4),
            border: isSelected
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              layer.type.name.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayhead(EditorState state) {
    final pixelsPerSecond = 100.0 * state.zoom;
    final left = state.playheadPosition.inMilliseconds / 1000 * pixelsPerSecond;

    return Positioned(
      left: left,
      top: 0,
      bottom: 0,
      child: Container(
        width: 2,
        color: Colors.red,
        child: Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotalWidth(BuildContext context, EditorState state) {
    final totalDuration = state.project?.totalDuration ?? const Duration(seconds: 10);
    final pixelsPerSecond = 100.0 * state.zoom;
    return (totalDuration.inMilliseconds / 1000 * pixelsPerSecond)
        .clamp(MediaQuery.of(context).size.width - 80, double.infinity);
  }

  void _handleTap(BuildContext context, TapUpDetails details, EditorState state) {
    final pixelsPerSecond = 100.0 * state.zoom;
    final position = Duration(
      milliseconds: ((details.localPosition.dx + 80) / pixelsPerSecond * 1000).round(),
    );
    context.read<EditorBloc>().add(UpdatePlayhead(position));
  }

  void _handleDrag(BuildContext context, DragUpdateDetails details, EditorState state) {
    final pixelsPerSecond = 100.0 * state.zoom;
    final position = Duration(
      milliseconds: ((details.localPosition.dx + 80) / pixelsPerSecond * 1000).round(),
    );
    context.read<EditorBloc>().add(UpdatePlayhead(position));
  }
}

class TimeRulerPainter extends CustomPainter {
  final Duration totalDuration;
  final double pixelsPerSecond;
  final Duration playheadPosition;

  TimeRulerPainter({
    required this.totalDuration,
    required this.pixelsPerSecond,
    required this.playheadPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final interval = _calculateInterval();
    final totalSeconds = totalDuration.inSeconds + 1;

    for (int i = 0; i <= totalSeconds; i += interval) {
      final x = i * pixelsPerSecond;
      canvas.drawLine(
        Offset(x, size.height - 10),
        Offset(x, size.height),
        paint,
      );

      textPainter.text = TextSpan(
        text: _formatTime(i),
        style: const TextStyle(fontSize: 10, color: Colors.white54),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + 4, 4));
    }
  }

  int _calculateInterval() {
    if (pixelsPerSecond > 200) return 1;
    if (pixelsPerSecond > 100) return 2;
    if (pixelsPerSecond > 50) return 5;
    return 10;
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  bool shouldRepaint(covariant TimeRulerPainter oldDelegate) {
    return oldDelegate.pixelsPerSecond != pixelsPerSecond ||
        oldDelegate.totalDuration != totalDuration;
  }
}