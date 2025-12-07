import 'api_client.dart';
import 'pagerank_service.dart';
import 'models/article.dart';
import 'models/pagination.dart';
import 'models/user_search_result.dart';

class SearchService {
  final ApiClient _client;
  final PageRankService _pageRankService;
  
  SearchService({ApiClient? client, PageRankService? pageRankService}) 
      : _client = client ?? ApiClient.instance,
        _pageRankService = pageRankService ?? PageRankService();

  /// GET /api/articles/search?q=<query>
  /// Search articles by title, content (AI summary), or tags
  /// Also searches MF recommender for articles not in database yet
  Future<(List<ArticleModel> articles, PaginationInfo pagination)> searchArticles({
    required String query,
    int page = 1,
    int limit = 20,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    // Search from main backend
    final res = await _client.get('/api/articles/search', query: {
      'q': query,
      'page': page,
      'limit': limit,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    });
    final data = _client.decode(res);
    
    List<ArticleModel> articles = [];
    PaginationInfo pagination = const PaginationInfo(page: 1, limit: 20, total: 0, totalPages: 0);
    
    if (res.statusCode == 200 && data['success'] == true) {
      final rawArticles = (data['data']['articles'] as List?) ?? [];
      articles = rawArticles
          .map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
          .toList();
      pagination = PaginationInfo.fromJson(data['data']['pagination'] ?? {});
    }
    
    // On first page, also search MF recommender for additional results
    if (page == 1) {
      try {
        final mfResults = await _pageRankService.searchArticles(query);
        if (mfResults.isNotEmpty) {
          // Get IDs of articles we already have
          final existingIds = articles.map((a) => a.wikipediaId ?? a.id).toSet();
          
          // Filter out duplicates and convert to ArticleModel
          for (final mfArticle in mfResults) {
            final mfId = mfArticle['id']?.toString() ?? '';
            if (mfId.isNotEmpty && !existingIds.contains(mfId)) {
              // Mark these as from MF recommender (not in main DB yet)
              articles.add(ArticleModel.fromJson({
                ...mfArticle,
                '_fromRecommender': true, // Flag for UI if needed
              }));
              existingIds.add(mfId);
            }
          }
          
          // Update total to reflect merged results
          pagination = PaginationInfo(
            page: pagination.page,
            limit: pagination.limit,
            total: pagination.total + mfResults.length,
            totalPages: pagination.totalPages,
          );
        }
      } catch (e) {
        // Don't fail if MF search fails - just use backend results
        print('[SearchService] MF search error (non-fatal): $e');
      }
    }
    
    if (articles.isEmpty && res.statusCode != 200) {
      throw Exception(data['message'] ?? 'Failed to search articles');
    }
    
    return (articles, pagination);
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
