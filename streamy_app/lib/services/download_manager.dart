import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive/hive.dart';
import '../models/media_item.dart';

/// Download Manager for offline video support
class DownloadManager {
  static final DownloadManager _instance = DownloadManager._internal();
  factory DownloadManager() => _instance;
  DownloadManager._internal();
  
  static const String _downloadsBoxName = 'downloads';
  static const String _downloadTasksBoxName = 'download_tasks';
  
  late Box<DownloadItem> _downloadsBox;
  late Box<String> _downloadTasksBox;
  late String _downloadDirectory;
  
  final Dio _dio = Dio();
  
  /// Initialize the download manager
  Future<void> initialize() async {
    // Initialize Hive boxes
    _downloadsBox = await Hive.openBox<DownloadItem>(_downloadsBoxName);
    _downloadTasksBox = await Hive.openBox<String>(_downloadTasksBoxName);
    
    // Setup download directory
    await _setupDownloadDirectory();
    
    // Setup dio interceptors
    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
    ));
    
    // Initialize flutter_downloader
    await FlutterDownloader.initialize(debug: kDebugMode);
    
    // Register download callback
    FlutterDownloader.registerCallback(downloadCallback);
  }
  
  /// Setup download directory
  Future<void> _setupDownloadDirectory() async {
    Directory? directory;
    
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
      _downloadDirectory = '${directory!.path}/Streamy/Downloads';
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
      _downloadDirectory = '${directory.path}/Downloads';
    } else {
      directory = await getDownloadsDirectory();
      _downloadDirectory = '${directory!.path}/Streamy';
    }
    
    final downloadDir = Directory(_downloadDirectory);
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
  }
  
  /// Request storage permissions
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true; // iOS doesn't need explicit storage permission for app directory
  }
  
  /// Start downloading a video
  Future<String?> downloadVideo({
    required MediaItem mediaItem,
    required String videoUrl,
    required String quality,
    Map<String, String>? headers,
    Function(int, int)? onProgress,
  }) async {
    // Check permissions
    if (!await requestPermissions()) {
      throw Exception('Storage permission denied');
    }
    
    // Generate unique filename
    final filename = _generateFilename(mediaItem.title, quality);
    final filePath = '$_downloadDirectory/$filename';
    
    try {
      // Create download item
      final downloadItem = DownloadItem(
        id: mediaItem.id,
        title: mediaItem.title,
        thumbnailUrl: mediaItem.thumbnailUrl ?? '',
        quality: quality,
        filePath: filePath,
        videoUrl: videoUrl,
        status: DownloadStatus.pending,
        downloadedBytes: 0,
        totalBytes: 0,
        startTime: DateTime.now(),
      );
      
      // Save to local storage
      await _downloadsBox.put(mediaItem.id, downloadItem);
      
      // Start download using flutter_downloader for better background support
      final taskId = await FlutterDownloader.enqueue(
        url: videoUrl,
        savedDir: _downloadDirectory,
        fileName: filename,
        headers: headers ?? {},
        showNotification: true,
        openFileFromNotification: false,
      );
      
      if (taskId != null) {
        // Map task ID to media item ID
        await _downloadTasksBox.put(taskId, mediaItem.id);
        
        // Update download item with task ID
        downloadItem.taskId = taskId;
        downloadItem.status = DownloadStatus.downloading;
        await _downloadsBox.put(mediaItem.id, downloadItem);
        
        return taskId;
      }
      
      return null;
    } catch (e) {
      // Update status to failed
      final downloadItem = _downloadsBox.get(mediaItem.id);
      if (downloadItem != null) {
        downloadItem.status = DownloadStatus.failed;
        downloadItem.error = e.toString();
        await _downloadsBox.put(mediaItem.id, downloadItem);
      }
      rethrow;
    }
  }
  
  /// Pause download
  Future<void> pauseDownload(String mediaItemId) async {
    final downloadItem = _downloadsBox.get(mediaItemId);
    if (downloadItem?.taskId != null) {
      await FlutterDownloader.pause(taskId: downloadItem!.taskId!);
      downloadItem.status = DownloadStatus.paused;
      await _downloadsBox.put(mediaItemId, downloadItem);
    }
  }
  
  /// Resume download
  Future<void> resumeDownload(String mediaItemId) async {
    final downloadItem = _downloadsBox.get(mediaItemId);
    if (downloadItem?.taskId != null) {
      final newTaskId = await FlutterDownloader.resume(taskId: downloadItem!.taskId!);
      if (newTaskId != null) {
        downloadItem.taskId = newTaskId;
        downloadItem.status = DownloadStatus.downloading;
        await _downloadsBox.put(mediaItemId, downloadItem);
        await _downloadTasksBox.put(newTaskId, mediaItemId);
      }
    }
  }
  
  /// Cancel download
  Future<void> cancelDownload(String mediaItemId) async {
    final downloadItem = _downloadsBox.get(mediaItemId);
    if (downloadItem?.taskId != null) {
      await FlutterDownloader.cancel(taskId: downloadItem!.taskId!);
      await _downloadTasksBox.delete(downloadItem.taskId!);
    }
    
    // Remove file if exists
    if (downloadItem?.filePath != null) {
      final file = File(downloadItem!.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    
    await _downloadsBox.delete(mediaItemId);
  }
  
  /// Delete downloaded video
  Future<void> deleteDownload(String mediaItemId) async {
    final downloadItem = _downloadsBox.get(mediaItemId);
    if (downloadItem != null) {
      // Delete file
      final file = File(downloadItem.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      
      // Remove from storage
      await _downloadsBox.delete(mediaItemId);
      
      if (downloadItem.taskId != null) {
        await _downloadTasksBox.delete(downloadItem.taskId!);
      }
    }
  }
  
  /// Get all downloads
  List<DownloadItem> getAllDownloads() {
    return _downloadsBox.values.toList();
  }
  
  /// Get downloads by status
  List<DownloadItem> getDownloadsByStatus(DownloadStatus status) {
    return _downloadsBox.values.where((item) => item.status == status).toList();
  }
  
  /// Get download by media item ID
  DownloadItem? getDownload(String mediaItemId) {
    return _downloadsBox.get(mediaItemId);
  }
  
  /// Check if video is downloaded
  bool isDownloaded(String mediaItemId) {
    final downloadItem = _downloadsBox.get(mediaItemId);
    return downloadItem?.status == DownloadStatus.completed;
  }
  
  /// Get total download size
  Future<int> getTotalDownloadSize() async {
    int totalSize = 0;
    for (final downloadItem in _downloadsBox.values) {
      if (downloadItem.status == DownloadStatus.completed) {
        final file = File(downloadItem.filePath);
        if (await file.exists()) {
          final size = await file.length();
          totalSize += size;
        }
      }
    }
    return totalSize;
  }
  
  /// Clean up incomplete downloads
  Future<void> cleanupIncompleteDownloads() async {
    final incompleteDownloads = _downloadsBox.values.where(
      (item) => item.status != DownloadStatus.completed,
    ).toList();
    
    for (final downloadItem in incompleteDownloads) {
      await cancelDownload(downloadItem.id);
    }
  }
  
  /// Generate unique filename
  String _generateFilename(String title, String quality) {
    final cleanTitle = title.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${cleanTitle}_${quality}_$timestamp.mp4';
  }
  
  /// Download callback for flutter_downloader
  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }
  
  /// Update download progress
  Future<void> updateDownloadProgress(String taskId, int status, int progress) async {
    final mediaItemId = _downloadTasksBox.get(taskId);
    if (mediaItemId != null) {
      final downloadItem = _downloadsBox.get(mediaItemId);
      if (downloadItem != null) {
        downloadItem.progress = progress;
        
        // Update status based on flutter_downloader status
        switch (status) {
          case 2: // DownloadTaskStatus.complete
            downloadItem.status = DownloadStatus.completed;
            downloadItem.completedTime = DateTime.now();
            break;
          case 3: // DownloadTaskStatus.failed
            downloadItem.status = DownloadStatus.failed;
            break;
          case 4: // DownloadTaskStatus.paused
            downloadItem.status = DownloadStatus.paused;
            break;
          case 1: // DownloadTaskStatus.running
            downloadItem.status = DownloadStatus.downloading;
            break;
        }
        
        await _downloadsBox.put(mediaItemId, downloadItem);
      }
    }
  }
}

/// Download item model
@HiveType(typeId: 0)
class DownloadItem extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String thumbnailUrl;
  
  @HiveField(3)
  String quality;
  
  @HiveField(4)
  String filePath;
  
  @HiveField(5)
  String videoUrl;
  
  @HiveField(6)
  DownloadStatus status;
  
  @HiveField(7)
  int downloadedBytes;
  
  @HiveField(8)
  int totalBytes;
  
  @HiveField(9)
  DateTime startTime;
  
  @HiveField(10)
  DateTime? completedTime;
  
  @HiveField(11)
  String? error;
  
  @HiveField(12)
  String? taskId;
  
  @HiveField(13)
  int progress;
  
  DownloadItem({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.quality,
    required this.filePath,
    required this.videoUrl,
    required this.status,
    required this.downloadedBytes,
    required this.totalBytes,
    required this.startTime,
    this.completedTime,
    this.error,
    this.taskId,
    this.progress = 0,
  });
  
  double get progressPercentage => progress / 100.0;
  
  Duration get downloadDuration {
    if (completedTime != null) {
      return completedTime!.difference(startTime);
    }
    return DateTime.now().difference(startTime);
  }
}

/// Download status enum
@HiveType(typeId: 1)
enum DownloadStatus {
  @HiveField(0)
  pending,
  
  @HiveField(1)
  downloading,
  
  @HiveField(2)
  paused,
  
  @HiveField(3)
  completed,
  
  @HiveField(4)
  failed,
  
  @HiveField(5)
  cancelled,
}
