// test/unit/todo_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:pam_p8_ifs23008/data/models/todo_model.dart';

void main() {
  group('TodoModel', () {
    const uuid = 'aaaa-bbbb-cccc-dddd';

    const todo = TodoModel(
      id: uuid,
      userId: 'user-001',
      title: 'Belajar Flutter',
      description: 'Mempelajari widget dan state management.',
      isDone: false,
      urlCover: null,
      createdAt: '2025-01-01T00:00:00Z',
      updatedAt: '2025-01-01T00:00:00Z',
    );

    test('membuat objek dengan semua field yang benar', () {
      expect(todo.id, equals(uuid));
      expect(todo.title, equals('Belajar Flutter'));
      expect(todo.isDone, isFalse);
      expect(todo.urlCover, isNull);
    });

    test('fromJson memetakan semua field dengan benar', () {
      final json = {
        'id': uuid,
        'userId': 'user-001',
        'title': 'Belajar Flutter',
        'description': 'Mempelajari widget dan state management.',
        'isDone': false,
        'urlCover': null,
        'createdAt': '2025-01-01T00:00:00Z',
        'updatedAt': '2025-01-01T00:00:00Z',
      };
      final result = TodoModel.fromJson(json);
      expect(result.id, equals(uuid));
      expect(result.title, equals('Belajar Flutter'));
      expect(result.isDone, isFalse);
      expect(result.urlCover, isNull);
    });

    test('fromJson dengan isDone true', () {
      final json = {
        'id': uuid,
        'userId': 'user-001',
        'title': 'Selesai',
        'description': 'Sudah selesai.',
        'isDone': true,
        'createdAt': '2025-01-01T00:00:00Z',
        'updatedAt': '2025-01-01T00:00:00Z',
      };
      final result = TodoModel.fromJson(json);
      expect(result.isDone, isTrue);
    });

    test('fromJson menggunakan default kosong jika field null/absen', () {
      final json = <String, dynamic>{};
      final result = TodoModel.fromJson(json);
      expect(result.id, equals(''));
      expect(result.title, equals(''));
      expect(result.isDone, isFalse);
    });

    test('fromJson memetakan urlCover dengan benar jika ada', () {
      final json = {
        'id': uuid,
        'userId': 'user-001',
        'title': 'Todo dengan cover',
        'description': 'Ada gambar.',
        'isDone': false,
        'urlCover': 'https://example.com/cover.jpg',
        'createdAt': '2025-01-01T00:00:00Z',
        'updatedAt': '2025-01-01T00:00:00Z',
      };
      final result = TodoModel.fromJson(json);
      expect(result.urlCover, equals('https://example.com/cover.jpg'));
    });

    test('fromJson dengan isDone null menggunakan false sebagai default', () {
      final json = {
        'id': uuid,
        'userId': 'user-001',
        'title': 'Test',
        'description': 'Desc',
        'isDone': null,
        'createdAt': '2025-01-01T00:00:00Z',
        'updatedAt': '2025-01-01T00:00:00Z',
      };
      final result = TodoModel.fromJson(json);
      expect(result.isDone, isFalse);
    });
  });
}
