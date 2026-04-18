// lib/providers/todo_provider.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import '../data/models/todo_model.dart';
import '../data/services/todo_repository.dart';

enum TodoStatus { initial, loading, success, error }

enum TodoFilter { all, done, pending }

class TodoProvider extends ChangeNotifier {
  TodoProvider({TodoRepository? repository})
      : _repository = repository ?? TodoRepository();

  final TodoRepository _repository;

  // ── State ────────────────────────────────────
  TodoStatus _status = TodoStatus.initial;
  List<TodoModel> _todos = [];
  TodoModel? _selectedTodo;
  String _errorMessage = '';
  String _searchQuery = '';
  TodoFilter _filter = TodoFilter.all;

  // Stats from API (home screen)
  int _statTotal = 0;
  int _statDone = 0;
  int _statPending = 0;

  // Pagination
  int _currentPage = 1;
  bool _hasNextPage = false;
  bool _isLoadingMore = false;
  static const int _perPage = 10;

  // ── Getters ──────────────────────────────────
  TodoStatus get status        => _status;
  TodoModel? get selectedTodo  => _selectedTodo;
  String get errorMessage      => _errorMessage;
  TodoFilter get filter        => _filter;
  bool get hasNextPage         => _hasNextPage;
  bool get isLoadingMore       => _isLoadingMore;
  List<TodoModel> get todos    => List.unmodifiable(_todos);

  // Stats (from API)
  int get totalTodos   => _statTotal;
  int get doneTodos    => _statDone;
  int get pendingTodos => _statPending;

  // ── Load Stats ────────────────────────────────
  Future<void> loadStats({required String authToken}) async {
    final result = await _repository.getStats(authToken: authToken);
    if (result.success && result.data != null) {
      final stats = result.data!;
      _statTotal   = (stats['total']   as num?)?.toInt() ?? 0;
      _statDone    = (stats['done']    as num?)?.toInt() ?? 0;
      _statPending = (stats['pending'] as num?)?.toInt() ?? 0;
      notifyListeners();
    }
  }

  // ── Load Todos (first page / reset) ──────────
  Future<void> loadTodos({required String authToken}) async {
    _setStatus(TodoStatus.loading);
    _currentPage = 1;
    _todos = [];

    final result = await _repository.getTodos(
      authToken: authToken,
      search: _searchQuery,
      page: 1,
      perPage: _perPage,
      isDone: _filterToBool(_filter),
    );

    if (result.success && result.data != null) {
      _todos       = result.data!.items;
      _hasNextPage = result.data!.hasNextPage;
      _setStatus(TodoStatus.success);
    } else {
      _errorMessage = result.message;
      _setStatus(TodoStatus.error);
    }
  }

  // ── Load More (infinite scroll) ───────────────
  Future<void> loadMore({required String authToken}) async {
    if (_isLoadingMore || !_hasNextPage) return;
    _isLoadingMore = true;
    notifyListeners();

    final nextPage = _currentPage + 1;
    final result = await _repository.getTodos(
      authToken: authToken,
      search: _searchQuery,
      page: nextPage,
      perPage: _perPage,
      isDone: _filterToBool(_filter),
    );

    _isLoadingMore = false;
    if (result.success && result.data != null) {
      _todos.addAll(result.data!.items);
      _currentPage = nextPage;
      _hasNextPage = result.data!.hasNextPage;
    }
    notifyListeners();
  }

  // ── Load Single Todo ──────────────────────────
  Future<void> loadTodoById({
    required String authToken,
    required String todoId,
  }) async {
    _setStatus(TodoStatus.loading);
    final result = await _repository.getTodoById(
        authToken: authToken, todoId: todoId);
    if (result.success && result.data != null) {
      _selectedTodo = result.data;
      _setStatus(TodoStatus.success);
    } else {
      _errorMessage = result.message;
      _setStatus(TodoStatus.error);
    }
  }

  // ── Create Todo ───────────────────────────────
  Future<bool> addTodo({
    required String authToken,
    required String title,
    required String description,
  }) async {
    _setStatus(TodoStatus.loading);
    final result = await _repository.createTodo(
      authToken:   authToken,
      title:       title,
      description: description,
    );
    if (result.success) {
      await loadTodos(authToken: authToken);
      await loadStats(authToken: authToken);
      return true;
    }
    _errorMessage = result.message;
    _setStatus(TodoStatus.error);
    return false;
  }

  // ── Update Todo ───────────────────────────────
  Future<bool> editTodo({
    required String authToken,
    required String todoId,
    required String title,
    required String description,
    required bool isDone,
  }) async {
    _setStatus(TodoStatus.loading);
    final result = await _repository.updateTodo(
      authToken:   authToken,
      todoId:      todoId,
      title:       title,
      description: description,
      isDone:      isDone,
    );
    if (result.success) {
      final results = await Future.wait([
        _repository.getTodoById(authToken: authToken, todoId: todoId),
        _repository.getTodos(
          authToken: authToken,
          search: _searchQuery,
          page: 1,
          perPage: _perPage * _currentPage,
          isDone: _filterToBool(_filter),
        ),
        _repository.getStats(authToken: authToken),
      ]);

      final detailResult = results[0];
      final listResult   = results[1];
      final statsResult  = results[2];

      if (detailResult.success && detailResult.data != null) {
        _selectedTodo = detailResult.data as TodoModel;
      }
      if (listResult.success && listResult.data != null) {
        final paginated = listResult.data as dynamic;
        _todos = paginated.items as List<TodoModel>;
        _hasNextPage = paginated.hasNextPage as bool;
      }
      if (statsResult.success && statsResult.data != null) {
        final stats = statsResult.data as Map<String, dynamic>;
        _statTotal   = (stats['total']   as num?)?.toInt() ?? _statTotal;
        _statDone    = (stats['done']    as num?)?.toInt() ?? _statDone;
        _statPending = (stats['pending'] as num?)?.toInt() ?? _statPending;
      }

      _setStatus(TodoStatus.success);
      return true;
    }
    _errorMessage = result.message;
    _setStatus(TodoStatus.error);
    return false;
  }

  // ── Update Cover ──────────────────────────────
  Future<bool> updateCover({
    required String authToken,
    required String todoId,
    File? imageFile,
    Uint8List? imageBytes,
    String imageFilename = 'cover.jpg',
  }) async {
    _setStatus(TodoStatus.loading);
    final result = await _repository.updateTodoCover(
      authToken:     authToken,
      todoId:        todoId,
      imageFile:     imageFile,
      imageBytes:    imageBytes,
      imageFilename: imageFilename,
    );
    if (result.success) {
      final results = await Future.wait([
        _repository.getTodoById(authToken: authToken, todoId: todoId),
      ]);

      final detailResult = results[0];
      if (detailResult.success && detailResult.data != null) {
        _selectedTodo = detailResult.data as TodoModel;
        // Update in list too
        final idx = _todos.indexWhere((t) => t.id == todoId);
        if (idx >= 0) {
          _todos[idx] = _selectedTodo!;
        }
      }

      _setStatus(TodoStatus.success);
      return true;
    }
    _errorMessage = result.message;
    _setStatus(TodoStatus.error);
    return false;
  }

  // ── Delete Todo ───────────────────────────────
  Future<bool> removeTodo({
    required String authToken,
    required String todoId,
  }) async {
    _setStatus(TodoStatus.loading);
    final result = await _repository.deleteTodo(
        authToken: authToken, todoId: todoId);
    if (result.success) {
      _todos.removeWhere((t) => t.id == todoId);
      _selectedTodo = null;
      await loadStats(authToken: authToken);
      _setStatus(TodoStatus.success);
      return true;
    }
    _errorMessage = result.message;
    _setStatus(TodoStatus.error);
    return false;
  }

  // ── Filter ────────────────────────────────────
  void setFilter(TodoFilter filter, {required String authToken}) {
    if (_filter == filter) return;
    _filter = filter;
    loadTodos(authToken: authToken);
  }

  // ── Search ────────────────────────────────────
  void updateSearchQuery(String query, {required String authToken}) {
    _searchQuery = query;
    loadTodos(authToken: authToken);
  }

  void clearSelectedTodo() {
    _selectedTodo = null;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────
  bool? _filterToBool(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.done:    return true;
      case TodoFilter.pending: return false;
      case TodoFilter.all:     return null;
    }
  }

  void _setStatus(TodoStatus status) {
    _status = status;
    notifyListeners();
  }
}
