import 'package:http/http.dart' as http;
import 'api_client.dart';

class AuthService {
  final ApiClient _client;
  AuthService({ApiClient? client}) : _client = client ?? ApiClient.instance;

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
      await _client.saveToken(token);
      return (token, Map<String, dynamic>.from(data['data']['user']));
    }
    if (data is Map && data['errors'] is List) {
      final msgs = (data['errors'] as List).whereType<Map>().map((e) => e['message']).whereType<String>().toList();
      if (msgs.isNotEmpty) {
        throw Exception(msgs.join('\n'));
      }
    }
    throw Exception(data['message'] ?? 'Signup failed (${res.statusCode})');
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
