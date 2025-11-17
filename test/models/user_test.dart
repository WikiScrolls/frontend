import 'package:flutter_test/flutter_test.dart';
import 'package:wikiscrolls_frontend/api/models/user.dart';

void main() {
  group('UserModel', () {
    test('fromJson creates UserModel with all fields', () {
      final json = {
        'id': 'user123',
        'username': 'testuser',
        'email': 'test@example.com',
        'isAdmin': true,
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'user123');
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
      expect(user.isAdmin, true);
    });

    test('fromJson uses name as fallback for username', () {
      final json = {
        'id': 'user456',
        'name': 'fallbackuser',
        'email': 'fallback@example.com',
      };

      final user = UserModel.fromJson(json);

      expect(user.username, 'fallbackuser');
    });

    test('fromJson defaults isAdmin to false when missing', () {
      final json = {
        'id': 'user789',
        'username': 'regularuser',
        'email': 'regular@example.com',
      };

      final user = UserModel.fromJson(json);

      expect(user.isAdmin, false);
    });

    test('fromJson handles numeric id', () {
      final json = {
        'id': 123,
        'username': 'numericuser',
        'email': 'numeric@example.com',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, '123');
    });

    test('fromJson handles empty strings gracefully', () {
      final json = {
        'id': '',
        'username': '',
        'email': '',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, '');
      expect(user.username, '');
      expect(user.email, '');
    });

    test('toJson converts UserModel to JSON', () {
      final user = UserModel(
        id: 'user123',
        username: 'testuser',
        email: 'test@example.com',
        isAdmin: true,
      );

      final json = user.toJson();

      expect(json['id'], 'user123');
      expect(json['username'], 'testuser');
      expect(json['email'], 'test@example.com');
      expect(json['isAdmin'], true);
    });

    test('round-trip serialization preserves data', () {
      final original = UserModel(
        id: 'user999',
        username: 'roundtripuser',
        email: 'roundtrip@example.com',
        isAdmin: false,
      );

      final json = original.toJson();
      final restored = UserModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.username, original.username);
      expect(restored.email, original.email);
      expect(restored.isAdmin, original.isAdmin);
    });

    test('const constructor creates immutable UserModel', () {
      const user1 = UserModel(
        id: 'user1',
        username: 'user1',
        email: 'user1@example.com',
      );
      const user2 = UserModel(
        id: 'user1',
        username: 'user1',
        email: 'user1@example.com',
      );

      expect(identical(user1, user2), true);
    });
  });
}
