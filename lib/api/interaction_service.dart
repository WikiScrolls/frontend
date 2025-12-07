import 'api_client.dart';
import 'models/article.dart';
import 'models/interaction_check.dart';
import 'models/pagination.dart';

class InteractionService {
  final ApiClient _client;
  InteractionService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  // POST /api/interactions (like, bookmark, etc.)
  Future<Map<String, dynamic>> createInteraction({required String articleId, required String interactionType}) async {
    final res = await _client.post('/api/interactions', body: {
      'articleId': articleId,
      'interactionType': interactionType,
    });
    final data = _client.decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300 && data['success'] == true) {
      return Map<String, dynamic>.from(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to create interaction');
  }

  // DELETE /api/interactions (undo interaction)
  Future<bool> deleteInteraction({required String articleId, required String interactionType}) async {
    final res = await _client.delete('/api/interactions', body: {
      'articleId': articleId,
      'interactionType': interactionType,
    });
    if (res.statusCode == 204) return true;
    final data = _client.decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300 && data['success'] == true) {
      return true;
    }
    throw Exception(data['message'] ?? 'Failed to delete interaction');
  }

  // GET /api/interactions/me (list my interactions)
  Future<List<Map<String, dynamic>>> listMyInteractions() async {
    final res = await _client.get('/api/interactions/me');
    final data = _client.decode(res);
    if (res.statusCode == 200 && data['success'] == true) {
      return (data['data']['interactions'] as List).cast<Map<String, dynamic>>();
    }
    throw Exception(data['message'] ?? 'Failed to fetch interactions');
  }

  /// GET /api/interactions/check/:articleId
  /// Returns { liked: bool, saved: bool }
  Future<InteractionCheck> checkInteraction(String articleId) async {
    final res = await _client.get('/api/interactions/check/$articleId');
    final data = _client.decode(res);
    if (res.statusCode == 200 && data['success'] == true) {
      return InteractionCheck.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to check interaction');
  }

  /// Legacy method for backward compatibility
  Future<bool> hasInteraction(String articleId) async {
    final check = await checkInteraction(articleId);
    return check.liked || check.saved;
  }

  /// GET /api/interactions/me/liked
  /// Returns paginated list of liked articles
  Future<(List<ArticleModel> articles, PaginationInfo pagination)> getMyLikedArticles({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _client.get('/api/interactions/me/liked', query: {
      'page': page,
      'limit': limit,
    });
    final data = _client.decode(res);
    if (res.statusCode == 200 && data['success'] == true) {
      final rawArticles = (data['data']['articles'] as List?) ?? [];
      final articles = rawArticles
          .map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagination = PaginationInfo.fromJson(data['data']['pagination'] ?? {});
      return (articles, pagination);
    }
    throw Exception(data['message'] ?? 'Failed to fetch liked articles');
  }

  /// GET /api/interactions/me/saved
  /// Returns paginated list of saved articles
  Future<(List<ArticleModel> articles, PaginationInfo pagination)> getMySavedArticles({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _client.get('/api/interactions/me/saved', query: {
      'page': page,
      'limit': limit,
    });
    final data = _client.decode(res);
    if (res.statusCode == 200 && data['success'] == true) {
      final rawArticles = (data['data']['articles'] as List?) ?? [];
      final articles = rawArticles
          .map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagination = PaginationInfo.fromJson(data['data']['pagination'] ?? {});
      return (articles, pagination);
    }
    throw Exception(data['message'] ?? 'Failed to fetch saved articles');
  }

  /// GET /api/interactions/users/:userId/liked
  /// Returns paginated list of liked articles for a specific user
  Future<(List<ArticleModel> articles, PaginationInfo pagination)> getUserLikedArticles({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _client.get('/api/interactions/users/$userId/liked', query: {
      'page': page,
      'limit': limit,
    });
    final data = _client.decode(res);
    if (res.statusCode == 200 && data['success'] == true) {
      final rawArticles = (data['data']['articles'] as List?) ?? [];
      final articles = rawArticles
          .map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagination = PaginationInfo.fromJson(data['data']['pagination'] ?? {});
      return (articles, pagination);
    }
    throw Exception(data['message'] ?? 'Failed to fetch user liked articles');
  }

  // Convenience methods for like/save operations
  Future<void> likeArticle(String articleId) async {
    await createInteraction(articleId: articleId, interactionType: 'LIKE');
  }

  Future<void> unlikeArticle(String articleId) async {
    await deleteInteraction(articleId: articleId, interactionType: 'LIKE');
  }

  Future<void> saveArticle(String articleId) async {
    await createInteraction(articleId: articleId, interactionType: 'SAVE');
  }

  Future<void> unsaveArticle(String articleId) async {
    await deleteInteraction(articleId: articleId, interactionType: 'SAVE');
  }
}
