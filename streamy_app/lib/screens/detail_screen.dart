import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../models/web_source.dart';
import '../services/api_service.dart';
import '../services/app_service_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class DetailScreen extends StatefulWidget {
  final MediaItem mediaItem;

  const DetailScreen({super.key, required this.mediaItem});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isLoading = false;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  MediaItem? _detailedItem;
  List<VideoSource> _availableVideoSources = [];
  final ApiService _apiService = ApiService();
  final AppServiceManager _serviceManager = AppServiceManager();

  @override
  void initState() {
    super.initState();
    _loadDetailedItem();
  }

  Future<void> _loadDetailedItem() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final item = await _apiService.getMediaById(widget.mediaItem.id);
      setState(() {
        _detailedItem = item;
        _isLoading = false;
      });

      // Try to load video sources
      await _loadVideoSources();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading content: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _loadVideoSources() async {
    final List<VideoSource> sources = [];

    // Add sources from API if available
    if (_detailedItem?.sources?.isNotEmpty == true) {
      for (String source in _detailedItem!.sources!) {
        sources.add(VideoSource(
          url: source,
          quality: 'Auto',
          format: 'MP4',
        ));
      }
    }

    // Try to extract from web sources if this is a web-scraped item
    if (widget.mediaItem.metadata?['source'] != null) {
      try {
        final originalUrl = widget.mediaItem.metadata?['originalUrl'];
        
        if (originalUrl != null) {
          final extractor = await _serviceManager.webScrapingService.extractVideoSources(originalUrl);
          
          final videoUrls = extractor['videoSources'] ?? <String>[];
          for (final url in videoUrls) {
            sources.add(VideoSource(
              url: url,
              quality: 'Unknown',
              format: _getFormatFromUrl(url),
            ));
          }
        }
      } catch (e) {
        print('Error extracting web video sources: $e');
      }
    }

    setState(() {
      _availableVideoSources = sources;
    });

    // Initialize player with the first available source
    if (sources.isNotEmpty) {
      _initializePlayer(sources.first.url);
    }
  }

  Future<void> _initializePlayer(String videoUrl) async {
    // Store the primary color before async operations
    final primaryColor = Theme.of(context).primaryColor;
    
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    await _videoPlayerController!.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: false,
      looping: false,
      aspectRatio: 16 / 9,
      placeholder: Container(
        color: Colors.black,
      ),
      materialProgressColors: ChewieProgressColors(
        playedColor: primaryColor,
        handleColor: primaryColor,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.white30,
      ),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    // Service manager handles disposal internally
    super.dispose();
  }

  Widget _buildVideoPlayer() {
    if (_chewieController != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Chewie(controller: _chewieController!),
      );
    } else {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          child: Center(
            child: _detailedItem?.sources?.isEmpty != false
                ? const Text('No video available', style: TextStyle(color: Colors.white))
                : const CircularProgressIndicator(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _detailedItem ?? widget.mediaItem;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to favorites')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video player or thumbnail
                  _buildVideoPlayer(),

                  // Video source selector
                  if (_availableVideoSources.length > 1) _buildSourceSelector(),

                  // Content info
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            if (item.rating != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.rating!.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getContentTypeColor(item.contentType),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getContentTypeText(item.contentType),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Description
                        if (item.description != null && item.description!.isNotEmpty)
                          Text(
                            item.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),

                        const SizedBox(height: 24),

                        // Play button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: item.sources?.isNotEmpty == true
                                ? () {
                                    _videoPlayerController?.play();
                                  }
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.play_arrow),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.sources?.isNotEmpty == true ? 'Play' : 'No Sources Available',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSourceSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Video Sources',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _availableVideoSources.asMap().entries.map((entry) {
                final source = entry.value;
                final isSelected = _videoPlayerController?.dataSource == source.url;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _initializePlayer(source.url);
                      }
                    },
                    label: Text('${source.quality} (${source.format})'),
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getContentTypeText(ContentType type) {
    switch (type) {
      case ContentType.movie:
        return 'MOVIE';
      case ContentType.tvShow:
        return 'TV SHOW';
      case ContentType.anime:
        return 'ANIME';
    }
  }

  Color _getContentTypeColor(ContentType type) {
    switch (type) {
      case ContentType.movie:
        return Colors.blue;
      case ContentType.tvShow:
        return Colors.purple;
      case ContentType.anime:
        return Colors.orange;
    }
  }

  String _getFormatFromUrl(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('.m3u8')) return 'HLS';
    if (lowerUrl.contains('.mp4')) return 'MP4';
    if (lowerUrl.contains('.mkv')) return 'MKV';
    if (lowerUrl.contains('.avi')) return 'AVI';
    if (lowerUrl.contains('.webm')) return 'WEBM';
    return 'Unknown';
  }
}
