import 'package:flutter/foundation.dart';
import '../api/models/user.dart';
import '../api/api_client.dart';

class AuthState extends ChangeNotifier {
  UserModel? _user;
  String? _token;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<void> loadToken() async {
    await ApiClient.instance.loadToken();
    _token = ApiClient.instance.token;
    notifyListeners();
  }

  Future<void> setSession(
      {required String token, required UserModel user}) async {
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

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }
}
