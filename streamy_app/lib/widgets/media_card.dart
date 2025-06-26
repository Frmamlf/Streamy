import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../screens/detail_screen.dart';

class MediaCard extends StatelessWidget {
  final MediaItem mediaItem;
  
  const MediaCard({
    super.key,
    required this.mediaItem,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(mediaItem: mediaItem),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  mediaItem.thumbnailUrl != null
                      ? Image.network(
                          mediaItem.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, _, __) => Container(
                            color: Colors.grey.shade800,
                            child: const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.white54,
                            ),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade800,
                          child: const Icon(
                            Icons.movie,
                            size: 50,
                            color: Colors.white54,
                          ),
                        ),
                  
                  // Type badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getContentTypeColor(mediaItem.contentType).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getContentTypeText(mediaItem.contentType),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  // Rating
                  if (mediaItem.rating != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              mediaItem.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                mediaItem.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getContentTypeText(ContentType type) {
    switch (type) {
      case ContentType.movie:
        return 'MOVIE';
      case ContentType.tvShow:
        return 'TV';
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
}
