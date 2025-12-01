import 'package:flutter/foundation.dart';
import '../api/models/user.dart';
import '../api/api_client.dart';
import '../api/auth_service.dart';

class AuthState extends ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isLoading = false;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  bool get isLoading => _isLoading;

  Future<void> loadToken() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await ApiClient.instance.loadToken();
      _token = ApiClient.instance.token;
      
      // If we have a token, try to fetch user profile
      if (_token != null && _token!.isNotEmpty) {
        try {
          final authService = AuthService();
          final userData = await authService.getMyProfile();
          _user = UserModel.fromJson(userData);
          if (kDebugMode) {
            print('[AuthState] Successfully loaded profile for ${_user?.username}');
          }
        } catch (e) {
          // Only clear token if it's an auth error (401/403)
          // Network errors or server issues shouldn't log user out
          if (kDebugMode) {
            print('[AuthState] Failed to fetch profile with saved token: $e');
          }
          final errorStr = e.toString().toLowerCase();
          if (errorStr.contains('401') || errorStr.contains('403') || errorStr.contains('unauthorized')) {
            if (kDebugMode) {
              print('[AuthState] Token invalid, clearing session');
            }
            await clear();
          } else {
            if (kDebugMode) {
              print('[AuthState] Keeping token, error might be temporary');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AuthState] Error loading token: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setSession({required String token, required UserModel user}) async {
    _token = token;
    _user = user;
    await ApiClient.instance.saveToken(token);
    notifyListeners();
  }

  Future<void> clear() async {
    _token = null;
    _user = null;
    await ApiClient.instance.clearToken();
    notifyListeners();
  }
}
