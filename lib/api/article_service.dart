import 'api_client.dart';
import 'models/article.dart';
import 'models/pagination.dart';
import 'package:http/http.dart' as http;

class ArticleService {
  final ApiClient _client;
  ArticleService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  Future<(List<ArticleModel> articles, PaginationInfo? pagination)> listArticles({int page = 1, int limit = 10, String sortBy = 'likeCount', String sortOrder = 'desc'}) async {
    final local = ApiClient(baseUrl: "http://localhost:8080");
    final http.Response res = await local.get(
      '/recommendations',
    );
    final data = local.decode(res);
    if (res.statusCode == 200 && data['success'] == true) {
      final rawArticles = (data['data']['articles'] as List);
      final articles = rawArticles.map((e) => ArticleModel.fromJson(e as Map<String, dynamic>)).toList();
      PaginationInfo? pagination;
      if (data['data']['pagination'] is Map<String, dynamic>) {
        pagination = PaginationInfo.fromJson(data['data']['pagination']);
      }
      return (articles, pagination);
    }
    throw Exception(data['message'] ?? 'Failed to fetch articles');
  }

  // POST /api/articles/:id/view to record a view
  Future<bool> recordView(String articleId) async {
    final res = await _client.post('/api/articles/$articleId/view');
    final data = _client.decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300 && data['success'] == true) {
      return true;
    }
    throw Exception(data['message'] ?? 'Failed to record view');
  }
}
