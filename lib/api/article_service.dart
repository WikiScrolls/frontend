import 'dart:convert';
import 'models/article.dart';
import 'models/pagination.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/env.dart';

class ArticleService {
  static const String _gorseBaseUrl = 'http://mf_recommender.digilabdte.com';
  
  ArticleService();

  String _buildGorseUrl(String path) {
    // On web with CORS proxy enabled, route through /gorse/ prefix
    if (kIsWeb && Env.useCorsProxy) {
      return '${Env.corsProxy}/gorse$path';
    }
    return _gorseBaseUrl + path;
  }

  // Get personalized recommendations from Gorse
  Future<(List<ArticleModel> articles, PaginationInfo? pagination)> listArticles({String? userId, int limit = 10}) async {
    try {
      // If userId is provided, get personalized recommendations
      // Otherwise get random articles
      final path = userId != null 
        ? '/api/recommendation/$userId'
        : '/api/recommendation/random?count=$limit';
      
      final endpoint = _buildGorseUrl(path);
      
      if (kDebugMode) {
        print('[ArticleService] Requesting from Gorse: $endpoint');
      }
      
      final http.Response res = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        // Gorse returns {data: [...]} format
        final rawArticles = data is List ? data : (data['data'] as List? ?? []);
        final articles = rawArticles.map((e) => ArticleModel.fromJson(e as Map<String, dynamic>)).toList();
        if (kDebugMode) {
          print('[ArticleService] Successfully loaded ${articles.length} articles from Gorse');
        }
        return (articles, null);
      }
      
      // Handle rate limiting or other errors
      if (res.statusCode == 429) {
        throw Exception('Too many requests. Please wait a moment and try again.');
      }
      
      throw Exception('Failed to fetch articles: ${res.statusCode} - ${res.body}');
    } catch (e) {
      if (kDebugMode) {
        print('[ArticleService] Error fetching articles: $e');
      }
      rethrow;
    }
  }

  // POST /api/articles/:id/open to record a view in Gorse
  Future<bool> recordView(String articleId, String userId) async {
    try {
      final url = _buildGorseUrl('/api/articles/$articleId/open?userId=$userId');
      if (kDebugMode) {
        print('[ArticleService] Recording view to Gorse: $url');
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
          print('[ArticleService] Recorded view for article $articleId');
        }
        return true;
      }
      throw Exception('Failed to record view');
    } catch (e) {
      if (kDebugMode) {
        print('[ArticleService] Failed to record view: $e');
      }
      return false;
    }
  }

  // Retry loading articles
  Future<(List<ArticleModel> articles, PaginationInfo? pagination)> retryLoadArticles({String? userId, int limit = 10}) async {
    return listArticles(userId: userId, limit: limit);
  }
}
