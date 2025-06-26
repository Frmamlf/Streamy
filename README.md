# Streamy - Advanced Cloud Streaming Platform

Streamy is a comprehensive, modern streaming application built with Flutter that rivals CloudStream in functionality and performance. It features a robust plugin system, advanced video player, offline downloads, and extensive content discovery capabilities.

## 🚀 Key Features

### Core Architecture
- **Plugin System**: Dynamic provider loading with CloudStream-style .cs3 plugin support
- **Multi-Provider Support**: Aggregate content from multiple streaming sources
- **Advanced API**: Comprehensive content discovery and management system
- **Modular Design**: Clean, maintainable, and scalable codebase

### Content Discovery
- **Real-time Search**: Search across all enabled providers simultaneously
- **Trending Content**: Automatically curated trending and popular content
- **Genre Filtering**: Browse content by categories (Movies, TV Shows, Anime, etc.)
- **Smart Recommendations**: AI-powered content suggestions based on viewing history
- **Favorites Management**: Save and organize favorite content
- **Continue Watching**: Resume content from where you left off

### Advanced Video Player
- **Multiple Subtitle Formats**: Support for SRT, VTT, ASS/SSA, TTML, and LRC
- **Subtitle Customization**: Font, size, color, outline, and positioning options
- **Multiple Audio Tracks**: Switch between different audio languages
- **Playback Controls**: Speed control, seek preview, gestures
- **Picture-in-Picture**: Continue watching while using other apps
- **Casting Support**: Chromecast and AirPlay integration
- **Error Recovery**: Automatic retry and fallback mechanisms

### Download Manager
- **Offline Support**: Download content for offline viewing
- **Resume Downloads**: Pause and resume interrupted downloads
- **Quality Selection**: Choose from multiple quality options (480p-4K)
- **Background Downloads**: Downloads continue in background
- **Storage Management**: Automatic cleanup and space optimization
- **Progress Tracking**: Real-time download progress and speed monitoring

### Plugin Management
- **Repository System**: Add custom plugin repositories
- **Automatic Updates**: Keep plugins up to date
- **Enable/Disable**: Control which providers are active
- **Metadata Display**: View provider information and supported content types
- **Error Handling**: Graceful plugin error management

### User Experience
- **Modern UI**: Beautiful, intuitive interface with Material Design 3
- **Dark Theme**: Optimized for comfortable viewing
- **Internationalization**: Support for multiple languages (English, Arabic)
- **Performance**: Optimized for smooth scrolling and fast content loading
- **Accessibility**: Screen reader support and keyboard navigation

## 📱 Screenshots

*[Screenshots would be added here in a real implementation]*

## 🏗️ Architecture

### Core Modules

#### `/core/api/`
- **main_api.dart**: Core API interfaces and data models
- Unified interface for all content providers
- Search, load, and streaming response models

#### `/core/plugins/`
- **plugin_manager.dart**: Dynamic plugin loading and management
- Repository system for plugin discovery
- Plugin state management and error handling

#### `/core/providers/`
- **anime_providers.dart**: Built-in anime streaming providers
- **movie_providers.dart**: Built-in movie/TV streaming providers
- Extensible provider architecture

#### `/core/extractors/`
- **extractor_api.dart**: Video link extraction interface
- **extractors.dart**: Implementation for popular video hosts
- Registry system for extractor management

#### `/core/downloads/`
- **download_manager.dart**: Complete offline download system
- Resume support, quality selection, progress tracking
- Storage optimization and automatic cleanup

#### `/core/subtitles/`
- **subtitle_service.dart**: Advanced subtitle management
- Multiple format support with styling options
- Automatic language detection and selection

#### `/core/discovery/`
- **content_discovery_service.dart**: Content aggregation and recommendations
- Trending detection, favorites management
- Smart caching and performance optimization

### Service Layer
- **app_service_manager.dart**: Central service coordination
- **enhanced_video_player_service.dart**: Advanced video playback
- **theme_manager.dart**: UI theming and customization
- **content_discovery_service.dart**: Content aggregation

### UI Layer
- **modern_home_screen.dart**: Main content browser
- **downloads_screen.dart**: Download management interface
- **plugin_management_screen.dart**: Provider configuration
- **search_screen.dart**: Advanced search with filters
- **settings_screen.dart**: App configuration

## 🛠️ Technology Stack

- **Framework**: Flutter 3.x
- **State Management**: Provider pattern
- **Storage**: SharedPreferences + local file system
- **Networking**: HTTP with custom extractors
- **Video**: Advanced video player with Chewie
- **Internationalization**: Built-in i18n support

## 📦 Installation

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code
- Android SDK / Xcode (for mobile deployment)

### Setup
```bash
# Clone the repository
git clone https://github.com/your-username/streamy.git
cd streamy/streamy_app

# Install dependencies
flutter pub get

# Run code generation (if needed)
flutter packages pub run build_runner build

# Run the app
flutter run
```

### Building for Release
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 🔧 Configuration

### Plugin Repositories
Add custom plugin repositories in the app settings:
```json
{
  "name": "Custom Repository",
  "url": "https://example.com/repository.json",
  "description": "Custom plugin repository"
}
```

### Environment Variables
Create a `.env` file in the project root:
```env
# API Keys (if needed)
TMDB_API_KEY=your_api_key_here
```

## 🧩 Plugin Development

### Creating a Custom Provider
```dart
class CustomProvider extends MainAPI {
  @override
  String get name => "Custom Provider";
  
  @override
  String get mainUrl => "https://custom-site.com";
  
  @override
  List<TvType> get supportedTypes => [TvType.Movie, TvType.TvSeries];
  
  @override
  Future<List<SearchResponse>?> search(String query) async {
    // Implementation here
  }
  
  @override
  Future<LoadResponse?> load(String url) async {
    // Implementation here
  }
  
  @override
  Future<List<ExtractorLink>?> loadLinks(
    String data, 
    bool isCasting, 
    String? subtitleCallback,
    Function(ExtractorSubtitleLink) callback,
  ) async {
    // Implementation here
  }
}
```

### Plugin Metadata Format
```json
{
  "name": "Custom Provider",
  "version": "1.0.0",
  "description": "Custom streaming provider",
  "author": "Developer Name",
  "iconUrl": "https://example.com/icon.png",
  "downloadUrl": "https://example.com/plugin.cs3",
  "supportedTypes": ["movie", "tv", "anime"],
  "language": "en",
  "status": "working",
  "lastUpdated": "2024-01-01T00:00:00Z"
}
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Workflow
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Run tests: `flutter test`
5. Commit changes: `git commit -m 'Add amazing feature'`
6. Push to branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

### Code Style
- Follow Dart/Flutter conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Write tests for new features

## 📋 Roadmap

### Version 2.0
- [ ] Chromecast integration
- [ ] Advanced subtitle editor
- [ ] Torrent streaming support
- [ ] User profiles and sync
- [ ] Advanced parental controls

### Version 2.1
- [ ] Live TV support
- [ ] Social features (reviews, ratings)
- [ ] Advanced filtering and sorting
- [ ] Batch download operations
- [ ] Custom theme support

### Version 2.2
- [ ] Smart TV interface
- [ ] Voice search integration
- [ ] Advanced analytics
- [ ] Cloud sync
- [ ] Plugin marketplace

## 🐛 Known Issues

- Some extractors may occasionally fail (working on improved error handling)
- Subtitle timing may need manual adjustment for some content
- Download resume may not work with all video hosts

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This application is for educational and personal use only. Users are responsible for ensuring they have the right to access and stream content through this application. The developers do not host, distribute, or encourage the piracy of copyrighted content.

## 🙏 Acknowledgments

- CloudStream project for inspiration and architecture guidance
- Flutter team for the amazing framework
- Open source video player libraries
- Community contributors and testers

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/your-username/streamy/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/streamy/discussions)
- **Email**: support@streamy-app.com

## 🌟 Star History

[![Star History Chart](https://api.star-history.com/svg?repos=your-username/streamy&type=Date)](https://star-history.com/#your-username/streamy&Date)

---

Built with ❤️ by the Streamy Team
