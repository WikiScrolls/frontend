import 'api_client.dart';

class FeedService {
  final ApiClient _client;
  FeedService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  // GET /api/feeds/me
  Future<Map<String, dynamic>> getMyFeed({int page = 1, int limit = 10}) async {
    final res = await _client.get('/api/feeds/me', query: {
      'page': page,
      'limit': limit,
    });
    final data = _client.decode(res);
    if (res.statusCode == 200 && data['success'] == true) {
      return Map<String, dynamic>.from(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to fetch feed');
  }

  // POST /api/feeds/me (create/init)
  Future<Map<String, dynamic>> createMyFeed(Map<String, dynamic> body) async {
    final res = await _client.post('/api/feeds/me', body: body);
    final data = _client.decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300 && data['success'] == true) {
      return Map<String, dynamic>.from(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to create feed');
  }

  // PUT /api/feeds/me (update settings)
  Future<Map<String, dynamic>> updateMyFeed(Map<String, dynamic> body) async {
    final res = await _client.put('/api/feeds/me', body: body);
    final data = _client.decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300 && data['success'] == true) {
      return Map<String, dynamic>.from(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to update feed');
  }

  // PUT /api/feeds/me/position (save current position)
  Future<Map<String, dynamic>> updatePosition(Map<String, dynamic> body) async {
    final res = await _client.put('/api/feeds/me/position', body: body);
    final data = _client.decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300 && data['success'] == true) {
      return Map<String, dynamic>.from(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to update position');
  }

  // POST /api/feeds/me/regenerate
  Future<Map<String, dynamic>> regenerate() async {
    final res = await _client.post('/api/feeds/me/regenerate');
    final data = _client.decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300 && data['success'] == true) {
      return Map<String, dynamic>.from(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to regenerate feed');
  }

  // DELETE /api/feeds/me
  Future<void> deleteMyFeed() async {
    final res = await _client.delete('/api/feeds/me');
    if (res.statusCode == 204) return;
    final data = _client.decode(res);
    throw Exception(data['message'] ?? 'Failed to delete feed');
  }
}
