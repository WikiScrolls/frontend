import 'package:flutter_test/flutter_test.dart';
import 'package:wikiscrolls_frontend/api/models/article.dart';

void main() {
  group('ArticleModel', () {
    test('fromJson creates ArticleModel with all fields', () {
      final json = {
        'id': '123',
        'title': 'Test Article',
        'content': 'Test content',
        'likeCount': 42,
        'createdAt': '2024-01-15T10:30:00.000Z',
      };

      final article = ArticleModel.fromJson(json);

      expect(article.id, '123');
      expect(article.title, 'Test Article');
      expect(article.content, 'Test content');
      expect(article.likeCount, 42);
      expect(article.createdAt, isNotNull);
      expect(article.createdAt!.year, 2024);
      expect(article.createdAt!.month, 1);
      expect(article.createdAt!.day, 15);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': '456',
        'title': 'Minimal Article',
      };

      final article = ArticleModel.fromJson(json);

      expect(article.id, '456');
      expect(article.title, 'Minimal Article');
      expect(article.content, isNull);
      expect(article.likeCount, 0);
      expect(article.createdAt, isNull);
    });

    test('fromJson uses body field as fallback for content', () {
      final json = {
        'id': '789',
        'title': 'Article with body',
        'body': 'Body content',
      };

      final article = ArticleModel.fromJson(json);

      expect(article.content, 'Body content');
    });

    test('fromJson handles numeric id correctly', () {
      final json = {
        'id': 999,
        'title': 'Numeric ID Article',
      };

      final article = ArticleModel.fromJson(json);

      expect(article.id, '999');
    });

    test('fromJson handles invalid date gracefully', () {
      final json = {
        'id': '111',
        'title': 'Invalid Date Article',
        'createdAt': 'not-a-date',
      };

      final article = ArticleModel.fromJson(json);

      expect(article.createdAt, isNull);
    });

    test('toJson converts ArticleModel to JSON', () {
      final article = ArticleModel(
        id: '123',
        title: 'Test Article',
        content: 'Test content',
        likeCount: 42,
        createdAt: DateTime(2024, 1, 15, 10, 30),
      );

      final json = article.toJson();

      expect(json['id'], '123');
      expect(json['title'], 'Test Article');
      expect(json['content'], 'Test content');
      expect(json['likeCount'], 42);
      expect(json['createdAt'], isNotNull);
    });

    test('toJson handles null values', () {
      final article = ArticleModel(
        id: '123',
        title: 'Test Article',
      );

      final json = article.toJson();

      expect(json['content'], isNull);
      expect(json['createdAt'], isNull);
    });

    test('round-trip serialization preserves data', () {
      final original = ArticleModel(
        id: '555',
        title: 'Round Trip Test',
        content: 'Content here',
        likeCount: 100,
        createdAt: DateTime(2024, 6, 1),
      );

      final json = original.toJson();
      final restored = ArticleModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.content, original.content);
      expect(restored.likeCount, original.likeCount);
      expect(restored.createdAt, original.createdAt);
    });
  });
}
