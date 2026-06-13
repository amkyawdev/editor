import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/or_provider/editor_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/video_layer.dart';

class EditingToolbar extends StatelessWidget {
  const EditingToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Theme.of(context).cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToolButton(
            context,
            icon: Icons.add_circle_outline,
            label: 'Add Media',
            onPressed: () => _addMedia(context),
          ),
          _buildToolButton(
            context,
            icon: Icons.content_cut,
            label: 'Split',
            onPressed: () => _splitClip(context),
          ),
          _buildToolButton(
            context,
            icon: Icons.speed,
            label: 'Speed',
            onPressed: () => _showSpeedDialog(context),
          ),
          _buildToolButton(
            context,
            icon: Icons.text_fields,
            label: 'Text',
            onPressed: () => _addText(context),
          ),
          _buildToolButton(
            context,
            icon: Icons.filter,
            label: 'Effects',
            onPressed: () => _showEffectsDialog(context),
          ),
          _buildToolButton(
            context,
            icon: Icons.music_note,
            label: 'Audio',
            onPressed: () => _addAudio(context),
          ),
          _buildToolButton(
            context,
            icon: Icons.zoom_in,
            label: 'Zoom',
            onPressed: () => _toggleZoom(context),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: Colors.white70),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addMedia(BuildContext context) async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);
    
    if (video != null && context.mounted) {
      final layer = VideoLayer(
        id: const Uuid().v4(),
        type: LayerType.video,
        sourcePath: video.path,
        startTime: Duration.zero,
        endTime: const Duration(seconds: 10),
        originalDuration: const Duration(seconds: 10),
      );
      context.read<EditorBloc>().add(AddLayer(layer));
    }
  }

  void _splitClip(BuildContext context) {
    final state = context.read<EditorBloc>().state;
    if (state.selectedLayerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a layer first')),
      );
      return;
    }

    final layer = state.project?.layers.firstWhere(
      (l) => l.id == state.selectedLayerId,
    );
    if (layer != null) {
      final splitPoint = state.playheadPosition;
      if (splitPoint > layer.startTime && splitPoint < layer.endTime) {
        final firstPart = layer.copyWith(endTime: splitPoint);
        final secondPart = layer.copyWith(
          id: const Uuid().v4(),
          startTime: splitPoint,
        );
        
        context.read<EditorBloc>().add(UpdateLayer(firstPart));
        context.read<EditorBloc>().add(AddLayer(secondPart));
      }
    }
  }

  void _showSpeedDialog(BuildContext context) {
    final state = context.read<EditorBloc>().state;
    if (state.selectedLayerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a layer first')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adjust Speed'),
        content: StatefulBuilder(
          builder: (context, setState) {
            double speed = 1.0;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${speed.toStringAsFixed(1)}x'),
                Slider(
                  value: speed,
                  min: 0.25,
                  max: 4.0,
                  divisions: 15,
                  label: '${speed.toStringAsFixed(1)}x',
                  onChanged: (value) {
                    speed = value;
                    (context as Element).markNeedsBuild();
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _speedPreset(context, 0.5, '0.5x'),
                    _speedPreset(context, 1.0, '1x'),
                    _speedPreset(context, 2.0, '2x'),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _speedPreset(BuildContext context, double speed, String label) {
    return ElevatedButton(
      onPressed: () {
        final state = context.read<EditorBloc>().state;
        final layer = state.project?.layers.firstWhere(
          (l) => l.id == state.selectedLayerId,
        );
        if (layer != null) {
          final newDuration = Duration(
            milliseconds: (layer.originalDuration.inMilliseconds / speed).round(),
          );
          context.read<EditorBloc>().add(UpdateLayer(
            layer.copyWith(speed: speed, endTime: layer.startTime + newDuration),
          ));
        }
        Navigator.pop(context);
      },
      child: Text(label),
    );
  }

  void _addText(BuildContext context) {
    final layer = VideoLayer(
      id: const Uuid().v4(),
      type: LayerType.text,
      sourcePath: '',
      startTime: context.read<EditorBloc>().state.playheadPosition,
      endTime: context.read<EditorBloc>().state.playheadPosition + const Duration(seconds: 5),
      originalDuration: const Duration(seconds: 5),
    );
    context.read<EditorBloc>().add(AddLayer(layer));
  }

  void _showEffectsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Effects',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _effectChip(context, 'Grayscale'),
                _effectChip(context, 'Sepia'),
                _effectChip(context, 'Blur'),
                _effectChip(context, 'Sharpen'),
                _effectChip(context, 'Brightness'),
                _effectChip(context, 'Contrast'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _effectChip(BuildContext context, String effect) {
    return ActionChip(
      label: Text(effect),
      onPressed: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Applied $effect effect')),
        );
      },
    );
  }

  Future<void> _addAudio(BuildContext context) async {
    final picker = ImagePicker();
    final audio = await picker.pickVideo(source: ImageSource.gallery);
    
    if (audio != null && context.mounted) {
      final layer = VideoLayer(
        id: const Uuid().v4(),
        type: LayerType.audio,
        sourcePath: audio.path,
        startTime: Duration.zero,
        endTime: const Duration(seconds: 30),
        originalDuration: const Duration(seconds: 30),
      );
      context.read<EditorBloc>().add(AddLayer(layer));
    }
  }

  void _toggleZoom(BuildContext context) {
    final state = context.read<EditorBloc>().state;
    final newZoom = state.zoom == 1.0 ? 2.0 : 1.0;
    context.read<EditorBloc>().add(UpdateZoom(newZoom));
  }
}