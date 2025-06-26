import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/api_service.dart';
import '../services/app_service_manager.dart';
import '../widgets/media_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  final AppServiceManager _serviceManager = AppServiceManager();
  bool _isSearching = false;
  List<MediaItem> _searchResults = [];
  String _lastQuery = '';
  bool _searchInWebSources = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty || query == _lastQuery) return;
    
    setState(() {
      _isSearching = true;
      _lastQuery = query;
    });

    try {
      List<MediaItem> results = [];
      
      // Search in API
      final apiResults = await _apiService.searchMedia(query);
      results.addAll(apiResults);
      
      // Search in web sources if enabled
      if (_searchInWebSources) {
        final webResults = await _serviceManager.webScrapingService.searchMovies(query);
        results.addAll(webResults);
      }
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onSubmitted: _performSearch,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search movies, shows, anime...',
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
            ),
            border: InputBorder.none,
          ),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'toggle_web_sources') {
                setState(() {
                  _searchInWebSources = !_searchInWebSources;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _searchInWebSources 
                          ? 'Web sources enabled' 
                          : 'Web sources disabled'
                    ),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_web_sources',
                child: Row(
                  children: [
                    Icon(
                      _searchInWebSources ? Icons.web : Icons.web_asset,
                      color: _searchInWebSources 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(_searchInWebSources ? 'Disable Web Sources' : 'Enable Web Sources'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _performSearch(_searchController.text),
          ),
        ],
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : _searchResults.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _lastQuery.isEmpty
                          ? const Icon(
                              Icons.search,
                              size: 80,
                              color: Colors.grey,
                            )
                          : const Icon(
                              Icons.movie_filter,
                              size: 80,
                              color: Colors.grey,
                            ),
                      const SizedBox(height: 16),
                      Text(
                        _lastQuery.isEmpty
                            ? 'Enter search terms'
                            : 'No results found for "$_lastQuery"',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    return MediaCard(mediaItem: _searchResults[index]);
                  },
                ),
    );
  }
}
