import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import '../models/media_item.dart';

/// Analytics and Performance Monitoring Service
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();
  
  static const String _analyticsBoxName = 'analytics_data';
  static const String _performanceBoxName = 'performance_data';
  
  late Box<AnalyticsEvent> _analyticsBox;
  late Box<PerformanceMetric> _performanceBox;
  
  FirebaseAnalytics? _analytics;
  FirebaseCrashlytics? _crashlytics;
  FirebasePerformance? _performance;
  
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  // Session tracking
  DateTime? _sessionStartTime;
  Duration _totalWatchTime = Duration.zero;
  int _videosWatched = 0;
  int _searchCount = 0;
  
  // Performance metrics
  final Map<String, Trace> _activeTraces = {};
  final List<double> _loadTimes = [];
  final List<NetworkMetric> _networkMetrics = [];
  
  // Data usage tracking
  int _dataUsedBytes = 0;
  
  /// Initialize analytics service
  Future<void> initialize() async {
    try {
      // Initialize Hive boxes
      _analyticsBox = await Hive.openBox<AnalyticsEvent>(_analyticsBoxName);
      _performanceBox = await Hive.openBox<PerformanceMetric>(_performanceBoxName);
      
      // Initialize Firebase services
      if (!kDebugMode) {
        _analytics = FirebaseAnalytics.instance;
        _crashlytics = FirebaseCrashlytics.instance;
        _performance = FirebasePerformance.instance;
        
        // Set up crash reporting
        FlutterError.onError = _crashlytics!.recordFlutterFatalError;
        PlatformDispatcher.instance.onError = (error, stack) {
          _crashlytics!.recordError(error, stack, fatal: true);
          return true;
        };
      }
      
      // Start session
      _startSession();
      
      // Monitor connectivity
      _startConnectivityMonitoring();
      
    } catch (e) {
      if (kDebugMode) {
        print('Analytics initialization error: $e');
      }
    }
  }
  
  /// Start user session
  void _startSession() {
    _sessionStartTime = DateTime.now();
    _logEvent('session_start');
  }
  
  /// End user session
  void endSession() {
    if (_sessionStartTime != null) {
      final sessionDuration = DateTime.now().difference(_sessionStartTime!);
      _logEvent('session_end', parameters: {
        'session_duration': sessionDuration.inSeconds,
        'videos_watched': _videosWatched,
        'search_count': _searchCount,
        'total_watch_time': _totalWatchTime.inSeconds,
      });
    }
  }
  
  /// Log custom event
  void _logEvent(String name, {Map<String, dynamic>? parameters}) {
    try {
      // Log to Firebase Analytics
      _analytics?.logEvent(
        name: name,
        parameters: parameters,
      );
      
      // Store locally for offline analysis
      final event = AnalyticsEvent(
        name: name,
        parameters: parameters ?? {},
        timestamp: DateTime.now(),
      );
      
      _analyticsBox.add(event);
      
    } catch (e) {
      if (kDebugMode) {
        print('Event logging error: $e');
      }
    }
  }
  
  /// Track video playback start
  void trackVideoStart({
    required MediaItem mediaItem,
    required String quality,
    required String source,
  }) {
    _logEvent('video_start', parameters: {
      'content_id': mediaItem.id,
      'content_title': mediaItem.title,
      'content_type': mediaItem.contentType.toString(),
      'video_quality': quality,
      'video_source': source,
      'content_rating': mediaItem.rating,
    });
    
    _videosWatched++;
  }
  
  /// Track video playback completion
  void trackVideoComplete({
    required MediaItem mediaItem,
    required Duration watchedDuration,
    required Duration totalDuration,
  }) {
    final completionRate = watchedDuration.inSeconds / totalDuration.inSeconds;
    
    _logEvent('video_complete', parameters: {
      'content_id': mediaItem.id,
      'content_title': mediaItem.title,
      'watched_duration': watchedDuration.inSeconds,
      'total_duration': totalDuration.inSeconds,
      'completion_rate': completionRate,
    });
    
    _totalWatchTime += watchedDuration;
  }
  
  /// Track search queries
  void trackSearch({
    required String query,
    required int resultCount,
    required Duration searchDuration,
  }) {
    _logEvent('search', parameters: {
      'search_query': query,
      'result_count': resultCount,
      'search_duration_ms': searchDuration.inMilliseconds,
    });
    
    _searchCount++;
  }
  
  /// Track download events
  void trackDownload({
    required MediaItem mediaItem,
    required String quality,
    required String event, // 'start', 'complete', 'cancel', 'fail'
  }) {
    _logEvent('download_$event', parameters: {
      'content_id': mediaItem.id,
      'content_title': mediaItem.title,
      'download_quality': quality,
    });
  }
  
  /// Track app crashes
  void trackCrash(dynamic error, StackTrace stackTrace) {
    _crashlytics?.recordError(error, stackTrace);
  }
  
  /// Track user preferences
  void trackUserPreference({
    required String preference,
    required dynamic value,
  }) {
    _logEvent('user_preference', parameters: {
      'preference_name': preference,
      'preference_value': value.toString(),
    });
  }
  
  /// Start performance trace
  void startTrace(String traceName) {
    try {
      final trace = _performance?.newTrace(traceName);
      trace?.start();
      _activeTraces[traceName] = trace!;
    } catch (e) {
      if (kDebugMode) {
        print('Start trace error: $e');
      }
    }
  }
  
  /// Stop performance trace
  void stopTrace(String traceName) {
    try {
      final trace = _activeTraces.remove(traceName);
      trace?.stop();
    } catch (e) {
      if (kDebugMode) {
        print('Stop trace error: $e');
      }
    }
  }
  
  /// Track page load time
  void trackPageLoad({
    required String pageName,
    required Duration loadTime,
  }) {
    _loadTimes.add(loadTime.inMilliseconds.toDouble());
    
    _logEvent('page_load', parameters: {
      'page_name': pageName,
      'load_time_ms': loadTime.inMilliseconds,
    });
    
    // Store performance metric
    final metric = PerformanceMetric(
      name: 'page_load_$pageName',
      value: loadTime.inMilliseconds.toDouble(),
      timestamp: DateTime.now(),
      metadata: {'page': pageName},
    );
    
    _performanceBox.add(metric);
  }
  
  /// Track network performance
  void trackNetworkRequest({
    required String url,
    required Duration duration,
    required int statusCode,
    required int responseSize,
  }) {
    final metric = NetworkMetric(
      url: url,
      duration: duration,
      statusCode: statusCode,
      responseSize: responseSize,
      timestamp: DateTime.now(),
    );
    
    _networkMetrics.add(metric);
    
    _logEvent('network_request', parameters: {
      'url': url,
      'duration_ms': duration.inMilliseconds,
      'status_code': statusCode,
      'response_size': responseSize,
    });
  }
  
  /// Track data usage
  void trackDataUsage(int bytes) {
    _dataUsedBytes += bytes;
    
    // Log data usage every 10MB
    if (_dataUsedBytes % (10 * 1024 * 1024) == 0) {
      _logEvent('data_usage', parameters: {
        'total_bytes': _dataUsedBytes,
        'session_bytes': bytes,
      });
    }
  }
  
  /// Get analytics summary
  AnalyticsSummary getAnalyticsSummary() {
    final now = DateTime.now();
    final last24Hours = now.subtract(Duration(hours: 24));
    
    // Filter events from last 24 hours
    final recentEvents = _analyticsBox.values
        .where((event) => event.timestamp.isAfter(last24Hours))
        .toList();
    
    // Calculate metrics
    final videoStartEvents = recentEvents
        .where((e) => e.name == 'video_start')
        .length;
    
    final searchEvents = recentEvents
        .where((e) => e.name == 'search')
        .length;
    
    final averageLoadTime = _loadTimes.isNotEmpty
        ? _loadTimes.reduce((a, b) => a + b) / _loadTimes.length
        : 0.0;
    
    final totalDataUsage = _dataUsedBytes;
    
    return AnalyticsSummary(
      videosWatched: videoStartEvents,
      searchCount: searchEvents,
      totalWatchTime: _totalWatchTime,
      averageLoadTime: Duration(milliseconds: averageLoadTime.round()),
      dataUsageBytes: totalDataUsage,
      networkRequests: _networkMetrics.length,
      lastUpdated: now,
    );
  }
  
  /// Export analytics data
  Future<Map<String, dynamic>> exportAnalyticsData() async {
    final events = _analyticsBox.values.toList();
    final performance = _performanceBox.values.toList();
    
    return {
      'events': events.map((e) => e.toJson()).toList(),
      'performance': performance.map((p) => p.toJson()).toList(),
      'network_metrics': _networkMetrics.map((n) => n.toJson()).toList(),
      'summary': getAnalyticsSummary().toJson(),
      'export_timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  /// Clear analytics data
  Future<void> clearAnalyticsData() async {
    await _analyticsBox.clear();
    await _performanceBox.clear();
    _networkMetrics.clear();
    _loadTimes.clear();
    _dataUsedBytes = 0;
  }
  
  /// Start connectivity monitoring
  void _startConnectivityMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        _logEvent('connectivity_changed', parameters: {
          'connection_type': result.toString(),
        });
      },
    );
  }
  
  /// Set user properties
  void setUserProperties({
    required String userId,
    String? userType,
    String? subscriptionLevel,
  }) {
    _analytics?.setUserId(id: userId);
    
    if (userType != null) {
      _analytics?.setUserProperty(name: 'user_type', value: userType);
    }
    
    if (subscriptionLevel != null) {
      _analytics?.setUserProperty(name: 'subscription_level', value: subscriptionLevel);
    }
  }
  
  /// Dispose resources
  void dispose() {
    endSession();
    _connectivitySubscription?.cancel();
  }
}

/// Analytics event model
@HiveType(typeId: 4)
class AnalyticsEvent extends HiveObject {
  @HiveField(0)
  String name;
  
  @HiveField(1)
  Map<String, dynamic> parameters;
  
  @HiveField(2)
  DateTime timestamp;
  
  AnalyticsEvent({
    required this.name,
    required this.parameters,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'parameters': parameters,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Performance metric model
@HiveType(typeId: 5)
class PerformanceMetric extends HiveObject {
  @HiveField(0)
  String name;
  
  @HiveField(1)
  double value;
  
  @HiveField(2)
  DateTime timestamp;
  
  @HiveField(3)
  Map<String, dynamic> metadata;
  
  PerformanceMetric({
    required this.name,
    required this.value,
    required this.timestamp,
    this.metadata = const {},
  });
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };
}

/// Network metric model
class NetworkMetric {
  final String url;
  final Duration duration;
  final int statusCode;
  final int responseSize;
  final DateTime timestamp;
  
  NetworkMetric({
    required this.url,
    required this.duration,
    required this.statusCode,
    required this.responseSize,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() => {
    'url': url,
    'duration_ms': duration.inMilliseconds,
    'status_code': statusCode,
    'response_size': responseSize,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Analytics summary model
class AnalyticsSummary {
  final int videosWatched;
  final int searchCount;
  final Duration totalWatchTime;
  final Duration averageLoadTime;
  final int dataUsageBytes;
  final int networkRequests;
  final DateTime lastUpdated;
  
  AnalyticsSummary({
    required this.videosWatched,
    required this.searchCount,
    required this.totalWatchTime,
    required this.averageLoadTime,
    required this.dataUsageBytes,
    required this.networkRequests,
    required this.lastUpdated,
  });
  
  Map<String, dynamic> toJson() => {
    'videos_watched': videosWatched,
    'search_count': searchCount,
    'total_watch_time_seconds': totalWatchTime.inSeconds,
    'average_load_time_ms': averageLoadTime.inMilliseconds,
    'data_usage_bytes': dataUsageBytes,
    'network_requests': networkRequests,
    'last_updated': lastUpdated.toIso8601String(),
  };
  
  String get dataUsageFormatted {
    if (dataUsageBytes < 1024) return '${dataUsageBytes}B';
    if (dataUsageBytes < 1024 * 1024) return '${(dataUsageBytes / 1024).toStringAsFixed(1)}KB';
    if (dataUsageBytes < 1024 * 1024 * 1024) return '${(dataUsageBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(dataUsageBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}
