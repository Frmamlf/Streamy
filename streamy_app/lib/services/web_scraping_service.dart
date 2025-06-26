import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import '../models/web_source.dart';
import '../models/media_item.dart';

class WebScrapingService {
  static const List<String> commonAdPatterns = [
    'googletagmanager.com',
    'doubleclick.net',
    'googlesyndication.com',
    'amazon-adsystem.com',
    'adsystem.com',
    'facebook.com/tr',
    'analytics.google.com',
    'google-analytics.com',
    'scorecardresearch.com',
    'outbrain.com',
    'taboola.com',
    'ads',
    'advertisement',
    'popup',
    'banner',
    'sponsor',
  ];

  static final List<WebSource> predefinedSources = [
    WebSource(
      id: 'asd_homes',
      name: 'ASD Homes',
      baseUrl: 'https://a.asd.homes',
      adBlockPatterns: [
        ...commonAdPatterns,
        'asd.homes/ads',
        'asd.homes/popup',
        'cdn.asd.homes/ads',
        // Add more specific patterns for this site
      ],
      videoSelectors: {
        'video': 'video',
        'iframe': 'iframe[src*="player"]',
        'source': 'source[src]',
        'embed': '[data-src*=".mp4"], [data-src*=".m3u8"]',
      },
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Referer': 'https://a.asd.homes',
      },
    ),
  ];

  final http.Client _client;
  List<WebSource> _customSources = [];

  WebScrapingService() : _client = http.Client();

  List<WebSource> get allSources => [...predefinedSources, ..._customSources];

  void addCustomSource(WebSource source) {
    _customSources.add(source);
  }

  void removeCustomSource(String id) {
    _customSources.removeWhere((source) => source.id == id);
  }

  Future<List<MediaItem>> searchMovies(String query) async {
    List<MediaItem> allResults = [];

    for (WebSource source in allSources.where((s) => s.isEnabled)) {
      try {
        final results = await _searchInSource(source, query);
        allResults.addAll(results);
      } catch (e) {
        print('Error searching in ${source.name}: $e');
      }
    }

    return allResults;
  }

  Future<List<MediaItem>> _searchInSource(WebSource source, String query) async {
    final searchUrl = '${source.baseUrl}/search?q=${Uri.encodeComponent(query)}';
    
    final response = await _client.get(
      Uri.parse(searchUrl),
      headers: source.headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load search results from ${source.name}');
    }

    return _parseSearchResults(source, response.body);
  }

  List<MediaItem> _parseSearchResults(WebSource source, String html) {
    final document = html_parser.parse(html);
    final List<MediaItem> items = [];

    // Generic selectors for movie/show cards
    final movieCards = document.querySelectorAll([
      '.movie-card',
      '.film-item',
      '.video-item',
      '.content-item',
      '[class*="movie"]',
      '[class*="film"]',
      '[class*="video"]',
    ].join(', '));

    for (Element card in movieCards) {
      try {
        final title = _extractText(card, [
          '.title',
          '.movie-title',
          '.film-title',
          'h3',
          'h2',
          '[class*="title"]',
        ]);

        final thumbnail = _extractAttribute(card, [
          'img',
          '.poster img',
          '.thumbnail img',
        ], 'src');

        final link = _extractAttribute(card, [
          'a',
          '[href]',
        ], 'href');

        if (title.isNotEmpty && link.isNotEmpty) {
          items.add(MediaItem(
            id: '${source.id}_${Uri.encodeComponent(link)}',
            title: title,
            thumbnailUrl: _makeAbsoluteUrl(source.baseUrl, thumbnail),
            contentType: ContentType.movie,
            sources: [_makeAbsoluteUrl(source.baseUrl, link)],
            metadata: {
              'source': source.name,
              'originalUrl': link,
            },
          ));
        }
      } catch (e) {
        print('Error parsing movie card: $e');
      }
    }

    return items;
  }

  Future<MediaExtractor> extractVideoSources(WebSource source, String url) async {
    final response = await _client.get(
      Uri.parse(url),
      headers: source.headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load video page');
    }

    final document = html_parser.parse(response.body);
    
    // Extract page title
    final title = document.querySelector('title')?.text ?? 'Unknown';
    
    // Extract description
    final description = document.querySelector('meta[name="description"]')?.attributes['content'];
    
    // Extract thumbnail
    final thumbnail = document.querySelector('meta[property="og:image"]')?.attributes['content'];

    // Extract video sources
    final videoSources = await _extractVideoSources(document, source);

    return MediaExtractor(
      title: title,
      description: description,
      thumbnailUrl: thumbnail,
      videoSources: videoSources,
      metadata: {
        'source': source.name,
        'url': url,
      },
    );
  }

  Future<List<VideoSource>> _extractVideoSources(Document document, WebSource source) async {
    final List<VideoSource> sources = [];

    // Extract direct video elements
    final videoElements = document.querySelectorAll('video source, video');
    for (Element element in videoElements) {
      final src = element.attributes['src'];
      if (src != null && src.isNotEmpty) {
        sources.add(VideoSource(
          url: _makeAbsoluteUrl(source.baseUrl, src),
          quality: _guessQuality(src),
          format: _guessFormat(src),
          headers: source.headers,
        ));
      }
    }

    // Extract iframe sources and try to resolve them
    final iframes = document.querySelectorAll('iframe[src]');
    for (Element iframe in iframes) {
      final src = iframe.attributes['src'];
      if (src != null && _isVideoFrame(src)) {
        try {
          final resolvedSources = await _resolveIframeSources(src, source);
          sources.addAll(resolvedSources);
        } catch (e) {
          print('Error resolving iframe: $e');
        }
      }
    }

    // Extract embedded player URLs from scripts
    final scripts = document.querySelectorAll('script');
    for (Element script in scripts) {
      final content = script.text;
      final videoUrls = _extractVideoUrlsFromScript(content);
      for (String url in videoUrls) {
        sources.add(VideoSource(
          url: url,
          quality: _guessQuality(url),
          format: _guessFormat(url),
          headers: source.headers,
        ));
      }
    }

    return sources;
  }

  Future<List<VideoSource>> _resolveIframeSources(String iframeUrl, WebSource source) async {
    try {
      final response = await _client.get(
        Uri.parse(iframeUrl),
        headers: source.headers,
      );

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        return await _extractVideoSources(document, source);
      }
    } catch (e) {
      print('Error resolving iframe: $e');
    }
    return [];
  }

  List<String> _extractVideoUrlsFromScript(String script) {
    final List<String> urls = [];
    
    // Common patterns for video URLs in JavaScript
    final patterns = [
      RegExp(r'"(https?://[^"]*\.m3u8[^"]*)"'),
      RegExp(r'"(https?://[^"]*\.mp4[^"]*)"'),
      RegExp(r'"(https?://[^"]*\.mkv[^"]*)"'),
      RegExp(r'"(https?://[^"]*\.avi[^"]*)"'),
      RegExp(r'src:\s*["\']([^"\']*)["\']'),
      RegExp(r'file:\s*["\']([^"\']*)["\']'),
      RegExp(r'source:\s*["\']([^"\']*)["\']'),
    ];

    for (RegExp pattern in patterns) {
      final matches = pattern.allMatches(script);
      for (Match match in matches) {
        final url = match.group(1);
        if (url != null && _isValidVideoUrl(url)) {
          urls.add(url);
        }
      }
    }

    return urls;
  }

  String _extractText(Element element, List<String> selectors) {
    for (String selector in selectors) {
      final found = element.querySelector(selector);
      if (found != null) {
        return found.text.trim();
      }
    }
    return '';
  }

  String _extractAttribute(Element element, List<String> selectors, String attribute) {
    for (String selector in selectors) {
      final found = element.querySelector(selector);
      if (found != null) {
        final value = found.attributes[attribute];
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
    }
    return '';
  }

  String _makeAbsoluteUrl(String baseUrl, String url) {
    if (url.startsWith('http')) return url;
    if (url.startsWith('//')) return 'https:$url';
    if (url.startsWith('/')) return '$baseUrl$url';
    return '$baseUrl/$url';
  }

  String _guessQuality(String url) {
    if (url.contains('1080') || url.contains('fullhd')) return '1080p';
    if (url.contains('720') || url.contains('hd')) return '720p';
    if (url.contains('480')) return '480p';
    if (url.contains('360')) return '360p';
    return 'Auto';
  }

  String _guessFormat(String url) {
    if (url.contains('.m3u8')) return 'HLS';
    if (url.contains('.mpd')) return 'DASH';
    if (url.contains('.mp4')) return 'MP4';
    if (url.contains('.mkv')) return 'MKV';
    if (url.contains('.avi')) return 'AVI';
    return 'Unknown';
  }

  bool _isVideoFrame(String url) {
    return url.contains('player') || 
           url.contains('embed') || 
           url.contains('video') ||
           url.contains('stream');
  }

  bool _isValidVideoUrl(String url) {
    return url.contains('.mp4') || 
           url.contains('.m3u8') || 
           url.contains('.mkv') || 
           url.contains('.avi') ||
           url.contains('stream') ||
           url.contains('video');
  }

  String applyAdBlocking(String html, WebSource source) {
    String blockedHtml = html;

    // Remove script tags with ad patterns
    for (String pattern in [...commonAdPatterns, ...source.adBlockPatterns]) {
      blockedHtml = blockedHtml.replaceAll(
        RegExp('<script[^>]*$pattern[^>]*>.*?</script>', caseSensitive: false, dotAll: true),
        '',
      );
    }

    // Remove div/iframe elements with ad patterns
    for (String pattern in [...commonAdPatterns, ...source.adBlockPatterns]) {
      blockedHtml = blockedHtml.replaceAll(
        RegExp('<(div|iframe)[^>]*$pattern[^>]*>.*?</\\1>', caseSensitive: false, dotAll: true),
        '',
      );
    }

    // Remove elements with ad-related classes/IDs
    final adSelectors = [
      'advertisement', 'ads', 'ad-banner', 'popup', 'overlay',
      'sponsored', 'promotion', 'marketing', 'banner'
    ];

    final document = html_parser.parse(blockedHtml);
    for (String selector in adSelectors) {
      document.querySelectorAll('[class*="$selector"], [id*="$selector"]')
        .forEach((element) => element.remove());
    }

    return document.outerHtml;
  }

  void dispose() {
    _client.close();
  }
}
