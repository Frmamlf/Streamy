import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/media_item.dart';

class ApiService {
  // For development, use your machine's IP address or hostname
  // when running in an emulator or real device:
  // - For Android emulator, use: 10.0.2.2:8000
  // - For iOS simulator, use: localhost:8000
  // - For real devices, use your computer's local IP address
  final String baseUrl = 'http://10.0.2.2:8000'; // Default for Android emulator

  Future<List<MediaItem>> getMedia() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/media'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => MediaItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load media: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }

  Future<MediaItem> getMediaById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/media/$id'));
      
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        return MediaItem.fromJson(data);
      } else {
        throw Exception('Failed to load media item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }

  Future<List<MediaItem>> searchMedia(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/search/$query'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => MediaItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search media: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }
}
