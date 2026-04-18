// lib/features/todos/todos_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/route_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/todo_provider.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/top_app_bar_widget.dart';

class TodosScreen extends StatefulWidget {
  const TodosScreen({super.key});

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    final token = context.read<AuthProvider>().authToken;
    if (token != null) context.read<TodoProvider>().loadTodos(authToken: token);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final token = context.read<AuthProvider>().authToken;
      if (token != null) {
        context.read<TodoProvider>().loadMore(authToken: token);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();
    final token    = context.read<AuthProvider>().authToken ?? '';

    return Scaffold(
      appBar: TopAppBarWidget(
        title: 'Todo Saya',
        withSearch: true,
        searchHint: 'Cari todo...',
        onSearchChanged: (query) {
          context.read<TodoProvider>().updateSearchQuery(
            query,
            authToken: token,
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context
            .push(RouteConstants.todosAdd)
            .then((_) => _loadData()),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah'),
        elevation: 3,
      ),
      body: Column(
        children: [
          // ── Filter Chips ──────────────────────────────
          _FilterBar(
            current: provider.filter,
            onChanged: (f) => provider.setFilter(f, authToken: token),
          ),

          // ── Content ────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: switch (provider.status) {
                TodoStatus.loading || TodoStatus.initial =>
                const LoadingWidget(message: 'Memuat todo...'),
                TodoStatus.error =>
                    AppErrorWidget(message: provider.errorMessage, onRetry: _loadData),
                _ => provider.todos.isEmpty
                    ? _EmptyState(filter: provider.filter)
                    : ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: provider.todos.length + (provider.hasNextPage ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    if (i == provider.todos.length) {
                      // Loading indicator at bottom
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final todo = provider.todos[i];
                    return _TodoCard(
                      todo: todo,
                      onTap: () => context
                          .push(RouteConstants.todosDetail(todo.id))
                          .then((_) => _loadData()),
                      onToggle: () async {
                        final success = await provider.editTodo(
                          authToken:   token,
                          todoId:      todo.id,
                          title:       todo.title,
                          description: todo.description,
                          isDone:      !todo.isDone,
                        );
                        if (!success && context.mounted) {
                          showAppSnackBar(context,
                              message: provider.errorMessage,
                              type: SnackBarType.error);
                        }
                      },
                    );
                  },
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter Bar ───────────────────────────────────────────
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.current, required this.onChanged});

  final TodoFilter current;
  final void Function(TodoFilter) onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _chip(context, TodoFilter.all,     'Semua',   Icons.format_list_bulleted_rounded),
          const SizedBox(width: 8),
          _chip(context, TodoFilter.pending, 'Belum',   Icons.radio_button_unchecked_rounded),
          const SizedBox(width: 8),
          _chip(context, TodoFilter.done,    'Selesai', Icons.check_circle_rounded),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, TodoFilter f, String label, IconData icon) {
    final selected = current == f;
    final colorScheme = Theme.of(context).colorScheme;
    return FilterChip(
      selected: selected,
      label: Text(label),
      avatar: Icon(icon, size: 16,
          color: selected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant),
      selectedColor: colorScheme.primary,
      labelStyle: TextStyle(
        color: selected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      checkmarkColor: colorScheme.onPrimary,
      showCheckmark: false,
      onSelected: (_) => onChanged(f),
    );
  }
}

// ── Empty State ──────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});

  final TodoFilter filter;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final msg = switch (filter) {
      TodoFilter.done    => 'Belum ada todo yang selesai.',
      TodoFilter.pending => 'Semua todo sudah selesai! 🎉',
      TodoFilter.all     => 'Belum ada todo.\nKetuk + untuk menambahkan.',
    };
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            filter == TodoFilter.done
                ? Icons.task_alt_rounded
                : Icons.inbox_outlined,
            size: 72,
            color: colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Todo Card ────────────────────────────────────────────
class _TodoCard extends StatelessWidget {
  const _TodoCard({
    required this.todo,
    required this.onTap,
    required this.onToggle,
  });

  final dynamic todo;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDone = todo.isDone as bool;

    return Material(
      borderRadius: BorderRadius.circular(16),
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Checkbox Icon
              GestureDetector(
                onTap: onToggle,
                behavior: HitTestBehavior.opaque,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isDone
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    key: ValueKey(isDone),
                    color: isDone ? const Color(0xFF2E7D32) : colorScheme.outline,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        decorationColor: colorScheme.outline,
                        fontWeight: FontWeight.w600,
                        color: isDone
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                      ),
                    ),
                    if ((todo.description as String).isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        todo.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDone
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isDone ? 'Selesai' : 'Belum selesai',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDone
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded,
                  color: colorScheme.outline, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
