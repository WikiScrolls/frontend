import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'api_client.dart';
import '../config/env.dart';

class AuthService {
  final ApiClient _client;
  static const String _gorseBaseUrl = 'http://mf_recommender.digilabdte.com';
  
  AuthService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  String _buildGorseUrl(String path) {
    // On web with CORS proxy enabled, route through /gorse/ prefix
    if (kIsWeb && Env.useCorsProxy) {
      return '${Env.corsProxy}/gorse$path';
    }
    return _gorseBaseUrl + path;
  }

  Future<(String token, Map<String, dynamic> user)> login({required String email, required String password}) async {
    final http.Response res = await _client.post('/api/auth/login', body: {
      'email': email,
      'password': password,
    });
    final data = _client.decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300 && data['success'] == true) {
      final token = data['data']['token'] as String;
      await _client.saveToken(token);
      return (token, Map<String, dynamic>.from(data['data']['user']));
    }
    if (data is Map && data['errors'] is List) {
      final msgs = (data['errors'] as List).whereType<Map>().map((e) => e['message']).whereType<String>().toList();
      if (msgs.isNotEmpty) {
        throw Exception(msgs.join('\n'));
      }
    }
    throw Exception(data['message'] ?? 'Login failed (${res.statusCode})');
  }

  Future<(String token, Map<String, dynamic> user)> signup({required String username, required String email, required String password}) async {
    final res = await _client.post('/api/auth/signup', body: {
      'username': username,
      'email': email,
      'password': password,
    });
    final data = _client.decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300 && data['success'] == true) {
      final token = data['data']['token'] as String;
      final user = Map<String, dynamic>.from(data['data']['user']);
      await _client.saveToken(token);
      
      // Register user to Gorse recommendation system
      try {
        await _registerUserToGorse(user['id'] as String, user['username'] as String);
      } catch (e) {
        // Log but don't fail signup if Gorse registration fails
        print('[AuthService] Failed to register user to Gorse: $e');
      }
      
      return (token, user);
    }
    if (data is Map && data['errors'] is List) {
      final msgs = (data['errors'] as List).whereType<Map>().map((e) => e['message']).whereType<String>().toList();
      if (msgs.isNotEmpty) {
        throw Exception(msgs.join('\n'));
      }
    }
    throw Exception(data['message'] ?? 'Signup failed (${res.statusCode})');
  }

  // Register user to Gorse recommendation system
  Future<void> _registerUserToGorse(String userId, String username) async {
    try {
      final url = _buildGorseUrl('/api/user/');
      final res = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: '{"id": "$userId", "interests": []}',
      ).timeout(const Duration(seconds: 30));
      
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('HTTP ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to register user to Gorse: $e');
    }
  }

  Future<Map<String, dynamic>> getMyProfile() async {
    final res = await _client.get('/api/auth/profile');
    final data = _client.decode(res);
    if (res.statusCode == 200 && data['success'] == true) {
      return Map<String, dynamic>.from(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to get profile');
  }

  Future<void> logout() async {
    await _client.clearToken();
  }
}
