import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/ffmpeg_helper.dart';
import '../../../domain/entities/video_layer.dart';
import '../../bloc/or_provider/editor_bloc.dart';

class ExportDialog extends StatefulWidget {
  const ExportDialog({super.key});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  String _selectedResolution = '1080p';
  int _selectedBitrate = AppConstants.defaultBitrate;
  int _selectedFrameRate = AppConstants.defaultFrameRate;
  bool _isExporting = false;
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Export Video',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isExporting) ...[
            _buildExportProgress(),
          ] else ...[
            _buildResolutionSelector(),
            const SizedBox(height: 16),
            _buildBitrateSlider(),
            const SizedBox(height: 16),
            _buildFrameRateSelector(),
            const SizedBox(height: 24),
            _buildExportButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildResolutionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Resolution', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: AppConstants.supportedResolutions.map((res) {
            return ButtonSegment(value: res, label: Text(res));
          }).toList(),
          selected: {_selectedResolution},
          onSelectionChanged: (selection) {
            setState(() => _selectedResolution = selection.first);
          },
        ),
      ],
    );
  }

  Widget _buildBitrateSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Bitrate', style: TextStyle(fontWeight: FontWeight.w500)),
            Text('${(_selectedBitrate / 1000000).toStringAsFixed(1)} Mbps'),
          ],
        ),
        Slider(
          value: _selectedBitrate.toDouble(),
          min: 2000000,
          max: 20000000,
          divisions: 9,
          onChanged: (value) {
            setState(() => _selectedBitrate = value.round());
          },
        ),
      ],
    );
  }

  Widget _buildFrameRateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Frame Rate', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 24, label: Text('24 fps')),
            ButtonSegment(value: 30, label: Text('30 fps')),
            ButtonSegment(value: 60, label: Text('60 fps')),
          ],
          selected: {_selectedFrameRate},
          onSelectionChanged: (selection) {
            setState(() => _selectedFrameRate = selection.first);
          },
        ),
      ],
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _startExport,
        icon: const Icon(Icons.file_upload),
        label: const Text('Export'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildExportProgress() {
    return Column(
      children: [
        const SizedBox(height: 32),
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: _progress,
                strokeWidth: 8,
              ),
              Text(
                '${(_progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Exporting video...',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'Please wait while your video is being processed',
          style: TextStyle(color: Colors.white54, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _startExport() async {
    setState(() {
      _isExporting = true;
      _progress = 0.0;
    });

    try {
      final state = context.read<EditorBloc>().state;
      final dimensions = AppConstants.resolutionDimensions[_selectedResolution]!;
      
      // Get first video layer as input
      final videoLayer = state.project?.layers.where((l) => l.type == LayerType.video).firstOrNull;
      if (videoLayer == null) {
        throw Exception('No video to export');
      }

      await FFmpegHelper.exportVideo(
        videoLayer.sourcePath,
        '/tmp/export_output.mp4',
        width: dimensions[0],
        height: dimensions[1],
        bitrate: _selectedBitrate,
        frameRate: _selectedFrameRate,
        onProgress: (progress) {
          setState(() => _progress = progress.clamp(0.0, 1.0));
        },
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}