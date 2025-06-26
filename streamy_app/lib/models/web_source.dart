class WebSource {
  final String id;
  final String name;
  final String baseUrl;
  final List<String> adBlockPatterns;
  final Map<String, String> videoSelectors;
  final Map<String, String> headers;
  final bool isEnabled;

  WebSource({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.adBlockPatterns,
    required this.videoSelectors,
    this.headers = const {},
    this.isEnabled = true,
  });

  factory WebSource.fromJson(Map<String, dynamic> json) {
    return WebSource(
      id: json['id'],
      name: json['name'],
      baseUrl: json['baseUrl'],
      adBlockPatterns: List<String>.from(json['adBlockPatterns'] ?? []),
      videoSelectors: Map<String, String>.from(json['videoSelectors'] ?? {}),
      headers: Map<String, String>.from(json['headers'] ?? {}),
      isEnabled: json['isEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'baseUrl': baseUrl,
      'adBlockPatterns': adBlockPatterns,
      'videoSelectors': videoSelectors,
      'headers': headers,
      'isEnabled': isEnabled,
    };
  }
}

class MediaExtractor {
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final List<VideoSource> videoSources;
  final Map<String, dynamic> metadata;

  MediaExtractor({
    required this.title,
    this.description,
    this.thumbnailUrl,
    required this.videoSources,
    this.metadata = const {},
  });
}

class VideoSource {
  final String url;
  final String quality;
  final String format;
  final Map<String, String> headers;

  VideoSource({
    required this.url,
    required this.quality,
    required this.format,
    this.headers = const {},
  });
}
