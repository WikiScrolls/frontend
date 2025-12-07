import 'api_client.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'models/article.dart';
import 'models/user.dart';

class SearchService {
  final ApiClient _client;
  SearchService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  // Search articles by title or content
  Future<List<ArticleModel>> searchArticles(String query, {int page = 1, int limit = 20}) async {
    if (query.trim().isEmpty) return [];
    
    final http.Response res = await _client.get(
      '/api/articles',
      query: {
        'page': page.toString(),
        'limit': limit.toString(),
        'search': query,
      },
    );
    
    final data = _client.decode(res);
    if (res.statusCode == 200 && data['success'] == true) {
      // Backend returns { success: true, data: { articles: [...], pagination: {...} } }
      final responseData = data['data'] as Map<String, dynamic>;
      final articles = (responseData['articles'] as List)
          .map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return articles;
    }
    throw Exception(data['message'] ?? 'Failed to search articles');
  }

  // Search users by username or display name
  // Note: Using GET /api/profiles/:userId for individual lookups
  // This is a workaround until backend adds public user search
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];
    
    try {
      // Get current user's profile to find other users
      final http.Response res = await _client.get('/api/profiles/me');
      final data = _client.decode(res);
      
      if (res.statusCode == 200 && data['success'] == true) {
        final profile = data['data'];
        final currentUser = UserModel(
          id: profile['userId'] ?? '',
          username: profile['user']?['username'] ?? profile['displayName'] ?? '',
          email: profile['user']?['email'] ?? '',
        );
        
        // For now, return current user if query matches
        // TODO: Backend needs to implement public user search endpoint
        final queryLower = query.toLowerCase();
        if (currentUser.username.toLowerCase().contains(queryLower)) {
          return [currentUser];
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('[SearchService] User search error: $e');
      }
      return [];
    }
  }

  // Get recent searches (stored locally)
  Future<List<String>> getRecentSearches() async {
    // TODO: Implement local storage for recent searches
    return [];
  }

  // Save search query to recent searches
  Future<void> saveRecentSearch(String query) async {
    // TODO: Implement local storage
  }

  // Clear recent searches
  Future<void> clearRecentSearches() async {
    // TODO: Implement local storage
  }
}
