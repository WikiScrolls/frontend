import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/env.dart';

class ApiClient {
  static final String defaultBaseUrl = Env.apiBaseUrl; // configurable via --dart-define

  String baseUrl;
  String? _token;
  late http.Client _httpClient;
  
  // HTTP timeout duration
  static const Duration _timeout = Duration(seconds: 30);

  ApiClient({String? baseUrl, String? token}) : baseUrl = baseUrl ?? defaultBaseUrl {
    _token = token;
    _httpClient = _createHttpClient();
    if (kDebugMode) {
      print('[ApiClient] Initialized with baseUrl: $baseUrl');
    }
  }

  static final ApiClient instance = ApiClient();

  // Create HTTP client with custom certificate handling for development
  http.Client _createHttpClient() {
    if (kIsWeb) {
      return http.Client();
    }
    
    final ioClient = HttpClient();
    
    // In development mode, allow self-signed certificates
    // This helps with Android emulator SSL issues
    if (kDebugMode) {
      ioClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
        if (kDebugMode) {
          print('[ApiClient] Accepting certificate for $host:$port');
        }
        return true; // Accept all certificates in debug mode
      };
    }
    
    return IOClient(ioClient);
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('authToken');
    if (kDebugMode && _token != null) {
      print('[ApiClient] Token loaded from SharedPreferences');
    }
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    if (kDebugMode) {
      print('[ApiClient] Token saved to SharedPreferences');
    }
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    if (kDebugMode) {
      print('[ApiClient] Token cleared from SharedPreferences');
    }
  }

  // Expose current token for read-only access
  String? get token => _token;

  Map<String, String> _headers({Map<String, String>? extra}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
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
    final uri = Uri.parse('$normalized$joined').replace(queryParameters: query?.map((k, v) => MapEntry(k, '$v')));
    if (kDebugMode) {
      print('[ApiClient] useCorsProxy: ${Env.useCorsProxy}, kIsWeb: $kIsWeb, effectiveBase: $effectiveBase');
      print('[ApiClient] Request URI: $uri');
    }
    return uri;
  }

  Future<http.Response> _handleRequest(Future<http.Response> Function() request, String method, String path) async {
    try {
      if (kDebugMode) {
        print('[ApiClient] $method $path');
      }
      final response = await request().timeout(_timeout);
      if (kDebugMode) {
        print('[ApiClient] Response: ${response.statusCode} ${response.reasonPhrase}');
        if (response.statusCode >= 400) {
          print('[ApiClient] Error body: ${response.body}');
        }
      }
      return response;
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('[ApiClient] SocketException: $e');
      }
      throw Exception('Network error: Unable to connect to server. Please check your internet connection.');
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('[ApiClient] TimeoutException: $e');
      }
      throw Exception('Network error: Request timed out. Please try again.');
    } on HttpException catch (e) {
      if (kDebugMode) {
        print('[ApiClient] HttpException: $e');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('[ApiClient] Unexpected error: $e');
      }
      throw Exception('Network error: $e');
    }
  }

  // no extra helpers

  Future<http.Response> get(String path, {Map<String, dynamic>? query}) async {
    return _handleRequest(
      () => _httpClient.get(_uri(path, query), headers: _headers()),
      'GET',
      path,
    );
  }


  Future<http.Response> post(String path, {Object? body, Map<String, dynamic>? query}) async {
    return _handleRequest(
      () => _httpClient.post(_uri(path, query), headers: _headers(), body: jsonEncode(body)),
      'POST',
      path,
    );
  }

  Future<http.Response> put(String path, {Object? body}) async {
    return _handleRequest(
      () => _httpClient.put(_uri(path), headers: _headers(), body: jsonEncode(body)),
      'PUT',
      path,
    );
  }

  Future<http.Response> delete(String path, {Object? body}) async {
    return _handleRequest(
      () => _httpClient.delete(_uri(path), headers: _headers(), body: body == null ? null : jsonEncode(body)),
      'DELETE',
      path,
    );
  }

  dynamic decode(http.Response res) {
    final data = jsonDecode(res.body);
    return data;
  }
}
