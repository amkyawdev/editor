import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/or_provider/editor_bloc.dart';
import '../../widgets/preview_player.dart';
import '../../widgets/timeline/timeline_widget.dart';
import '../../widgets/toolbar/editing_toolbar.dart';
import '../../widgets/dialogs/export_dialog.dart';
import '../../../domain/entities/project_model.dart';
import '../../../data/repositories/project_repository.dart';

class EditorScreen extends StatelessWidget {
  final ProjectModel project;

  const EditorScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditorBloc()..add(LoadProject(project)),
      child: const EditorView(),
    );
  }
}

class EditorView extends StatelessWidget {
  const EditorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<EditorBloc, EditorState>(
          builder: (context, state) {
            return Text(state.project?.name ?? 'Editor');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveProject(context),
            tooltip: 'Save',
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _showExportDialog(context),
            tooltip: 'Export',
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview Player
          const Expanded(
            flex: 4,
            child: PreviewPlayer(),
          ),
          // Playback Controls
          _buildPlaybackControls(context),
          // Timeline
          const Expanded(
            flex: 3,
            child: TimelineWidget(),
          ),
          // Toolbar
          const EditingToolbar(),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls(BuildContext context) {
    return BlocBuilder<EditorBloc, EditorState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).cardColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: () {
                  context.read<EditorBloc>().add(UpdatePlayhead(Duration.zero));
                },
              ),
              IconButton(
                icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: 40,
                onPressed: () {
                  context.read<EditorBloc>().add(TogglePlayback());
                },
              ),
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: () {
                  context.read<EditorBloc>().add(TogglePlayback());
                  context.read<EditorBloc>().add(UpdatePlayhead(Duration.zero));
                },
              ),
              const SizedBox(width: 24),
              Text(
                _formatDuration(state.playheadPosition),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 16,
                ),
              ),
              Text(
                ' / ${_formatDuration(state.project?.totalDuration ?? Duration.zero)}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 16,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final millis = ((duration.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
    return '$minutes:$seconds.$millis';
  }

  Future<void> _saveProject(BuildContext context) async {
    final state = context.read<EditorBloc>().state;
    if (state.project != null) {
      final repository = ProjectRepository();
      await repository.saveProject(state.project!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project saved')),
        );
      }
    }
  }

  void _showExportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const ExportDialog(),
    );
  }
}