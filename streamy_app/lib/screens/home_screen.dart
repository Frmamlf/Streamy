import 'package:flutter/material.dart';
import '../widgets/media_card.dart';
import '../models/media_item.dart';
import '../services/api_service.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _categories = [
    'All', 'Movies', 'TV Shows', 'Anime', 'Favorites'
  ];
  
  int _selectedIndex = 0;
  int _selectedCategoryIndex = 0;
  bool _isLoading = true;
  List<MediaItem> _mediaItems = [];
  List<MediaItem> _filteredMediaItems = [];
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await _apiService.getMedia();
      setState(() {
        _mediaItems = items;
        _filterMediaByCategory();
        _isLoading = false;
      });
    } catch (e) {
      // In a real app, we'd handle errors properly
      setState(() {
        _isLoading = false;
        _mediaItems = dummyMediaItems; // Fallback to dummy data
        _filterMediaByCategory();
      });
    }
  }
  
  void _filterMediaByCategory() {
    if (_selectedCategoryIndex == 0) {
      // "All" category
      _filteredMediaItems = List.from(_mediaItems);
    } else {
      final categoryName = _categories[_selectedCategoryIndex].toLowerCase();
      _filteredMediaItems = _mediaItems.where((item) {
        switch (categoryName) {
          case 'movies':
            return item.contentType == ContentType.movie;
          case 'tv shows':
            return item.contentType == ContentType.tvShow;
          case 'anime':
            return item.contentType == ContentType.anime;
          case 'favorites':
            // In a real app, we'd check if this item is in favorites
            return false; 
          default:
            return true;
        }
      }).toList();
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Streamy',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                        _filterMediaByCategory();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: index == _selectedCategoryIndex 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          color: index == _selectedCategoryIndex 
                            ? Colors.white 
                            : Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Media Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMediaItems.isEmpty
                    ? const Center(child: Text('No content available'))
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _filteredMediaItems.length,
                        itemBuilder: (context, index) {
                          return MediaCard(mediaItem: _filteredMediaItems[index]);
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Dummy data for testing
final List<MediaItem> dummyMediaItems = [
  MediaItem(
    id: 'movie1',
    title: 'Movie Title 1',
    thumbnailUrl: 'https://via.placeholder.com/300x450',
    contentType: ContentType.movie,
    rating: 4.5,
  ),
  MediaItem(
    id: 'movie2',
    title: 'Movie Title 2',
    thumbnailUrl: 'https://via.placeholder.com/300x450',
    contentType: ContentType.movie,
    rating: 3.8,
  ),
  MediaItem(
    id: 'show1',
    title: 'TV Show Title 1',
    thumbnailUrl: 'https://via.placeholder.com/300x450',
    contentType: ContentType.tvShow,
    rating: 4.2,
  ),
  MediaItem(
    id: 'show2',
    title: 'TV Show Title 2',
    thumbnailUrl: 'https://via.placeholder.com/300x450',
    contentType: ContentType.tvShow,
    rating: 4.7,
  ),
  MediaItem(
    id: 'anime1',
    title: 'Anime Title 1',
    thumbnailUrl: 'https://via.placeholder.com/300x450',
    contentType: ContentType.anime,
    rating: 4.9,
  ),
  MediaItem(
    id: 'anime2',
    title: 'Anime Title 2',
    thumbnailUrl: 'https://via.placeholder.com/300x450',
    contentType: ContentType.anime,
    rating: 4.1,
  ),
];
