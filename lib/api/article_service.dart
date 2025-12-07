import 'api_client.dart';
import 'models/article.dart';
import 'models/pagination.dart';
import 'package:http/http.dart' as http;

class ArticleService {
  final ApiClient _client;
  ArticleService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  /// Fetches articles from the recommender service and upserts them to the backend.
  /// Returns articles with proper backend UUIDs that can be used for interactions.
  Future<(List<ArticleModel> articles, PaginationInfo? pagination)> listArticles({
    int page = 1,
    int limit = 10,
    String sortBy = 'likeCount',
    String sortOrder = 'desc',
  }) async {
    // 1. Fetch from recommender service
    final recommenderClient = ApiClient(baseUrl: "http://mf_recommender.digilabdte.com");
    final http.Response recommenderRes = await recommenderClient.get('api/recommendation/random');
    final recommenderData = recommenderClient.decode(recommenderRes);

    if (recommenderRes.statusCode != 200) {
      throw Exception(recommenderData['error'] ?? 'Failed to fetch from recommender');
    }

    final rawArticles = (recommenderData['data'] as List);
    if (rawArticles.isEmpty) {
      return (<ArticleModel>[], null);
    }

    // 2. Prepare articles for batch upsert to backend
    final articlesToUpsert = rawArticles.map((e) {
      final map = e as Map<String, dynamic>;
      final title = (map['title'] ?? '') as String;
      final wikipediaId = map['id']?.toString() ?? '';
      
      // Recommender returns empty wikipediaUrl, so we construct it from the title
      String wikipediaUrl = (map['wikipediaUrl'] ?? '') as String;
      if (wikipediaUrl.isEmpty) {
        // Construct Wikipedia URL from title (replace spaces with underscores)
        final encodedTitle = title.replaceAll(' ', '_');
        wikipediaUrl = 'https://en.wikipedia.org/wiki/$encodedTitle';
      }
      
      return {
        'id': wikipediaId, // Wikipedia Page ID
        'title': title,
        'wikipediaUrl': wikipediaUrl,
        'content': map['content'] ?? map['extract'] ?? map['body'] ?? '',
        'thumbnail': map['imageUrl'] ?? map['thumbnail'] ?? map['image'] ?? '',
      };
    }).where((a) => a['id']!.isNotEmpty && a['title']!.isNotEmpty).toList();

    if (articlesToUpsert.isEmpty) {
      return (<ArticleModel>[], null);
    }

    // 3. Batch upsert to backend to get/create proper UUIDs
    try {
      final upsertRes = await _client.post('/api/articles/upsert-batch', body: {
        'articles': articlesToUpsert,
      });
      final upsertData = _client.decode(upsertRes);

      if (upsertRes.statusCode >= 200 && upsertRes.statusCode < 300 && upsertData['success'] == true) {
        // Return articles with backend UUIDs
        final backendArticles = (upsertData['data']['articles'] as List?) ?? [];
        final articles = backendArticles
            .map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return (articles, null);
      } else {
        // If upsert fails, log and fall back to recommender data (interactions won't work)
        print('[ArticleService] Batch upsert failed: ${upsertData['message']}');
        final articles = rawArticles
            .map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return (articles, null);
      }
    } catch (e) {
      // If backend call fails, fall back to recommender data (interactions won't work)
      print('[ArticleService] Backend upsert error: $e');
      final articles = rawArticles
          .map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return (articles, null);
    }
  }

  /// Upsert a single article to the backend
  Future<ArticleModel?> upsertArticle({
    required String wikipediaId,
    required String title,
    required String wikipediaUrl,
    String? content,
    String? thumbnail,
  }) async {
    try {
      final res = await _client.post('/api/articles/upsert', body: {
        'id': wikipediaId,
        'title': title,
        'wikipediaUrl': wikipediaUrl,
        if (content != null) 'content': content,
        if (thumbnail != null) 'thumbnail': thumbnail,
      });
      final data = _client.decode(res);

      if (res.statusCode >= 200 && res.statusCode < 300 && data['success'] == true) {
        return ArticleModel.fromJson(data['data']['article'] as Map<String, dynamic>);
      }
      print('[ArticleService] Upsert failed: ${data['message']}');
      return null;
    } catch (e) {
      print('[ArticleService] Upsert error: $e');
      return null;
    }
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
