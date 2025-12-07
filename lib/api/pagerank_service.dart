import 'api_client.dart';

/// Service for PageRank/MF recommender interactions
/// Base URL: http://mf_recommender.digilabdte.com
class PageRankService {
  static const String _baseUrl = 'http://mf_recommender.digilabdte.com';
  final ApiClient _client;

  PageRankService() : _client = ApiClient(baseUrl: _baseUrl);

  /// POST /api/articles/:id/like?userId
  /// Adds weight for the pagerank recommender when user likes an article
  Future<void> recordLike({
    required String articleId,
    required String userId,
  }) async {
    try {
      final res = await _client.post(
        '/api/articles/$articleId/like',
        query: {'userId': userId},
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        print('[PageRankService] Like recorded for article $articleId');
      } else {
        print('[PageRankService] Like failed: ${res.statusCode}');
      }
    } catch (e) {
      // Don't throw - this is a background operation
      print('[PageRankService] Error recording like: $e');
    }
  }

  /// POST /api/articles/:id/open?userId
  /// Adds weight for the pagerank recommender when user opens/reads an article
  Future<void> recordOpen({
    required String articleId,
    required String userId,
  }) async {
    try {
      final res = await _client.post(
        '/api/articles/$articleId/open',
        query: {'userId': userId},
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        print('[PageRankService] Open recorded for article $articleId');
      } else {
        print('[PageRankService] Open failed: ${res.statusCode}');
      }
    } catch (e) {
      // Don't throw - this is a background operation
      print('[PageRankService] Error recording open: $e');
    }
  }

  /// GET /api/articles/search?keyword
  /// Search articles from the MF recommender (may include articles not in main DB)
  Future<List<Map<String, dynamic>>> searchArticles(String keyword) async {
    try {
      final res = await _client.get(
        '/api/articles/search',
        query: {'keyword': keyword},
      );
      final data = _client.decode(res);
      
      if (res.statusCode == 200) {
        // Handle different response formats
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['data'] != null) {
          return (data['data'] as List).cast<Map<String, dynamic>>();
        } else if (data is Map && data['articles'] != null) {
          return (data['articles'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      }
      return [];
    } catch (e) {
      print('[PageRankService] Error searching articles: $e');
      return [];
    }
  }
}
