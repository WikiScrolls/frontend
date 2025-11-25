import 'api_client.dart';
import 'models/article.dart';
import 'models/pagination.dart';
import 'package:http/http.dart' as http;

class ArticleService {
  final ApiClient _client;
  ArticleService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  Future<(List<ArticleModel> articles, PaginationInfo? pagination)> listArticles({int page = 1, int limit = 10, String sortBy = 'likeCount', String sortOrder = 'desc'}) async {
    final local = ApiClient(baseUrl: "http://mf_recommender.digilabdte.com");
    final http.Response res = await local.get(
      'api/recommendation/random',
    );
    final data = local.decode(res);
    if (res.statusCode == 200) {
      final rawArticles = (data['data'] as List);
      final articles = rawArticles.map((e) => ArticleModel.fromJson(e as Map<String, dynamic>)).toList();

      return (articles, null);
    }
    throw Exception(data['error'] ?? 'Failed to fetch articles');
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
