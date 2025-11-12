import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/env.dart';

class ApiClient {
  static final String defaultBaseUrl = Env.apiBaseUrl; // configurable via --dart-define

  String baseUrl;
  String? _token;

  ApiClient({String? baseUrl, String? token}) : baseUrl = baseUrl ?? defaultBaseUrl {
    _token = token;
  }

  static final ApiClient instance = ApiClient();

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('authToken');
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
  }

  Map<String, String> _headers({Map<String, String>? extra}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    // If web proxy flag is on, swap baseUrl to proxy (still keep original for logs if needed)
  final effectiveBase = (Env.useCorsProxy && kIsWeb) ? Env.corsProxy : baseUrl;
    final normalized = effectiveBase.endsWith('/') ? effectiveBase.substring(0, effectiveBase.length - 1) : effectiveBase;
    final joined = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalized$joined').replace(queryParameters: query?.map((k, v) => MapEntry(k, '$v')));
  }

  // no extra helpers

  Future<http.Response> get(String path, {Map<String, dynamic>? query}) async {
    final res = await http.get(_uri(path, query), headers: _headers());
    return res;
  }

  Future<http.Response> post(String path, {Object? body, Map<String, dynamic>? query}) async {
    final res = await http.post(_uri(path, query), headers: _headers(), body: jsonEncode(body));
    return res;
  }

  Future<http.Response> put(String path, {Object? body}) async {
    final res = await http.put(_uri(path), headers: _headers(), body: jsonEncode(body));
    return res;
  }

  Future<http.Response> delete(String path, {Object? body}) async {
    final res = await http.delete(_uri(path), headers: _headers(), body: body == null ? null : jsonEncode(body));
    return res;
  }

  dynamic decode(http.Response res) {
    final data = jsonDecode(res.body);
    return data;
  }
}
