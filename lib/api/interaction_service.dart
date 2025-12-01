import 'api_client.dart';
import 'models/article.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/env.dart';

class InteractionService {
  final ApiClient _client;
  static const String _gorseBaseUrl = 'http://mf_recommender.digilabdte.com';
  
  InteractionService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  String _buildGorseUrl(String path) {
    // On web with CORS proxy enabled, route through /gorse/ prefix
    if (kIsWeb && Env.useCorsProxy) {
      return '${Env.corsProxy}/gorse$path';
    }
    return _gorseBaseUrl + path;
  }

  // Local storage keys for dummy data interactions
  static const String _localLikesKey = 'local_likes';
  static const String _localSavesKey = 'local_saves';

  // Check if article is a dummy article
  bool _isDummyArticle(String articleId) => articleId.startsWith('dummy-');

  // Get local interactions
  Future<Set<String>> _getLocalInteractions(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(key) ?? [];
      return Set<String>.from(list);
    } catch (e) {
      return {};
    }
  }

  // Save local interactions
  Future<void> _saveLocalInteractions(String key, Set<String> interactions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(key, interactions.toList());
    } catch (e) {
      if (kDebugMode) {
        print('[InteractionService] Failed to save local interactions: $e');
      }
    }
  }

  // POST /api/articles/:id/like to Gorse recommendation system
  Future<Map<String, dynamic>> createInteraction({required String articleId, required String interactionType, required String userId}) async {
    // Handle dummy articles locally
    if (_isDummyArticle(articleId)) {
      final key = interactionType == 'LIKE' ? _localLikesKey : _localSavesKey;
      final interactions = await _getLocalInteractions(key);
      interactions.add(articleId);
      await _saveLocalInteractions(key, interactions);
      return {'success': true};
    }

    try {
      // For likes, send to Gorse recommendation API
      if (interactionType == 'LIKE') {
        final url = _buildGorseUrl('/api/articles/$articleId/like?userId=$userId');
        if (kDebugMode) {
          print('[InteractionService] Sending like to Gorse: $url');
        }
        
        final res = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 30));
        
        if (res.statusCode >= 200 && res.statusCode < 300) {
          if (kDebugMode) {
            print('[InteractionService] Sent like to Gorse for article $articleId');
          }
          return {'success': true};
        }
        throw Exception('Failed to create like interaction');
      }
      
      // For other types (SAVE, etc.), use the backend API
      final res = await _client.post('/api/interactions', body: {
        'articleId': articleId,
        'interactionType': interactionType,
      });
      final data = _client.decode(res);
      if (res.statusCode >= 200 && res.statusCode < 300 && data['success'] == true) {
        return Map<String, dynamic>.from(data['data']);
      }
      throw Exception(data['message'] ?? 'Failed to create interaction');
    } catch (e) {
      if (kDebugMode) {
        print('[InteractionService] Failed to create interaction, storing locally: $e');
      }
      // Store locally as fallback
      final key = interactionType == 'LIKE' ? _localLikesKey : _localSavesKey;
      final interactions = await _getLocalInteractions(key);
      interactions.add(articleId);
      await _saveLocalInteractions(key, interactions);
      return {'success': true};
    }
  }

  // DELETE /api/interactions (undo interaction)
  Future<bool> deleteInteraction({required String articleId, required String interactionType}) async {
    // Handle dummy articles locally
    if (_isDummyArticle(articleId)) {
      final key = interactionType == 'LIKE' ? _localLikesKey : _localSavesKey;
      final interactions = await _getLocalInteractions(key);
      interactions.remove(articleId);
      await _saveLocalInteractions(key, interactions);
      return true;
    }

    try {
      final res = await _client.delete('/api/interactions', body: {
        'articleId': articleId,
        'interactionType': interactionType,
      });
      if (res.statusCode == 204) return true;
      final data = _client.decode(res);
      throw Exception(data['message'] ?? 'Failed to delete interaction');
    } catch (e) {
      if (kDebugMode) {
        print('[InteractionService] Failed to delete interaction, removing locally: $e');
      }
      // Remove locally as fallback
      final key = interactionType == 'LIKE' ? _localLikesKey : _localSavesKey;
      final interactions = await _getLocalInteractions(key);
      interactions.remove(articleId);
      await _saveLocalInteractions(key, interactions);
      return true;
    }
  }

  // GET /api/interactions/me (list my interactions)
  Future<List<Map<String, dynamic>>> listMyInteractions({String? type}) async {
    try {
      final query = type != null ? {'type': type} : null;
      final res = await _client.get('/api/interactions/me', query: query);
      final data = _client.decode(res);
      if (res.statusCode == 200 && data['success'] == true) {
        // Backend returns array of interactions directly in data field
        final interactions = (data['data'] as List).cast<Map<String, dynamic>>();
        if (kDebugMode) {
          print('[InteractionService] Loaded ${interactions.length} interactions of type $type');
        }
        return interactions;
      }
      throw Exception(data['message'] ?? 'Failed to fetch interactions');
    } catch (e) {
      if (kDebugMode) {
        print('[InteractionService] Failed to fetch interactions: $e');
      }
      return [];
    }
  }

  // GET /api/interactions/check/:articleId (check if I have interacted)
  Future<bool> hasInteraction(String articleId, {required String type}) async {
    // Handle dummy articles locally
    if (_isDummyArticle(articleId)) {
      final key = type == 'LIKE' ? _localLikesKey : _localSavesKey;
      final interactions = await _getLocalInteractions(key);
      return interactions.contains(articleId);
    }

    try {
      final res = await _client.get('/api/interactions/check/$articleId', query: {'type': type});
      final data = _client.decode(res);
      if (res.statusCode == 200 && data['success'] == true) {
        return data['data']['hasInteraction'] == true;
      }
      throw Exception(data['message'] ?? 'Failed to check interaction');
    } catch (e) {
      // Check locally as fallback
      final key = type == 'LIKE' ? _localLikesKey : _localSavesKey;
      final interactions = await _getLocalInteractions(key);
      return interactions.contains(articleId);
    }
  }

  // Helper: Get all liked articles
  Future<List<ArticleModel>> getLikedArticles() async {
    try {
      final interactions = await listMyInteractions(type: 'LIKE');
      return interactions
          .where((i) => i['article'] != null)
          .map((i) => ArticleModel.fromJson(i['article'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch liked articles: $e');
    }
  }

  // Helper: Get all saved articles
  Future<List<ArticleModel>> getSavedArticles() async {
    try {
      final interactions = await listMyInteractions(type: 'SAVE');
      return interactions
          .where((i) => i['article'] != null)
          .map((i) => ArticleModel.fromJson(i['article'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch saved articles: $e');
    }
  }

  // Helper: Toggle like on an article
  Future<bool> toggleLike(String articleId, String userId, bool currentlyLiked) async {
    if (currentlyLiked) {
      await deleteInteraction(articleId: articleId, interactionType: 'LIKE');
      return false;
    } else {
      await createInteraction(articleId: articleId, interactionType: 'LIKE', userId: userId);
      return true;
    }
  }

  // Helper: Toggle save on an article
  Future<bool> toggleSave(String articleId, String userId, bool currentlySaved) async {
    if (currentlySaved) {
      await deleteInteraction(articleId: articleId, interactionType: 'SAVE');
      return false;
    } else {
      await createInteraction(articleId: articleId, interactionType: 'SAVE', userId: userId);
      return true;
    }
  }
}

