import 'api_client.dart';
import 'models/article.dart';
import 'models/pagination.dart';
import 'models/user_search_result.dart';

class SearchService {
  final ApiClient _client;
  SearchService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  /// GET /api/articles/search?q=<query>
  /// Search articles by title, content (AI summary), or tags
  Future<(List<ArticleModel> articles, PaginationInfo pagination)> searchArticles({
    required String query,
    int page = 1,
    int limit = 20,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    final res = await _client.get('/api/articles/search', query: {
      'q': query,
      'page': page,
      'limit': limit,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
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
    throw Exception(data['message'] ?? 'Failed to search articles');
  }

  /// GET /api/users/search?q=<query>
  /// Search users by username or display name
  Future<(List<UserSearchResult> users, PaginationInfo pagination)> searchUsers({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _client.get('/api/users/search', query: {
      'q': query,
      'page': page,
      'limit': limit,
    });
    final data = _client.decode(res);
    if (res.statusCode == 200 && data['success'] == true) {
      final rawUsers = (data['data']['users'] as List?) ?? [];
      final users = rawUsers
          .map((e) => UserSearchResult.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagination = PaginationInfo.fromJson(data['data']['pagination'] ?? {});
      return (users, pagination);
    }
    throw Exception(data['message'] ?? 'Failed to search users');
  }
}
