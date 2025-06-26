enum ContentType { movie, tvShow, anime }

class MediaItem {
  final String id;
  final String title;
  final String? thumbnailUrl;
  final ContentType contentType;
  final double? rating;
  final String? description;
  final List<String>? sources;
  final Map<String, dynamic>? metadata;

  MediaItem({
    required this.id,
    required this.title,
    this.thumbnailUrl,
    required this.contentType,
    this.rating,
    this.description,
    this.sources,
    this.metadata,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    ContentType contentTypeFromString(String? type) {
      switch (type?.toLowerCase()) {
        case 'tv':
        case 'tvshow':
          return ContentType.tvShow;
        case 'anime':
          return ContentType.anime;
        default:
          return ContentType.movie;
      }
    }
    
    // Extract sources
    List<String>? sourceUrls;
    if (json['sources'] != null) {
      sourceUrls = (json['sources'] as List)
          .map((source) => source['url'].toString())
          .toList();
    }

    return MediaItem(
      id: json['id'],
      title: json['title'],
      thumbnailUrl: json['thumbnail'],
      contentType: contentTypeFromString(json['metadata']?['type']),
      rating: json['metadata']?['rating'] != null 
          ? double.tryParse(json['metadata']['rating'].toString()) 
          : null,
      description: json['description'],
      sources: sourceUrls,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}
