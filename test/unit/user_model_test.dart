// test/unit/user_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:pam_p8_ifs23008/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    const uuid = 'user-uuid-1234';

    const user = UserModel(
      id: uuid,
      name: 'Budi Santoso',
      username: 'ifs23008',
      urlPhoto: null,
      createdAt: '2025-01-01T00:00:00Z',
      updatedAt: '2025-01-01T00:00:00Z',
    );

    test('membuat objek dengan semua field yang benar', () {
      expect(user.id, equals(uuid));
      expect(user.name, equals('Budi Santoso'));
      expect(user.username, equals('ifs23008'));
      expect(user.urlPhoto, isNull);
    });

    test('fromJson memetakan semua field dengan benar', () {
      final json = {
        'id': uuid,
        'name': 'Budi Santoso',
        'username': 'ifs23008',
        'urlPhoto': null,
        'createdAt': '2025-01-01T00:00:00Z',
        'updatedAt': '2025-01-01T00:00:00Z',
      };
      final result = UserModel.fromJson(json);
      expect(result.id, equals(uuid));
      expect(result.name, equals('Budi Santoso'));
      expect(result.username, equals('ifs23008'));
      expect(result.urlPhoto, isNull);
    });

    test('fromJson memetakan urlPhoto jika ada', () {
      final json = {
        'id': uuid,
        'name': 'Budi Santoso',
        'username': 'ifs23008',
        'urlPhoto': 'https://example.com/photo.jpg',
        'createdAt': '2025-01-01T00:00:00Z',
        'updatedAt': '2025-01-01T00:00:00Z',
      };
      final result = UserModel.fromJson(json);
      expect(result.urlPhoto, equals('https://example.com/photo.jpg'));
    });

    test('inisial nama pertama diambil dari karakter pertama name', () {
      // Logika inisial dipakai di UI, pastikan data mendukungnya
      expect(user.name.isNotEmpty, isTrue);
      expect(user.name[0].toUpperCase(), equals('B'));
    });
  });
}
