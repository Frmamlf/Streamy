import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../models/media_item.dart';
import 'web_scraping_service.dart';

/// Enhanced Content Discovery and Search Service
class ContentDiscoveryService extends ChangeNotifier {
  static final ContentDiscoveryService _instance = ContentDiscoveryService._internal();
  factory ContentDiscoveryService() => _instance;
  ContentDiscoveryService._internal();
  
  static const String _searchHistoryBoxName = 'search_history';
  static const String _watchHistoryBoxName = 'watch_history';
  static const String _favoritesBoxName = 'favorites';
  static const String _trendingCacheBoxName = 'trending_cache';
  
  late Box<String> _searchHistoryBox;
  late Box<WatchHistoryItem> _watchHistoryBox;
  late Box<MediaItem> _favoritesBox;
  late Box<TrendingCache> _trendingCacheBox;
  
  final WebScrapingService _webScrapingService = WebScrapingService();
  final http.Client _httpClient = http.Client();
  
  // Search debouncing
  Timer? _searchDebounceTimer;
  static const Duration _searchDebounceDelay = Duration(milliseconds: 500);
  
  // Cache for search results
  final Map<String, List<MediaItem>> _searchCache = {};
  final Map<String, DateTime> _searchCacheTimestamps = {};
  static const Duration _cacheValidDuration = Duration(minutes: 15);
  
  // Current search state
  String _currentSearchQuery = '';
  List<MediaItem> _currentSearchResults = [];
  bool _isSearching = false;
  
  // Trending content
  List<MediaItem> _trendingMovies = [];
  List<MediaItem> _trendingTVShows = [];
  List<MediaItem> _popularContent = [];
  DateTime? _lastTrendingUpdate;
  
  // Getters
  String get currentSearchQuery => _currentSearchQuery;
  List<MediaItem> get currentSearchResults => _currentSearchResults;
  bool get isSearching => _isSearching;
  List<MediaItem> get trendingMovies => _trendingMovies;
  List<MediaItem> get trendingTVShows => _trendingTVShows;
  List<MediaItem> get popularContent => _popularContent;
  
  /// Initialize the content discovery service
  Future<void> initialize() async {
    _searchHistoryBox = await Hive.openBox<String>(_searchHistoryBoxName);
    _watchHistoryBox = await Hive.openBox<WatchHistoryItem>(_watchHistoryBoxName);
    _favoritesBox = await Hive.openBox<MediaItem>(_favoritesBoxName);
    _trendingCacheBox = await Hive.openBox<TrendingCache>(_trendingCacheBoxName);
    
    // Load cached trending content
    await _loadCachedTrendingContent();
    
    // Update trending content if cache is old
    if (_shouldUpdateTrendingContent()) {
      _updateTrendingContent();
    }
  }
  
  /// Perform real-time search across multiple sources
  Future<void> searchContent(String query) async {
    if (query.trim().isEmpty) {
      _currentSearchQuery = '';
      _currentSearchResults = [];
      notifyListeners();
      return;
    }
    
    _currentSearchQuery = query;
    _isSearching = true;
    notifyListeners();
    
    // Cancel previous search
    _searchDebounceTimer?.cancel();
    
    // Debounce search requests
    _searchDebounceTimer = Timer(_searchDebounceDelay, () async {
      await _performSearch(query);
    });
  }
  
  /// Perform the actual search
  Future<void> _performSearch(String query) async {
    try {
      // Check cache first
      if (_isSearchCacheValid(query)) {
        _currentSearchResults = _searchCache[query]!;
        _isSearching = false;
        notifyListeners();
        return;
      }
      
      // Search across multiple sources
      final results = await _webScrapingService.searchMovies(query);
      
      // Enhanced search with additional sources
      final enhancedResults = await _searchAdditionalSources(query);
      results.addAll(enhancedResults);
      
      // Remove duplicates and sort by relevance
      final uniqueResults = _removeDuplicatesAndSort(results, query);
      
      // Cache results
      _searchCache[query] = uniqueResults;
      _searchCacheTimestamps[query] = DateTime.now();
      
      // Add to search history
      await _addToSearchHistory(query);
      
      _currentSearchResults = uniqueResults;
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _isSearching = false;
      notifyListeners();
      if (kDebugMode) {
        print('Search error: $e');
      }
    }
  }
  
  /// Search additional sources (TMDB, OMDB, etc.)
  Future<List<MediaItem>> _searchAdditionalSources(String query) async {
    final results = <MediaItem>[];
    
    try {
      // Search TMDB (The Movie Database)
      final tmdbResults = await _searchTMDB(query);
      results.addAll(tmdbResults);
      
      // Search OMDB (Open Movie Database)
      final omdbResults = await _searchOMDB(query);
      results.addAll(omdbResults);
    } catch (e) {
      if (kDebugMode) {
        print('Additional sources search error: $e');
      }
    }
    
    return results;
  }
  
  /// Search TMDB API
  Future<List<MediaItem>> _searchTMDB(String query) async {
    // Note: You'll need to add your TMDB API key
    const apiKey = 'YOUR_TMDB_API_KEY';
    final url = 'https://api.themoviedb.org/3/search/multi?api_key=$apiKey&query=${Uri.encodeComponent(query)}';
    
    try {
      final response = await _httpClient.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = <MediaItem>[];
        
        for (final item in data['results']) {
          final mediaItem = _parseTMDBItem(item);
          if (mediaItem != null) {
            results.add(mediaItem);
          }
        }
        
        return results;
      }
    } catch (e) {
      if (kDebugMode) {
        print('TMDB search error: $e');
      }
    }
    
    return [];
  }
  
  /// Search OMDB API
  Future<List<MediaItem>> _searchOMDB(String query) async {
    // Note: You'll need to add your OMDB API key
    const apiKey = 'YOUR_OMDB_API_KEY';
    final url = 'http://www.omdbapi.com/?apikey=$apiKey&s=${Uri.encodeComponent(query)}';
    
    try {
      final response = await _httpClient.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = <MediaItem>[];
        
        if (data['Search'] != null) {
          for (final item in data['Search']) {
            final mediaItem = _parseOMDBItem(item);
            if (mediaItem != null) {
              results.add(mediaItem);
            }
          }
        }
        
        return results;
      }
    } catch (e) {
      if (kDebugMode) {
        print('OMDB search error: $e');
      }
    }
    
    return [];
  }
  
  /// Parse TMDB item to MediaItem
  MediaItem? _parseTMDBItem(Map<String, dynamic> item) {
    try {
      final id = item['id']?.toString() ?? '';
      final title = item['title'] ?? item['name'] ?? '';
      final overview = item['overview'] ?? '';
      final posterPath = item['poster_path'];
      final releaseDate = item['release_date'] ?? item['first_air_date'] ?? '';
      final voteAverage = (item['vote_average'] ?? 0).toDouble();
      final mediaType = item['media_type'] ?? 'movie';
      
      if (title.isEmpty) return null;
      
      final thumbnailUrl = posterPath != null 
          ? 'https://image.tmdb.org/t/p/w500$posterPath'
          : '';
      
      return MediaItem(
        id: 'tmdb_$id',
        title: title,
        thumbnailUrl: thumbnailUrl,
        contentType: mediaType == 'tv' ? ContentType.tvShow : ContentType.movie,
        rating: voteAverage,
        description: overview,
        sources: [], // Will be populated when user selects this item
        metadata: {
          'tmdb_id': id,
          'release_date': releaseDate,
          'media_type': mediaType,
          'source': 'TMDB',
        },
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Parse OMDB item to MediaItem
  MediaItem? _parseOMDBItem(Map<String, dynamic> item) {
    try {
      final imdbId = item['imdbID'] ?? '';
      final title = item['Title'] ?? '';
      final year = item['Year'] ?? '';
      final poster = item['Poster'] ?? '';
      final type = item['Type'] ?? 'movie';
      
      if (title.isEmpty) return null;
      
      return MediaItem(
        id: 'omdb_$imdbId',
        title: title,
        thumbnailUrl: poster != 'N/A' ? poster : '',
        contentType: type == 'series' ? ContentType.tvShow : ContentType.movie,
        rating: 0.0, // OMDB search doesn't return ratings
        description: '',
        sources: [],
        metadata: {
          'imdb_id': imdbId,
          'year': year,
          'type': type,
          'source': 'OMDB',
        },
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Remove duplicates and sort by relevance
  List<MediaItem> _removeDuplicatesAndSort(List<MediaItem> results, String query) {
    // Remove duplicates based on title similarity
    final uniqueResults = <MediaItem>[];
    final seenTitles = <String>{};
    
    for (final item in results) {
      final normalizedTitle = item.title.toLowerCase().trim();
      if (!seenTitles.contains(normalizedTitle)) {
        seenTitles.add(normalizedTitle);
        uniqueResults.add(item);
      }
    }
    
    // Sort by relevance (title match, rating, etc.)
    uniqueResults.sort((a, b) {
      final aRelevance = _calculateRelevance(a, query);
      final bRelevance = _calculateRelevance(b, query);
      return bRelevance.compareTo(aRelevance);
    });
    
    return uniqueResults;
  }
  
  /// Calculate relevance score for search result
  double _calculateRelevance(MediaItem item, String query) {
    double score = 0.0;
    final queryLower = query.toLowerCase();
    final titleLower = item.title.toLowerCase();
    
    // Exact match gets highest score
    if (titleLower == queryLower) {
      score += 100.0;
    }
    // Title starts with query
    else if (titleLower.startsWith(queryLower)) {
      score += 80.0;
    }
    // Title contains query
    else if (titleLower.contains(queryLower)) {
      score += 60.0;
    }
    
    // Add rating bonus
    score += (item.rating ?? 0.0) * 5;
    
    // Prefer movies over TV shows (can be made configurable)
    if (item.contentType == ContentType.movie) {
      score += 10.0;
    }
    
    return score;
  }
  
  /// Check if search cache is valid
  bool _isSearchCacheValid(String query) {
    if (!_searchCache.containsKey(query)) return false;
    
    final timestamp = _searchCacheTimestamps[query];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _cacheValidDuration;
  }
  
  /// Add search query to history
  Future<void> _addToSearchHistory(String query) async {
    final history = _searchHistoryBox.values.toList();
    
    // Remove if already exists
    history.remove(query);
    
    // Add to beginning
    history.insert(0, query);
    
    // Keep only last 50 searches
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }
    
    // Save back to box
    await _searchHistoryBox.clear();
    for (int i = 0; i < history.length; i++) {
      await _searchHistoryBox.put(i, history[i]);
    }
  }
  
  /// Get search history
  List<String> getSearchHistory() {
    return _searchHistoryBox.values.toList();
  }
  
  /// Clear search history
  Future<void> clearSearchHistory() async {
    await _searchHistoryBox.clear();
  }
  
  /// Add to favorites
  Future<void> addToFavorites(MediaItem item) async {
    await _favoritesBox.put(item.id, item);
    notifyListeners();
  }
  
  /// Remove from favorites
  Future<void> removeFromFavorites(String itemId) async {
    await _favoritesBox.delete(itemId);
    notifyListeners();
  }
  
  /// Check if item is in favorites
  bool isFavorite(String itemId) {
    return _favoritesBox.containsKey(itemId);
  }
  
  /// Get all favorites
  List<MediaItem> getFavorites() {
    return _favoritesBox.values.toList();
  }
  
  /// Add to watch history
  Future<void> addToWatchHistory(MediaItem item, {Duration? watchedDuration}) async {
    final historyItem = WatchHistoryItem(
      mediaItem: item,
      watchedAt: DateTime.now(),
      watchedDuration: watchedDuration ?? Duration.zero,
    );
    
    await _watchHistoryBox.put(item.id, historyItem);
    notifyListeners();
  }
  
  /// Get watch history
  List<WatchHistoryItem> getWatchHistory() {
    final history = _watchHistoryBox.values.toList();
    history.sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
    return history;
  }
  
  /// Get continue watching (partially watched items)
  List<WatchHistoryItem> getContinueWatching() {
    return _watchHistoryBox.values
        .where((item) => 
            item.watchedDuration > Duration.zero && 
            item.watchedDuration < Duration(hours: 2)) // Assume max movie length
        .toList()
      ..sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
  }
  
  /// Update trending content
  Future<void> _updateTrendingContent() async {
    try {
      // This would typically call external APIs like TMDB
      // For now, we'll use placeholder logic
      
      final trendingCache = TrendingCache(
        movies: [],
        tvShows: [],
        popular: [],
        lastUpdated: DateTime.now(),
      );
      
      await _trendingCacheBox.put('trending', trendingCache);
      
      _trendingMovies = trendingCache.movies;
      _trendingTVShows = trendingCache.tvShows;
      _popularContent = trendingCache.popular;
      _lastTrendingUpdate = trendingCache.lastUpdated;
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating trending content: $e');
      }
    }
  }
  
  /// Load cached trending content
  Future<void> _loadCachedTrendingContent() async {
    final trendingCache = _trendingCacheBox.get('trending');
    if (trendingCache != null) {
      _trendingMovies = trendingCache.movies;
      _trendingTVShows = trendingCache.tvShows;
      _popularContent = trendingCache.popular;
      _lastTrendingUpdate = trendingCache.lastUpdated;
    }
  }
  
  /// Check if trending content should be updated
  bool _shouldUpdateTrendingContent() {
    if (_lastTrendingUpdate == null) return true;
    
    final timeSinceUpdate = DateTime.now().difference(_lastTrendingUpdate!);
    return timeSinceUpdate > Duration(hours: 6); // Update every 6 hours
  }
  
  /// Get content by genre
  Future<List<MediaItem>> getContentByGenre(String genre) async {
    // Implementation for genre-based content discovery
    return [];
  }
  
  /// Get recommendations based on watch history
  List<MediaItem> getRecommendations() {
    // Simple recommendation logic based on favorites and watch history
    // This is a placeholder - in a real app, you'd use more sophisticated
    // recommendation algorithms
    return [];
  }
  
  /// Dispose resources
  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _httpClient.close();
    super.dispose();
  }
}

/// Watch history item model
@HiveType(typeId: 2)
class WatchHistoryItem extends HiveObject {
  @HiveField(0)
  MediaItem mediaItem;
  
  @HiveField(1)
  DateTime watchedAt;
  
  @HiveField(2)
  Duration watchedDuration;
  
  WatchHistoryItem({
    required this.mediaItem,
    required this.watchedAt,
    required this.watchedDuration,
  });
}

/// Trending content cache model
@HiveType(typeId: 3)
class TrendingCache extends HiveObject {
  @HiveField(0)
  List<MediaItem> movies;
  
  @HiveField(1)
  List<MediaItem> tvShows;
  
  @HiveField(2)
  List<MediaItem> popular;
  
  @HiveField(3)
  DateTime lastUpdated;
  
  TrendingCache({
    required this.movies,
    required this.tvShows,
    required this.popular,
    required this.lastUpdated,
  });
}
