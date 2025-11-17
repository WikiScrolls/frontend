import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wikiscrolls_frontend/api/auth_service.dart';
import 'package:wikiscrolls_frontend/api/api_client.dart';
import 'dart:convert';

class MockApiClient extends Fake implements ApiClient {
  final Map<String, dynamic> _responses = {};
  final List<String> _savedTokens = [];
  
  void setResponse(String key, dynamic value) {
    _responses[key] = value;
  }
  
  @override
  Future<http.Response> post(String path, {Object? body, Map<String, dynamic>? query}) async {
    return http.Response(jsonEncode(_responses['post'] ?? {}), _responses['statusCode'] ?? 200);
  }
  
  @override
  Future<http.Response> get(String path, {Map<String, dynamic>? query}) async {
    return http.Response(jsonEncode(_responses['get'] ?? {}), _responses['statusCode'] ?? 200);
  }
  
  @override
  dynamic decode(http.Response res) {
    return jsonDecode(res.body);
  }
  
  @override
  Future<void> saveToken(String token) async {
    _savedTokens.add(token);
  }
  
  @override
  Future<void> clearToken() async {
    _savedTokens.clear();
  }
  
  bool wasTokenSaved(String token) => _savedTokens.contains(token);
  bool wasTokenCleared() => _savedTokens.isEmpty;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService', () {
    late MockApiClient mockClient;
    late AuthService authService;

    setUp(() {
      mockClient = MockApiClient();
      authService = AuthService(client: mockClient);
      SharedPreferences.setMockInitialValues({});
    });

    group('login', () {
      test('successful login returns token and user', () async {
        mockClient.setResponse('post', {
          'success': true,
          'data': {
            'token': 'test-token-123',
            'user': {
              'id': 'user1',
              'username': 'testuser',
              'email': 'test@example.com',
              'isAdmin': false,
            }
          }
        });
        mockClient.setResponse('statusCode', 200);

        final result = await authService.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result.$1, 'test-token-123');
        expect(result.$2['username'], 'testuser');
        expect(result.$2['email'], 'test@example.com');
        expect(mockClient.wasTokenSaved('test-token-123'), true);
      });

      test('failed login throws exception with error message', () async {
        mockClient.setResponse('post', {
          'success': false,
          'message': 'Invalid credentials',
        });
        mockClient.setResponse('statusCode', 401);

        expect(
          () => authService.login(
            email: 'wrong@example.com',
            password: 'wrongpass',
          ),
          throwsException,
        );
      });

      test('login with validation errors shows error messages', () async {
        mockClient.setResponse('post', {
          'success': false,
          'errors': [
            {'message': 'Email is required'},
            {'message': 'Password is too short'},
          ]
        });
        mockClient.setResponse('statusCode', 400);

        expect(
          () => authService.login(email: '', password: ''),
          throwsException,
        );
      });
    });

    group('signup', () {
      test('successful signup returns token and user', () async {
        mockClient.setResponse('post', {
          'success': true,
          'data': {
            'token': 'new-token-456',
            'user': {
              'id': 'user2',
              'username': 'newuser',
              'email': 'new@example.com',
              'isAdmin': false,
            }
          }
        });
        mockClient.setResponse('statusCode', 201);

        final result = await authService.signup(
          username: 'newuser',
          email: 'new@example.com',
          password: 'password123',
        );

        expect(result.$1, 'new-token-456');
        expect(result.$2['username'], 'newuser');
        expect(mockClient.wasTokenSaved('new-token-456'), true);
      });

      test('signup with duplicate email throws exception', () async {
        mockClient.setResponse('post', {
          'success': false,
          'errors': [
            {'message': 'Email already exists'}
          ]
        });
        mockClient.setResponse('statusCode', 400);

        expect(
          () => authService.signup(
            username: 'testuser',
            email: 'existing@example.com',
            password: 'password123',
          ),
          throwsException,
        );
      });
    });

    group('getMyProfile', () {
      test('successful profile fetch returns user data', () async {
        mockClient.setResponse('get', {
          'success': true,
          'data': {
            'id': 'user1',
            'username': 'testuser',
            'email': 'test@example.com',
          }
        });
        mockClient.setResponse('statusCode', 200);

        final profile = await authService.getMyProfile();

        expect(profile['username'], 'testuser');
        expect(profile['email'], 'test@example.com');
      });

      test('unauthorized profile fetch throws exception', () async {
        mockClient.setResponse('get', {
          'success': false,
          'message': 'Unauthorized',
        });
        mockClient.setResponse('statusCode', 401);

        expect(() => authService.getMyProfile(), throwsException);
      });
    });

    group('logout', () {
      test('logout clears token', () async {
        mockClient._savedTokens.add('test-token');
        
        await authService.logout();

        expect(mockClient.wasTokenCleared(), true);
      });
    });
  });
}
