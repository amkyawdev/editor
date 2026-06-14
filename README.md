# Amkyaw Editor

A powerful video editor app built with Flutter, inspired by Alight Motion.

## Features

- 📁 **Project Management** - Create, save, and manage multiple video projects
- 🎬 **Video Editing Workspace** - Full-featured editor with timeline
- ▶️ **Real-time Preview** - Live video preview with playback controls
- 🛠️ **Editing Tools**
  - Add Media - Import video files
  - Split - Split clips at playhead position
  - Speed - Adjust video playback speed (0.25x - 4x)
  - Text - Add text overlays
  - Effects - Apply visual effects (Grayscale, Sepia, Blur, etc.)
  - Audio - Add audio tracks
  - Zoom - Timeline zoom control
- 📤 **Export** - Export videos with customizable resolution and bitrate
- ⚙️ **Settings** - Configure default export settings
- 🌙 **Dark Theme** - Modern dark UI optimized for video editing

## Architecture

Built with **Clean Architecture** principles:

```
lib/
├── core/           # Shared utilities, constants, theme
│   ├── constants/  # App constants
│   ├── theme/      # Dark theme configuration
│   └── utils/       # FFmpeg helper, updater
├── data/           # Data layer
│   ├── datasources/ # Local storage, API
│   └── repositories/# Repository implementations
├── domain/         # Business logic
│   └── entities/   # Video layer, project model
└── presentation/    # UI layer
    ├── bloc/       # BLoC state management
    ├── screens/     # Home, Editor, Settings
    └── widgets/     # Timeline, toolbar, preview
```

## Dependencies

- **State Management**: flutter_bloc, provider
- **Video**: video_player
- **Storage**: hive, shared_preferences, path_provider
- **UI**: google_fonts, flutter_colorpicker
- **Utils**: uuid, image_picker

## Getting Started

### Prerequisites

- Flutter SDK 3.24.0+
- Android SDK 34+
- Java 17

### Installation

```bash
# Clone the repository
git clone https://github.com/amkyawdev/editor.git

# Navigate to project
cd editor

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Build

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# iOS (requires macOS)
flutter build ios --release
```

## CI/CD

GitHub Actions workflows are configured for automated builds:

- **Android**: Builds debug APK on every push
- **iOS**: Builds simulator IPA on every push

## Screenshots

| Home | Editor |
|------|--------|
| Project list | Timeline & Preview |

## License

Private project - All rights reserved

## Author

**Amkyaw Dev**

- GitHub: [@amkyawdev](https://github.com/amkyawdev)