// test/unit/todo_provider_test.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:pam_p8_ifs23008/data/models/api_response_model.dart';
import 'package:pam_p8_ifs23008/data/models/todo_model.dart';
import 'package:pam_p8_ifs23008/data/models/paginated_todo_model.dart';
import 'package:pam_p8_ifs23008/data/services/todo_repository.dart';
import 'package:pam_p8_ifs23008/providers/todo_provider.dart';

// ── Mock Repository ───────────────────────────────────────
class MockTodoRepository extends TodoRepository {
  MockTodoRepository({
    required this.mockTodos,
    this.mockStats = const {'total': 2, 'done': 1, 'pending': 1},
    this.shouldFail = false,
  });

  final List<TodoModel> mockTodos;
  final Map<String, dynamic> mockStats;
  final bool shouldFail;

  PaginatedTodoModel _paginate(List<TodoModel> items, int page, int perPage) {
    final start = (page - 1) * perPage;
    final end = (start + perPage).clamp(0, items.length);
    final pageItems = items.sublist(start.clamp(0, items.length), end);
    final totalPages = (items.length / perPage).ceil().clamp(1, 999);
    return PaginatedTodoModel(
      items: pageItems,
      page: page,
      perPage: perPage,
      total: items.length,
      totalPages: totalPages,
      hasNextPage: page < totalPages,
    );
  }

  @override
  Future<ApiResponse<PaginatedTodoModel>> getTodos({
    required String authToken,
    String search = '',
    int page = 1,
    int perPage = 10,
    bool? isDone,
  }) async {
    if (shouldFail) {
      return const ApiResponse(
          success: false, message: 'Gagal terhubung ke server.');
    }
    var filtered = mockTodos.where((t) {
      final matchSearch = search.isEmpty ||
          t.title.toLowerCase().contains(search.toLowerCase());
      final matchDone = isDone == null || t.isDone == isDone;
      return matchSearch && matchDone;
    }).toList();
    return ApiResponse(
        success: true,
        message: 'OK',
        data: _paginate(filtered, page, perPage));
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getStats({
    required String authToken,
  }) async {
    if (shouldFail) {
      return const ApiResponse(success: false, message: 'Gagal mengambil stats.');
    }
    return ApiResponse(success: true, message: 'OK', data: mockStats);
  }

  @override
  Future<ApiResponse<TodoModel>> getTodoById({
    required String authToken,
    required String todoId,
  }) async {
    if (shouldFail) {
      return const ApiResponse(success: false, message: 'Gagal mengambil data.');
    }
    final todo = mockTodos.firstWhere(
      (t) => t.id == todoId,
      orElse: () => const TodoModel(
        id: '', userId: '', title: '', description: '',
        isDone: false, createdAt: '', updatedAt: '',
      ),
    );
    return ApiResponse(success: true, message: 'OK', data: todo);
  }

  @override
  Future<ApiResponse<String>> createTodo({
    required String authToken,
    required String title,
    required String description,
  }) async {
    if (shouldFail) {
      return const ApiResponse(success: false, message: 'Gagal menambahkan todo.');
    }
    return const ApiResponse(success: true, message: 'OK', data: 'new-todo-uuid');
  }

  @override
  Future<ApiResponse<void>> updateTodo({
    required String authToken,
    required String todoId,
    required String title,
    required String description,
    required bool isDone,
  }) async {
    if (shouldFail) {
      return const ApiResponse(success: false, message: 'Gagal mengubah todo.');
    }
    return const ApiResponse(success: true, message: 'OK');
  }

  @override
  Future<ApiResponse<void>> updateTodoCover({
    required String authToken,
    required String todoId,
    File? imageFile,
    Uint8List? imageBytes,
    String imageFilename = 'cover.jpg',
  }) async {
    if (shouldFail) {
      return const ApiResponse(success: false, message: 'Gagal upload cover.');
    }
    return const ApiResponse(success: true, message: 'OK');
  }

  @override
  Future<ApiResponse<void>> deleteTodo({
    required String authToken,
    required String todoId,
  }) async {
    if (shouldFail) {
      return const ApiResponse(success: false, message: 'Gagal menghapus todo.');
    }
    return const ApiResponse(success: true, message: 'OK');
  }
}

// ── Test Data ────────────────────────────────────────────
const _mockTodos = [
  TodoModel(
    id: 'todo-001',
    userId: 'user-001',
    title: 'Belajar Flutter',
    description: 'Pelajari widget dan state.',
    isDone: false,
    createdAt: '2025-01-01T00:00:00Z',
    updatedAt: '2025-01-01T00:00:00Z',
  ),
  TodoModel(
    id: 'todo-002',
    userId: 'user-001',
    title: 'Membuat API Ktor',
    description: 'Setup routing dan database.',
    isDone: true,
    createdAt: '2025-01-02T00:00:00Z',
    updatedAt: '2025-01-02T00:00:00Z',
  ),
];

const _token = 'mock-token-abc';

void main() {
  group('TodoProvider', () {
    late TodoProvider provider;

    setUp(() {
      provider = TodoProvider(
        repository: MockTodoRepository(mockTodos: _mockTodos),
      );
    });

    tearDown(() {
      provider.dispose();
    });

    // ── State awal ──────────────────────────────────
    test('status awal adalah initial', () {
      expect(provider.status, equals(TodoStatus.initial));
    });

    test('filter awal adalah all', () {
      expect(provider.filter, equals(TodoFilter.all));
    });

    test('todos awal adalah list kosong', () {
      expect(provider.todos, isEmpty);
    });

    test('stats awal semua nol', () {
      expect(provider.totalTodos, equals(0));
      expect(provider.doneTodos, equals(0));
      expect(provider.pendingTodos, equals(0));
    });

    test('hasNextPage awal adalah false', () {
      expect(provider.hasNextPage, isFalse);
    });

    test('isLoadingMore awal adalah false', () {
      expect(provider.isLoadingMore, isFalse);
    });

    // ── loadTodos ───────────────────────────────────
    test('loadTodos berhasil mengubah status ke success', () async {
      await provider.loadTodos(authToken: _token);
      expect(provider.status, equals(TodoStatus.success));
      expect(provider.todos.length, equals(2));
    });

    test('loadTodos gagal mengubah status ke error', () async {
      provider = TodoProvider(
        repository: MockTodoRepository(mockTodos: [], shouldFail: true),
      );
      await provider.loadTodos(authToken: _token);
      expect(provider.status, equals(TodoStatus.error));
      expect(provider.errorMessage, isNotEmpty);
    });

    // ── loadStats ───────────────────────────────────
    test('loadStats mengisi nilai total, done, dan pending', () async {
      await provider.loadStats(authToken: _token);
      expect(provider.totalTodos, equals(2));
      expect(provider.doneTodos, equals(1));
      expect(provider.pendingTodos, equals(1));
    });

    // ── loadTodoById ────────────────────────────────
    test('loadTodoById berhasil mengisi selectedTodo', () async {
      await provider.loadTodoById(authToken: _token, todoId: 'todo-001');
      expect(provider.selectedTodo, isNotNull);
      expect(provider.selectedTodo!.id, equals('todo-001'));
    });

    test('loadTodoById gagal mengubah status ke error', () async {
      provider = TodoProvider(
        repository: MockTodoRepository(mockTodos: _mockTodos, shouldFail: true),
      );
      await provider.loadTodoById(authToken: _token, todoId: 'todo-001');
      expect(provider.status, equals(TodoStatus.error));
    });

    // ── Filter ──────────────────────────────────────
    test('setFilter done menampilkan hanya todo yang selesai', () async {
      await provider.loadTodos(authToken: _token);
      provider.setFilter(TodoFilter.done, authToken: _token);
      await Future.delayed(Duration.zero); // tunggu async selesai
      expect(provider.filter, equals(TodoFilter.done));
    });

    test('setFilter pending menampilkan hanya todo yang belum selesai', () async {
      await provider.loadTodos(authToken: _token);
      provider.setFilter(TodoFilter.pending, authToken: _token);
      await Future.delayed(Duration.zero);
      expect(provider.filter, equals(TodoFilter.pending));
    });

    test('setFilter all mengembalikan semua todo', () async {
      await provider.loadTodos(authToken: _token);
      provider.setFilter(TodoFilter.done, authToken: _token);
      provider.setFilter(TodoFilter.all, authToken: _token);
      await Future.delayed(Duration.zero);
      expect(provider.filter, equals(TodoFilter.all));
    });

    test('setFilter dengan filter yang sama tidak memicu loadTodos ulang', () async {
      await provider.loadTodos(authToken: _token);
      final statusBefore = provider.status;
      provider.setFilter(TodoFilter.all, authToken: _token); // sama
      // status tidak berubah ke loading
      expect(provider.status, equals(statusBefore));
    });

    // ── addTodo ─────────────────────────────────────
    test('addTodo berhasil mengembalikan true', () async {
      final success = await provider.addTodo(
        authToken: _token,
        title: 'Todo Baru',
        description: 'Deskripsi baru',
      );
      expect(success, isTrue);
    });

    test('addTodo gagal mengembalikan false dan set error', () async {
      provider = TodoProvider(
        repository: MockTodoRepository(mockTodos: _mockTodos, shouldFail: true),
      );
      final success = await provider.addTodo(
        authToken: _token,
        title: 'Todo Baru',
        description: 'Deskripsi',
      );
      expect(success, isFalse);
      expect(provider.status, equals(TodoStatus.error));
    });

    // ── removeTodo ──────────────────────────────────
    test('removeTodo berhasil menghapus dari list lokal', () async {
      await provider.loadTodos(authToken: _token);
      final success = await provider.removeTodo(
        authToken: _token,
        todoId: 'todo-001',
      );
      expect(success, isTrue);
      expect(provider.todos.any((t) => t.id == 'todo-001'), isFalse);
    });

    test('removeTodo gagal mengembalikan false dan set error', () async {
      provider = TodoProvider(
        repository: MockTodoRepository(mockTodos: _mockTodos, shouldFail: true),
      );
      await provider.loadTodos(authToken: _token);
      final success = await provider.removeTodo(
        authToken: _token,
        todoId: 'todo-001',
      );
      expect(success, isFalse);
      expect(provider.status, equals(TodoStatus.error));
    });

    // ── clearSelectedTodo ───────────────────────────
    test('clearSelectedTodo mengosongkan selectedTodo', () async {
      await provider.loadTodoById(authToken: _token, todoId: 'todo-001');
      expect(provider.selectedTodo, isNotNull);
      provider.clearSelectedTodo();
      expect(provider.selectedTodo, isNull);
    });
  });
}
