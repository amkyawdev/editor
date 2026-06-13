import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/datasources/local_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedResolution = '1080p';
  int _selectedBitrate = AppConstants.defaultBitrate;
  int _selectedFrameRate = AppConstants.defaultFrameRate;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _selectedResolution = LocalStorage.getSetting<String>('resolution') ?? '1080p';
      _selectedBitrate = LocalStorage.getSetting<int>('bitrate') ?? AppConstants.defaultBitrate;
      _selectedFrameRate = LocalStorage.getSetting<int>('frameRate') ?? AppConstants.defaultFrameRate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Export Settings'),
          _buildResolutionTile(),
          _buildBitrateTile(),
          _buildFrameRateTile(),
          const Divider(),
          _buildSectionHeader('About'),
          _buildAboutTile(),
          _buildVersionTile(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildResolutionTile() {
    return ListTile(
      title: const Text('Resolution'),
      subtitle: Text(_selectedResolution),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showResolutionDialog(),
    );
  }

  Widget _buildBitrateTile() {
    return ListTile(
      title: const Text('Bitrate'),
      subtitle: Text('${(_selectedBitrate / 1000000).toStringAsFixed(1)} Mbps'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showBitrateDialog(),
    );
  }

  Widget _buildFrameRateTile() {
    return ListTile(
      title: const Text('Frame Rate'),
      subtitle: Text('$_selectedFrameRate fps'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showFrameRateDialog(),
    );
  }

  Widget _buildAboutTile() {
    return ListTile(
      title: const Text('About Amkyaw Editor'),
      subtitle: const Text('Professional video editing app'),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: AppConstants.appName,
          applicationVersion: AppConstants.appVersion,
          applicationIcon: const Icon(Icons.video_library, size: 48),
          children: const [
            Text('A powerful video editor with timeline, effects, and real-time preview.'),
          ],
        );
      },
    );
  }

  Widget _buildVersionTile() {
    return ListTile(
      title: const Text('Version'),
      subtitle: const Text(AppConstants.appVersion),
    );
  }

  void _showResolutionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Resolution'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.supportedResolutions.map((res) {
            return RadioListTile<String>(
              title: Text(res),
              subtitle: Text(_getResolutionDimensions(res)),
              value: res,
              groupValue: _selectedResolution,
              onChanged: (value) {
                setState(() => _selectedResolution = value!);
                LocalStorage.saveSetting('resolution', value);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showBitrateDialog() {
    final bitrates = [4000000, 6000000, 8000000, 12000000, 20000000];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Bitrate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: bitrates.map((bitrate) {
            return RadioListTile<int>(
              title: Text('${(bitrate / 1000000).toStringAsFixed(1)} Mbps'),
              value: bitrate,
              groupValue: _selectedBitrate,
              onChanged: (value) {
                setState(() => _selectedBitrate = value!);
                LocalStorage.saveSetting('bitrate', value);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFrameRateDialog() {
    final frameRates = [24, 30, 60];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Frame Rate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: frameRates.map((fps) {
            return RadioListTile<int>(
              title: Text('$fps fps'),
              subtitle: Text(_getFrameRateDescription(fps)),
              value: fps,
              groupValue: _selectedFrameRate,
              onChanged: (value) {
                setState(() => _selectedFrameRate = value!);
                LocalStorage.saveSetting('frameRate', value);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getResolutionDimensions(String resolution) {
    final dims = AppConstants.resolutionDimensions[resolution] ?? [1920, 1080];
    return '${dims[0]} x ${dims[1]}';
  }

  String _getFrameRateDescription(int fps) {
    switch (fps) {
      case 24:
        return 'Cinematic';
      case 30:
        return 'Standard';
      case 60:
        return 'Smooth';
      default:
        return '';
    }
  }
}