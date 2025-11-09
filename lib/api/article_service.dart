import 'api_client.dart';
import 'package:http/http.dart' as http;

class ArticleService {
  final ApiClient _client;
  ArticleService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  Future<List<Map<String, dynamic>>> listArticles({int page = 1, int limit = 10, String sortBy = 'likeCount', String sortOrder = 'desc'}) async {
    final http.Response res = await _client.get('/api/articles', query: {
      'page': page,
      'limit': limit,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    });
    final data = _client.decode(res);
    if (res.statusCode == 200 && data['success'] == true) {
      final list = (data['data']['articles'] as List).cast<Map<String, dynamic>>();
      return list;
    }
    throw Exception(data['message'] ?? 'Failed to fetch articles');
  }
}
