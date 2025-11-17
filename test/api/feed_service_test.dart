import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:wikiscrolls_frontend/api/feed_service.dart';
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
    return http.Response(jsonEncode(_responses['post'] ?? {}), _responses['statusCode'] ?? 200);
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
  group('FeedService', () {
    late MockApiClient mockClient;
    late FeedService feedService;

    setUp(() {
      mockClient = MockApiClient();
      feedService = FeedService(client: mockClient);
    });

    group('getMyFeed', () {
      test('successful fetch returns feed data with pagination', () async {
        mockClient.setResponse('get', {
          'success': true,
          'data': {
            'articles': [
              {'id': 'article1', 'title': 'Article 1'},
              {'id': 'article2', 'title': 'Article 2'},
            ],
            'page': 1,
            'limit': 10,
          }
        });
        mockClient.setResponse('statusCode', 200);

        final feed = await feedService.getMyFeed(page: 1, limit: 10);

        expect(feed['articles'], isNotNull);
        expect(feed['page'], 1);
        expect(feed['limit'], 10);
      });

      test('failed fetch throws exception', () async {
        mockClient.setResponse('get', {
          'success': false,
          'message': 'Feed not found',
        });
        mockClient.setResponse('statusCode', 404);

        expect(() => feedService.getMyFeed(), throwsException);
      });
    });

    group('createMyFeed', () {
      test('successful creation returns feed data', () async {
        mockClient.setResponse('post', {
          'success': true,
          'data': {'id': 'feed1', 'preferences': ['tech', 'science']}
        });
        mockClient.setResponse('statusCode', 201);

        final result = await feedService.createMyFeed({'preferences': ['tech', 'science']});

        expect(result['id'], 'feed1');
        expect(result['preferences'], ['tech', 'science']);
      });
    });

    group('updateMyFeed', () {
      test('successful update returns updated data', () async {
        mockClient.setResponse('put', {
          'success': true,
          'data': {'preferences': ['history']}
        });
        mockClient.setResponse('statusCode', 200);

        final result = await feedService.updateMyFeed({'preferences': ['history']});

        expect(result['preferences'], ['history']);
      });
    });

    group('updatePosition', () {
      test('successful position update', () async {
        mockClient.setResponse('put', {
          'success': true,
          'data': {'position': 5}
        });
        mockClient.setResponse('statusCode', 200);

        final result = await feedService.updatePosition({'articleId': 'article5', 'position': 5});

        expect(result['position'], 5);
      });
    });

    group('regenerate', () {
      test('successful regeneration returns new feed', () async {
        mockClient.setResponse('post', {
          'success': true,
          'data': {'regenerated': true}
        });
        mockClient.setResponse('statusCode', 200);

        final result = await feedService.regenerate();

        expect(result['regenerated'], true);
      });
    });

    group('deleteMyFeed', () {
      test('successful deletion with 204 status', () async {
        mockClient.setResponse('statusCode', 204);

        await feedService.deleteMyFeed();

        expect(mockClient.deleteCallCount, 1);
      });

      test('failed deletion throws exception', () async {
        mockClient.setResponse('delete', {
          'message': 'Cannot delete feed',
        });
        mockClient.setResponse('statusCode', 400);

        expect(() => feedService.deleteMyFeed(), throwsException);
      });
    });
  });
}
