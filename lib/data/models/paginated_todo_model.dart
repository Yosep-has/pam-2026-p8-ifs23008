// lib/data/models/paginated_todo_model.dart

import 'todo_model.dart';

class PaginatedTodoModel {
  const PaginatedTodoModel({
    required this.items,
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
  });

  final List<TodoModel> items;
  final int page;
  final int perPage;
  final int total;
  final int totalPages;
  final bool hasNextPage;
}
