import 'dart:core';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import '../models/web_source.dart';
import '../models/media_item.dart';
import 'ad_blocking_engine.dart';

/// Enhanced Web Scraping Service with Advanced Ad Blocking
/// Inspired by uBlock Origin's filtering techniques
class WebScrapingService {
  static const List<String> commonAdPatterns = [
    // Major ad networks
    'googletagmanager.com',
    'doubleclick.net', 
    'googlesyndication.com',
    'amazon-adsystem.com',
    'facebook.com/tr',
    'google-analytics.com',
    'scorecardresearch.com',
    'outbrain.com',
    'taboola.com',
    
    // Generic patterns
    'ads',
    'advertisement', 
    'popup',
    'banner',
    'sponsor',
    'tracking',
    'analytics',
    'telemetry',
  ];

  static final List<WebSource> predefinedSources = [
    WebSource(
      id: 'asd_homes',
      name: 'ASD Homes',
      baseUrl: 'https://a.asd.homes',
      adBlockPatterns: [
        ...commonAdPatterns,
        // Site-specific patterns
        'asd.homes/ads',
        'asd.homes/popup',
        'cdn.asd.homes/ads',
        'static.asd.homes/ads',
        
        // Known ad networks for streaming sites
        'propellerads.com',
        'adnxs.com',
        'adsystem.com',
        'interstitial',
        'overlay',
        'modal',
        'sponsored',
        'promo',
        'vast',
        'vmap',
        'ima',
        'preroll',
        'midroll',
        'postroll',
        'hotjar.com',
        'mixpanel.com',
        'segment.io',
        'amplitude.com',
        'fullstory.com',
        'twitter.com/i/adsct',
        'linkedin.com/px',
        'snapchat.com/p',
        'tiktok.com/i18n/pixel',
      ],
      videoSelectors: {
        'video': 'video, video source',
        'iframe': 'iframe[src*="player"], iframe[src*="embed"], iframe[src*="stream"]',
        'source': 'source[src]',
        'embed': '[data-src*=".mp4"], [data-src*=".m3u8"], [data-video], [data-stream]',
        'jwplayer': '.jwplayer, #jwplayer, [id*="jwplayer"]',
        'videojs': '.video-js, .vjs-tech',
        'flowplayer': '.flowplayer, .fp-player',
      },
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept-Encoding': 'gzip, deflate, br',
        'DNT': '1',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
        'Sec-Fetch-Dest': 'document',
        'Sec-Fetch-Mode': 'navigate',
        'Sec-Fetch-Site': 'none',
        'Sec-Fetch-User': '?1',
        'Cache-Control': 'max-age=0',
        'Referer': 'https://a.asd.homes',
      },
    ),
    WebSource(
      id: 'flixhq',
      name: 'FlixHQ',
      baseUrl: 'https://flixhq.to',
      adBlockPatterns: [
        ...commonAdPatterns,
        'flixhq.to/ads',
        'flixhq.to/popup',
        'cdn.flixhq.to/ads',
        'static.flixhq.to/ads',
      ],
      videoSelectors: {
        'video': 'video, video source',
        'iframe': 'iframe[src*="player"], iframe[src*="embed"]',
        'source': 'source[src]',
        'embed': '[data-src*=".mp4"], [data-src*=".m3u8"]',
      },
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
        'Referer': 'https://flixhq.to',
      },
    ),
  ];

  final http.Client _client;
  final List<WebSource> _customSources = [];
  final AdBlockingEngine _adBlocker;

  WebScrapingService({AdBlockingConfig? adBlockingConfig}) 
    : _client = http.Client(),
      _adBlocker = AdBlockingEngine(
        networkFilteringEnabled: adBlockingConfig?.networkFilteringEnabled ?? true,
        cosmeticFilteringEnabled: adBlockingConfig?.cosmeticFilteringEnabled ?? true,
        scriptBlockingEnabled: adBlockingConfig?.scriptBlockingEnabled ?? true,
        cookieNoticesBlocked: adBlockingConfig?.cookieNoticesBlocked ?? true,
        socialWidgetsBlocked: adBlockingConfig?.socialWidgetsBlocked ?? true,
        trackingBlocked: adBlockingConfig?.trackingBlocked ?? true,
        customPatterns: adBlockingConfig?.customPatterns ?? [],
        allowedDomains: adBlockingConfig?.allowedDomains ?? [],
      );

  List<WebSource> get allSources => [...predefinedSources, ..._customSources];

  void addCustomSource(WebSource source) {
    _customSources.add(source);
  }

  void removeCustomSource(String id) {
    _customSources.removeWhere((source) => source.id == id);
  }

  /// Search for movies across all enabled sources
  Future<List<MediaItem>> searchMovies(String query) async {
    List<MediaItem> allResults = [];

    for (WebSource source in allSources.where((s) => s.isEnabled)) {
      try {
        final results = await _searchInSource(source, query);
        allResults.addAll(results);
      } catch (e) {
        developer.log('Error searching in ${source.name}: $e', name: 'WebScrapingService');
      }
    }

    return allResults;
  }

  /// Search in a specific source
  Future<List<MediaItem>> _searchInSource(WebSource source, String query) async {
    final searchUrl = '${source.baseUrl}/search?q=${Uri.encodeComponent(query)}';
    
    final response = await _client.get(
      Uri.parse(searchUrl),
      headers: source.headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load search results from ${source.name}');
    }

    final cleanedHtml = _adBlocker.processHtml(response.body, Uri.parse(searchUrl));
    return _parseSearchResults(source, cleanedHtml);
  }

  /// Parse search results from HTML
  List<MediaItem> _parseSearchResults(WebSource source, String html) {
    final document = html_parser.parse(html);
    final List<MediaItem> items = [];

    // Generic selectors for common movie listing patterns
    final selectors = [
      '.movie-item, .film-item, .video-item',
      '.search-result, .result-item',
      '[class*="movie"], [class*="film"], [class*="video"]',
      'article, .item, .card',
    ];

    for (final selector in selectors) {
      final elements = document.querySelectorAll(selector);
      
      for (final element in elements) {
        try {
          final mediaItem = _parseMediaItem(element, source);
          if (mediaItem != null) {
            items.add(mediaItem);
          }
        } catch (e) {
          developer.log('Error parsing media item: $e', name: 'WebScrapingService');
        }
      }
      
      if (items.isNotEmpty) break; // Found results with this selector
    }

    return items;
  }

  /// Parse individual media item from element
  MediaItem? _parseMediaItem(Element element, WebSource source) {
    try {
      // Extract title
      final titleElement = element.querySelector('h1, h2, h3, h4, .title, [class*="title"], .name, [class*="name"]');
      final title = titleElement?.text.trim();
      
      if (title == null || title.isEmpty) return null;

      // Extract image
      final imgElement = element.querySelector('img');
      final imageUrl = imgElement?.attributes['src'] ?? imgElement?.attributes['data-src'] ?? '';

      // Extract description
      final descElement = element.querySelector('.description, .synopsis, .summary, p');
      final description = descElement?.text.trim() ?? '';

      // Extract year
      final yearElement = element.querySelector('.year, [class*="year"], .date, [class*="date"]');
      final yearText = yearElement?.text.trim() ?? '';
      final yearMatch = RegExp(r'(\d{4})').firstMatch(yearText);
      final year = yearMatch?.group(1) ?? '';

      // Extract rating
      final ratingElement = element.querySelector('.rating, [class*="rating"], .score, [class*="score"]');
      final ratingText = ratingElement?.text.trim() ?? '';
      final ratingMatch = RegExp(r'(\d+\.?\d*)').firstMatch(ratingText);
      final rating = double.tryParse(ratingMatch?.group(1) ?? '0') ?? 0.0;

      // Extract URL
      final linkElement = element.querySelector('a');
      final relativeUrl = linkElement?.attributes['href'] ?? '';
      final url = relativeUrl.startsWith('http') ? relativeUrl : '${source.baseUrl}$relativeUrl';

      return MediaItem(
        id: url.hashCode.toString(),
        title: title,
        thumbnailUrl: imageUrl.startsWith('http') ? imageUrl : '${source.baseUrl}$imageUrl',
        contentType: ContentType.movie,
        rating: rating,
        description: description,
        sources: [url],
        metadata: {
          'year': year,
          'source': source.name,
          'url': url,
        },
      );
    } catch (e) {
      developer.log('Error parsing media item: $e', name: 'WebScrapingService');
      return null;
    }
  }

  /// Extract video sources from a media page
  Future<List<VideoSource>> extractVideoSources(String url) async {
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
          'Referer': url,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load video page');
      }

      final cleanedHtml = _adBlocker.processHtml(response.body, Uri.parse(url));
      return _extractVideoFromHtml(cleanedHtml, url);
    } catch (e) {
      developer.log('Error extracting video sources: $e', name: 'WebScrapingService');
      return [];
    }
  }

  /// Extract video sources from HTML content
  List<VideoSource> _extractVideoFromHtml(String html, String pageUrl) {
    final document = html_parser.parse(html);
    final List<VideoSource> sources = [];

    // Extract from video elements
    final videoElements = document.querySelectorAll('video, source');
    for (final element in videoElements) {
      final src = element.attributes['src'];
      if (src != null && _isValidVideoUrl(src)) {
        sources.add(VideoSource(
          url: _resolveUrl(src, pageUrl),
          quality: _extractQuality(element, src),
          type: _getVideoType(src),
        ));
      }
    }

    // Extract from iframes
    final iframeElements = document.querySelectorAll('iframe');
    for (final element in iframeElements) {
      final src = element.attributes['src'];
      if (src != null && _isVideoIframe(src)) {
        sources.add(VideoSource(
          url: _resolveUrl(src, pageUrl),
          quality: 'Unknown',
          type: 'iframe',
        ));
      }
    }

    // Extract from JavaScript
    final scriptElements = document.querySelectorAll('script');
    for (final element in scriptElements) {
      final scriptContent = element.text;
      sources.addAll(_extractVideoUrlsFromScript(scriptContent, pageUrl));
    }

    return sources;
  }

  /// Extract video URLs from JavaScript content
  List<VideoSource> _extractVideoUrlsFromScript(String script, String pageUrl) {
    final List<VideoSource> sources = [];
    
    // Enhanced patterns for video URLs
    final patterns = <RegExp>[
      // Direct video file patterns
      RegExp(r'"(https?://[^"]*\.m3u8[^"]*)"', caseSensitive: false),
      RegExp(r'"(https?://[^"]*\.mp4[^"]*)"', caseSensitive: false),
      RegExp(r'"(https?://[^"]*\.mkv[^"]*)"', caseSensitive: false),
      RegExp(r'"(https?://[^"]*\.avi[^"]*)"', caseSensitive: false),
      RegExp(r'"(https?://[^"]*\.webm[^"]*)"', caseSensitive: false),
      
      // Player configuration patterns
      RegExp(r'src:\s*["\047`]([^"\047`]+)["\047`]', caseSensitive: false),
      RegExp(r'file:\s*["\047`]([^"\047`]+)["\047`]', caseSensitive: false),
      RegExp(r'source:\s*["\047`]([^"\047`]+)["\047`]', caseSensitive: false),
      RegExp(r'url:\s*["\047`]([^"\047`]+)["\047`]', caseSensitive: false),
      RegExp(r'stream:\s*["\047`]([^"\047`]+)["\047`]', caseSensitive: false),
      
      // JSON patterns
      RegExp(r'"(?:videoUrl|streamUrl|playUrl)":\s*"([^"]+)"', caseSensitive: false),
      RegExp(r'"(?:file|src|url)":\s*"([^"]+\.(?:mp4|m3u8|mkv|avi|webm)[^"]*)"', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(script);
      for (final match in matches) {
        final url = match.group(1);
        if (url != null && _isValidVideoUrl(url)) {
          sources.add(VideoSource(
            url: _resolveUrl(url, pageUrl),
            quality: _extractQualityFromUrl(url),
            type: _getVideoType(url),
          ));
        }
      }
    }

    return sources;
  }

  /// Check if URL is a valid video URL
  bool _isValidVideoUrl(String url) {
    final videoExtensions = ['.mp4', '.m3u8', '.mkv', '.avi', '.webm', '.mov', '.flv'];
    return videoExtensions.any((ext) => url.toLowerCase().contains(ext)) ||
           url.contains('stream') ||
           url.contains('video') ||
           url.contains('player');
  }

  /// Check if iframe source is a video player
  bool _isVideoIframe(String src) {
    final playerDomains = ['youtube.com', 'vimeo.com', 'dailymotion.com', 'player', 'embed', 'stream'];
    return playerDomains.any((domain) => src.toLowerCase().contains(domain));
  }

  /// Resolve relative URLs to absolute URLs
  String _resolveUrl(String url, String baseUrl) {
    if (url.startsWith('http')) return url;
    if (url.startsWith('//')) return 'https:$url';
    if (url.startsWith('/')) {
      final uri = Uri.parse(baseUrl);
      return '${uri.scheme}://${uri.host}$url';
    }
    return '$baseUrl/$url';
  }

  /// Extract quality information from element or URL
  String _extractQuality(Element element, String url) {
    // Check element attributes
    final quality = element.attributes['data-quality'] ?? 
                   element.attributes['quality'] ??
                   element.attributes['data-res'];
    
    if (quality != null) return quality;
    
    return _extractQualityFromUrl(url);
  }

  /// Extract quality from URL
  String _extractQualityFromUrl(String url) {
    final qualityPatterns = [
      RegExp(r'(\d+p)', caseSensitive: false),
      RegExp(r'(\d+x\d+)', caseSensitive: false),
      RegExp(r'(hd|sd|uhd|4k|1080|720|480|360)', caseSensitive: false),
    ];
    
    for (final pattern in qualityPatterns) {
      final match = pattern.firstMatch(url);
      if (match != null) return match.group(1)!;
    }
    
    return 'Unknown';
  }

  /// Get video type from URL
  String _getVideoType(String url) {
    if (url.contains('.m3u8')) return 'HLS';
    if (url.contains('.mp4')) return 'MP4';
    if (url.contains('.mkv')) return 'MKV';
    if (url.contains('.avi')) return 'AVI';
    if (url.contains('.webm')) return 'WebM';
    return 'Unknown';
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}

/// Video source model
class VideoSource {
  final String url;
  final String quality;
  final String type;

  VideoSource({
    required this.url,
    required this.quality,
    required this.type,
  });

  @override
  String toString() => 'VideoSource(url: $url, quality: $quality, type: $type)';
}
