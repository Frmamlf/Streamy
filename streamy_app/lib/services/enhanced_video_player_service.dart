import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Enhanced video player service with advanced features
class EnhancedVideoPlayerService {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  
  // Player state
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isFullscreen = false;
  double _playbackSpeed = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  
  // Stream controllers for state updates
  final StreamController<bool> _playingController = StreamController<bool>.broadcast();
  final StreamController<Duration> _positionController = StreamController<Duration>.broadcast();
  final StreamController<double> _speedController = StreamController<double>.broadcast();
  
  // Getters for streams
  Stream<bool> get playingStream => _playingController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<double> get speedStream => _speedController.stream;
  
  // Getters for current state
  bool get isInitialized => _isInitialized;
  bool get isPlaying => _isPlaying;
  bool get isFullscreen => _isFullscreen;
  double get playbackSpeed => _playbackSpeed;
  Duration get position => _position;
  Duration get duration => _duration;
  ChewieController? get chewieController => _chewieController;
  
  /// Initialize video player with URL
  Future<void> initialize({
    required String videoUrl,
    bool autoPlay = false,
    bool looping = false,
    bool allowFullScreen = true,
    bool allowPlaybackSpeedChanging = true,
    bool showControls = true,
    Duration? startAt,
    List<String> subtitleUrls = const [],
  }) async {
    try {
      await dispose();
      
      // Enable wakelock during video playback
      await WakelockPlus.enable();
      
      // Initialize video controller based on URL type
      if (videoUrl.startsWith('http')) {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      } else {
        _videoController = VideoPlayerController.asset(videoUrl);
      }
      
      await _videoController!.initialize();
      
      // Set up video controller listener
      _videoController!.addListener(_videoListener);
      
      // Create Chewie controller with enhanced features
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: autoPlay,
        looping: looping,
        allowFullScreen: allowFullScreen,
        allowPlaybackSpeedChanging: allowPlaybackSpeedChanging,
        showControls: showControls,
        startAt: startAt,
        playbackSpeeds: [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0],
        additionalOptions: (context) => [
          // Removed custom options due to type conflicts
        ],
        customControls: const MaterialControls(),
        errorBuilder: (context, errorMessage) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error playing video',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
      
      _isInitialized = true;
      _duration = _videoController!.value.duration;
      
      // Start position updates
      _startPositionUpdates();
      
    } catch (e) {
      throw Exception('Failed to initialize video player: $e');
    }
  }
  
  /// Video controller listener
  void _videoListener() {
    if (_videoController == null) return;
    
    final value = _videoController!.value;
    
    // Update playing state
    if (_isPlaying != value.isPlaying) {
      _isPlaying = value.isPlaying;
      _playingController.add(_isPlaying);
      
      // Manage wakelock based on playback state
      if (_isPlaying) {
        WakelockPlus.enable();
      } else {
        WakelockPlus.disable();
      }
    }
    
    // Update position
    if (_position != value.position) {
      _position = value.position;
      _positionController.add(_position);
    }
    
    // Update duration
    if (_duration != value.duration) {
      _duration = value.duration;
    }
  }
  
  /// Start periodic position updates
  void _startPositionUpdates() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_videoController == null || !_isInitialized) {
        timer.cancel();
        return;
      }
      
      _position = _videoController!.value.position;
      _positionController.add(_position);
    });
  }
  
  /// Play video
  Future<void> play() async {
    if (_videoController != null && _isInitialized) {
      await _videoController!.play();
    }
  }
  
  /// Pause video
  Future<void> pause() async {
    if (_videoController != null && _isInitialized) {
      await _videoController!.pause();
    }
  }
  
  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }
  
  /// Seek to position
  Future<void> seekTo(Duration position) async {
    if (_videoController != null && _isInitialized) {
      await _videoController!.seekTo(position);
    }
  }
  
  /// Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    if (_videoController != null && _isInitialized) {
      await _videoController!.setPlaybackSpeed(speed);
      _playbackSpeed = speed;
      _speedController.add(_playbackSpeed);
    }
  }
  
  /// Set volume
  Future<void> setVolume(double volume) async {
    if (_videoController != null && _isInitialized) {
      await _videoController!.setVolume(volume);
    }
  }
  
  /// Enter fullscreen mode
  Future<void> enterFullscreen() async {
    if (_chewieController != null) {
      _chewieController!.enterFullScreen();
      _isFullscreen = true;
      
      // Lock orientation to landscape
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    }
  }
  
  /// Exit fullscreen mode
  Future<void> exitFullscreen() async {
    if (_chewieController != null) {
      _chewieController!.exitFullScreen();
      _isFullscreen = false;
      
      // Reset orientation
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }
  
  /// Toggle fullscreen
  Future<void> toggleFullscreen() async {
    if (_isFullscreen) {
      await exitFullscreen();
    } else {
      await enterFullscreen();
    }
  }
  
  /// Skip forward by duration
  Future<void> skipForward([Duration duration = const Duration(seconds: 10)]) async {
    if (_videoController != null && _isInitialized) {
      final newPosition = _position + duration;
      final maxPosition = _duration;
      
      if (newPosition <= maxPosition) {
        await seekTo(newPosition);
      } else {
        await seekTo(maxPosition);
      }
    }
  }
  
  /// Skip backward by duration
  Future<void> skipBackward([Duration duration = const Duration(seconds: 10)]) async {
    if (_videoController != null && _isInitialized) {
      final newPosition = _position - duration;
      
      if (newPosition >= Duration.zero) {
        await seekTo(newPosition);
      } else {
        await seekTo(Duration.zero);
      }
    }
  }
  
  /// Get video widget for display
  Widget getVideoWidget() {
    if (_chewieController != null && _isInitialized) {
      return Chewie(controller: _chewieController!);
    }
    
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
  
  /// Check if URL supports HLS/DASH
  bool supportsAdaptiveStreaming(String url) {
    return url.contains('.m3u8') || // HLS
           url.contains('.mpd') ||  // DASH
           url.contains('manifest'); // Generic manifest
  }
  
  /// Get supported video formats
  List<String> getSupportedFormats() {
    return [
      'mp4', 'mov', 'avi', 'mkv', 'webm',
      'm3u8', // HLS
      'mpd',  // DASH
    ];
  }
  
  /// Dispose resources
  Future<void> dispose() async {
    // Stop position updates and close streams
    _playingController.close();
    _positionController.close();
    _speedController.close();
    
    // Dispose controllers
    _chewieController?.dispose();
    await _videoController?.dispose();
    
    // Disable wakelock
    await WakelockPlus.disable();
    
    // Reset state
    _videoController = null;
    _chewieController = null;
    _isInitialized = false;
    _isPlaying = false;
    _isFullscreen = false;
    _playbackSpeed = 1.0;
    _position = Duration.zero;
    _duration = Duration.zero;
    
    // Reset orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}
