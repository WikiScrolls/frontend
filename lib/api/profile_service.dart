import 'api_client.dart';
import 'package:http/http.dart' as http;
import 'models/user.dart';
import 'models/user_stats.dart';
import 'models/public_profile.dart';

class ProfileService {
  final ApiClient _client;
  ProfileService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  // GET /api/profiles/me (protected)
  Future<Map<String, dynamic>> getMyProfileRaw() async {
    final http.Response res = await _client.get('/api/profiles/me');
    final data = _client.decode(res);
    if (res.statusCode == 200 && data['success'] == true) {
      return Map<String, dynamic>.from(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to fetch profile');
  }

  Future<UserModel> getMyProfile() async {
    final raw = await getMyProfileRaw();
    return UserModel.fromJson(raw['user'] ?? raw);
  }

  // POST /api/profiles/me (create or initial setup) - semantics depends on backend
  Future<Map<String, dynamic>> createOrInitProfile(Map<String, dynamic> body) async {
    final res = await _client.post('/api/profiles/me', body: body);
    final data = _client.decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300 && data['success'] == true) {
      return Map<String, dynamic>.from(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to create profile');
  }

  // PUT /api/profiles/me (update)
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async {
    final res = await _client.put('/api/profiles/me', body: body);
    final data = _client.decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300 && data['success'] == true) {
      return Map<String, dynamic>.from(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to update profile');
  }

  // DELETE /api/profiles/me
  Future<void> deleteProfile() async {
    final res = await _client.delete('/api/profiles/me');
    if (res.statusCode == 204) return;
    final data = _client.decode(res);
    throw Exception(data['message'] ?? 'Failed to delete profile');
  }

  /// GET /api/profiles/me/stats
  /// Returns user statistics (totalLikes, totalSaves, totalViews, etc.)
  Future<UserStats> getMyStats() async {
    final res = await _client.get('/api/profiles/me/stats');
    final data = _client.decode(res);
    if (res.statusCode == 200 && data['success'] == true) {
      return UserStats.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to fetch stats');
  }

  /// GET /api/profiles/public/:userId
  /// Returns public profile of any user
  Future<PublicProfile> getPublicProfile(String userId) async {
    final res = await _client.get('/api/profiles/public/$userId');
    final data = _client.decode(res);
    if (res.statusCode == 200 && data['success'] == true) {
      return PublicProfile.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to fetch public profile');
  }
}
