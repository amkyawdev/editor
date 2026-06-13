class AppConstants {
  static const String appName = 'Amkyaw Editor';
  static const String appVersion = '1.0.0';
  
  // Timeline
  static const double defaultTimelineHeight = 200.0;
  static const double minZoom = 0.1;
  static const double maxZoom = 10.0;
  static const double defaultZoom = 1.0;
  
  // Video Export
  static const int defaultBitrate = 8000000;
  static const int defaultFrameRate = 30;
  static const List<String> supportedResolutions = ['720p', '1080p', '4K'];
  static const Map<String, List<int>> resolutionDimensions = {
    '720p': [1280, 720],
    '1080p': [1920, 1080],
    '4K': [3840, 2160],
  };
  
  // Storage
  static const String projectBoxName = 'projects';
  static const String settingsBoxName = 'settings';
  static const String draftBoxName = 'drafts';
  
  // Network
  static const String updateApiBaseUrl = 'https://api.example.com';
  static const Duration apiTimeout = Duration(seconds: 30);
}