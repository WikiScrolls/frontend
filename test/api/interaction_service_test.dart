import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:wikiscrolls_frontend/api/interaction_service.dart';
import 'package:wikiscrolls_frontend/api/api_client.dart';
import 'dart:convert';

class MockApiClient extends Fake implements ApiClient {
  final Map<String, dynamic> _responses = {};
  
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
  Future<http.Response> delete(String path, {Object? body}) async {
    return http.Response('', _responses['statusCode'] ?? 204);
  }
  
  @override
  dynamic decode(http.Response res) {
    return jsonDecode(res.body);
  }
}

void main() {
  group('InteractionService', () {
    late MockApiClient mockClient;
    late InteractionService interactionService;

    setUp(() {
      mockClient = MockApiClient();
      interactionService = InteractionService(client: mockClient);
    });

    group('createInteraction', () {
      test('successful interaction creation returns data', () async {
        mockClient.setResponse('post', {
          'success': true,
          'data': {
            'articleId': 'article123',
            'interactionType': 'like',
          }
        });
        mockClient.setResponse('statusCode', 201);

        final result = await interactionService.createInteraction(
          articleId: 'article123',
          interactionType: 'like',
        );

        expect(result['articleId'], 'article123');
        expect(result['interactionType'], 'like');
      });

      test('failed interaction creation throws exception', () async {
        mockClient.setResponse('post', {
          'success': false,
          'message': 'Already liked',
        });
        mockClient.setResponse('statusCode', 400);

        expect(
          () => interactionService.createInteraction(
            articleId: 'article123',
            interactionType: 'like',
          ),
          throwsException,
        );
      });
    });

    group('deleteInteraction', () {
      test('successful deletion returns true', () async {
        mockClient.setResponse('statusCode', 204);

        final result = await interactionService.deleteInteraction(
          articleId: 'article123',
          interactionType: 'like',
        );

        expect(result, true);
      });

      test('failed deletion throws exception', () async {
        mockClient.setResponse('delete', {
          'message': 'Interaction not found',
        });
        mockClient.setResponse('statusCode', 400);

        expect(
          () => interactionService.deleteInteraction(
            articleId: 'article123',
            interactionType: 'like',
          ),
          throwsException,
        );
      });
    });

    group('listMyInteractions', () {
      test('successful fetch returns interaction list', () async {
        mockClient.setResponse('get', {
          'success': true,
          'data': {
            'interactions': [
              {'articleId': 'article1', 'type': 'like'},
              {'articleId': 'article2', 'type': 'bookmark'},
            ]
          }
        });
        mockClient.setResponse('statusCode', 200);

        final interactions = await interactionService.listMyInteractions();

        expect(interactions.length, 2);
        expect(interactions[0]['articleId'], 'article1');
      });

      test('empty interaction list returns empty array', () async {
        mockClient.setResponse('get', {
          'success': true,
          'data': {'interactions': []}
        });
        mockClient.setResponse('statusCode', 200);

        final interactions = await interactionService.listMyInteractions();

        expect(interactions, isEmpty);
      });
    });

    group('hasInteraction', () {
      test('returns true when interaction exists', () async {
        mockClient.setResponse('get', {
          'success': true,
          'data': {'interacted': true}
        });
        mockClient.setResponse('statusCode', 200);

        final hasInteracted = await interactionService.hasInteraction('article123');

        expect(hasInteracted, true);
      });

      test('returns false when interaction does not exist', () async {
        mockClient.setResponse('get', {
          'success': true,
          'data': {'interacted': false}
        });
        mockClient.setResponse('statusCode', 200);

        final hasInteracted = await interactionService.hasInteraction('article456');

        expect(hasInteracted, false);
      });
    });
  });
}
