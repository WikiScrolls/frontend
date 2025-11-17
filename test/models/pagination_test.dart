import 'package:flutter_test/flutter_test.dart';
import 'package:wikiscrolls_frontend/api/models/pagination.dart';

void main() {
  group('PaginationInfo', () {
    test('fromJson creates PaginationInfo with all fields', () {
      final json = {
        'page': 2,
        'limit': 20,
        'totalItems': 150,
        'totalPages': 8,
      };

      final pagination = PaginationInfo.fromJson(json);

      expect(pagination.page, 2);
      expect(pagination.limit, 20);
      expect(pagination.totalItems, 150);
      expect(pagination.totalPages, 8);
    });

    test('fromJson handles default values when fields are missing', () {
      final json = <String, dynamic>{};

      final pagination = PaginationInfo.fromJson(json);

      expect(pagination.page, 1);
      expect(pagination.limit, 10);
      expect(pagination.totalItems, 0);
      expect(pagination.totalPages, 0);
    });

    test('fromJson handles double values correctly', () {
      final json = {
        'page': 3.0,
        'limit': 15.0,
        'totalItems': 200.0,
        'totalPages': 14.0,
      };

      final pagination = PaginationInfo.fromJson(json);

      expect(pagination.page, 3);
      expect(pagination.limit, 15);
      expect(pagination.totalItems, 200);
      expect(pagination.totalPages, 14);
    });

    test('toJson converts PaginationInfo to JSON', () {
      const pagination = PaginationInfo(
        page: 3,
        limit: 25,
        totalItems: 300,
        totalPages: 12,
      );

      final json = pagination.toJson();

      expect(json['page'], 3);
      expect(json['limit'], 25);
      expect(json['totalItems'], 300);
      expect(json['totalPages'], 12);
    });

    test('round-trip serialization preserves data', () {
      const original = PaginationInfo(
        page: 5,
        limit: 50,
        totalItems: 500,
        totalPages: 10,
      );

      final json = original.toJson();
      final restored = PaginationInfo.fromJson(json);

      expect(restored.page, original.page);
      expect(restored.limit, original.limit);
      expect(restored.totalItems, original.totalItems);
      expect(restored.totalPages, original.totalPages);
    });

    test('const constructor creates immutable PaginationInfo', () {
      const pagination1 = PaginationInfo(
        page: 1,
        limit: 10,
        totalItems: 100,
        totalPages: 10,
      );
      const pagination2 = PaginationInfo(
        page: 1,
        limit: 10,
        totalItems: 100,
        totalPages: 10,
      );

      expect(identical(pagination1, pagination2), true);
    });
  });
}
