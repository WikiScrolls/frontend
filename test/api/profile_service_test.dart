import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:wikiscrolls_frontend/api/profile_service.dart';
import 'package:wikiscrolls_frontend/api/api_client.dart';
import 'dart:convert';

class MockApiClient extends Fake implements ApiClient {
  final Map<String, dynamic> _responses = {};
  int _deleteCallCount = 0;
  
  void setResponse(String key, dynamic value) {
    _responses[key] = value;
  }
  
  @override
  Future<http.Response> get(String path, {Map<String, dynamic>? query}) async {
    return http.Response(jsonEncode(_responses['get'] ?? {}), _responses['statusCode'] ?? 200);
  }
  
  @override
  Future<http.Response> post(String path, {Object? body, Map<String, dynamic>? query}) async {
    return http.Response(jsonEncode(_responses['post'] ?? {}), _responses['statusCode'] ?? 201);
  }
  
  @override
  Future<http.Response> put(String path, {Object? body}) async {
    return http.Response(jsonEncode(_responses['put'] ?? {}), _responses['statusCode'] ?? 200);
  }
  
  @override
  Future<http.Response> delete(String path, {Object? body}) async {
    _deleteCallCount++;
    return http.Response('', _responses['statusCode'] ?? 204);
  }
  
  @override
  dynamic decode(http.Response res) {
    return jsonDecode(res.body);
  }
  
  int get deleteCallCount => _deleteCallCount;
}

void main() {
  group('ProfileService', () {
    late MockApiClient mockClient;
    late ProfileService profileService;

    setUp(() {
      mockClient = MockApiClient();
      profileService = ProfileService(client: mockClient);
    });

    group('getMyProfileRaw', () {
      test('successful fetch returns profile data', () async {
        mockClient.setResponse('get', {
          'success': true,
          'data': {
            'user': {
              'id': 'user1',
              'username': 'profileuser',
              'email': 'profile@example.com',
            }
          }
        });
        mockClient.setResponse('statusCode', 200);

        final profile = await profileService.getMyProfileRaw();

        expect(profile['user'], isNotNull);
        expect(profile['user']['username'], 'profileuser');
      });

      test('failed fetch throws exception', () async {
        mockClient.setResponse('get', {
          'success': false,
          'message': 'Profile not found',
        });
        mockClient.setResponse('statusCode', 404);

        expect(() => profileService.getMyProfileRaw(), throwsException);
      });
    });

    group('getMyProfile', () {
      test('returns UserModel from profile data', () async {
        mockClient.setResponse('get', {
          'success': true,
          'data': {
            'user': {
              'id': 'user1',
              'username': 'modeluser',
              'email': 'model@example.com',
              'isAdmin': false,
            }
          }
        });
        mockClient.setResponse('statusCode', 200);

        final user = await profileService.getMyProfile();

        expect(user.username, 'modeluser');
        expect(user.email, 'model@example.com');
        expect(user.isAdmin, false);
      });
    });

    group('createOrInitProfile', () {
      test('successful creation returns profile data', () async {
        mockClient.setResponse('post', {
          'success': true,
          'data': {
            'bio': 'Test bio',
            'interests': ['tech', 'science']
          }
        });
        mockClient.setResponse('statusCode', 201);

        final result = await profileService.createOrInitProfile({
          'bio': 'Test bio',
          'interests': ['tech', 'science']
        });

        expect(result['bio'], 'Test bio');
        expect(result['interests'], ['tech', 'science']);
      });
    });

    group('updateProfile', () {
      test('successful update returns updated data', () async {
        mockClient.setResponse('put', {
          'success': true,
          'data': {'bio': 'Updated bio'}
        });
        mockClient.setResponse('statusCode', 200);

        final result = await profileService.updateProfile({'bio': 'Updated bio'});

        expect(result['bio'], 'Updated bio');
      });

      test('failed update throws exception', () async {
        mockClient.setResponse('put', {
          'success': false,
          'message': 'Invalid data',
        });
        mockClient.setResponse('statusCode', 400);

        expect(
          () => profileService.updateProfile({'invalid': 'data'}),
          throwsException,
        );
      });
    });

    group('deleteProfile', () {
      test('successful deletion with 204 status', () async {
        mockClient.setResponse('statusCode', 204);

        await profileService.deleteProfile();

        expect(mockClient.deleteCallCount, 1);
      });

      test('failed deletion throws exception', () async {
        mockClient.setResponse('delete', {
          'message': 'Cannot delete profile',
        });
        mockClient.setResponse('statusCode', 400);

        expect(() => profileService.deleteProfile(), throwsException);
      });
    });
  });
}
