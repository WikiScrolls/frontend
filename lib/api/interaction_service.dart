import 'api_client.dart';

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

  // GET /api/interactions/check/:articleId (check if I have interacted)
  Future<bool> hasInteraction(String articleId) async {
    final res = await _client.get('/api/interactions/check/$articleId');
    final data = _client.decode(res);
    if (res.statusCode == 200 && data['success'] == true) {
      // Expecting data like { interacted: true/false }
      return data['data']['interacted'] == true;
    }
    throw Exception(data['message'] ?? 'Failed to check interaction');
  }
}
