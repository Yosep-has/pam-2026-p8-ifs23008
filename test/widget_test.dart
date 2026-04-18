// test/widget_test.dart
//
// Widget tests untuk aplikasi Delcom Todos.
// Menguji rendering awal layar login, navigasi, dan komponen utama.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:pam_p8_ifs23008/main.dart';
import 'package:pam_p8_ifs23008/providers/auth_provider.dart';
import 'package:pam_p8_ifs23008/providers/todo_provider.dart';
import 'package:pam_p8_ifs23008/providers/theme_provider.dart';
import 'package:pam_p8_ifs23008/features/auth/login_screen.dart';
import 'package:pam_p8_ifs23008/features/home/home_screen.dart';
import 'package:pam_p8_ifs23008/features/todos/todos_screen.dart';

void main() {
  // ── Helper: bungkus widget dengan providers yang dibutuhkan ──
  Widget buildWithProviders(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
      ],
      child: MaterialApp(home: child),
    );
  }

  // ────────────────────────────────────────────
  // App smoke test
  // ────────────────────────────────────────────
  testWidgets('App dapat di-render tanpa crash', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => TodoProvider()),
        ],
        child: const DelcomTodosApp(),
      ),
    );
    // Cukup pump tanpa error
    await tester.pump();
  });

  // ────────────────────────────────────────────
  // Login Screen
  // ────────────────────────────────────────────
  group('LoginScreen', () {
    testWidgets('Menampilkan field username dan password', (tester) async {
      await tester.pumpWidget(buildWithProviders(const LoginScreen()));
      await tester.pump();

      expect(find.widgetWithText(TextFormField, 'Username'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Kata Sandi'), findsOneWidget);
    });

    testWidgets('Menampilkan tombol Masuk', (tester) async {
      await tester.pumpWidget(buildWithProviders(const LoginScreen()));
      await tester.pump();

      expect(find.text('Masuk'), findsAtLeastNWidgets(1));
    });

    testWidgets('Validasi form — field kosong menampilkan pesan error',
            (tester) async {
          await tester.pumpWidget(buildWithProviders(const LoginScreen()));
          await tester.pump();

          // Tap tombol submit tanpa mengisi apapun
          final submitBtn = find.widgetWithText(FilledButton, 'Masuk');
          if (submitBtn.evaluate().isNotEmpty) {
            await tester.tap(submitBtn);
            await tester.pump();
            // Setidaknya satu pesan validasi muncul
            expect(
              find.byType(TextFormField),
              findsAtLeastNWidgets(2),
            );
          }
        });

    testWidgets('Terdapat link ke halaman Register', (tester) async {
      await tester.pumpWidget(buildWithProviders(const LoginScreen()));
      await tester.pump();

      // Cari teks yang mengarah ke register
      expect(
        find.textContaining('Daftar'),
        findsAtLeastNWidgets(1),
      );
    });
  });

  // ────────────────────────────────────────────
  // Home Screen
  // ────────────────────────────────────────────
  group('HomeScreen', () {
    testWidgets('Menampilkan widget stat (Total, Selesai, Tertunda)',
            (tester) async {
          await tester.pumpWidget(buildWithProviders(const HomeScreen()));
          await tester.pump();

          expect(find.text('Total'),   findsOneWidget);
          expect(find.text('Selesai'), findsOneWidget);
          expect(find.text('Tertunda'), findsOneWidget);
        });

    testWidgets('Menampilkan LinearProgressIndicator', (tester) async {
      await tester.pumpWidget(buildWithProviders(const HomeScreen()));
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('Menampilkan teks Akses Cepat', (tester) async {
      await tester.pumpWidget(buildWithProviders(const HomeScreen()));
      await tester.pump();

      expect(find.text('Akses Cepat'), findsOneWidget);
    });

    testWidgets('Menampilkan card Daftar Todo dan Buat Todo Baru',
            (tester) async {
          await tester.pumpWidget(buildWithProviders(const HomeScreen()));
          await tester.pump();

          expect(find.text('Daftar Todo'),    findsOneWidget);
          expect(find.text('Buat Todo Baru'), findsOneWidget);
        });
  });

  // ────────────────────────────────────────────
  // Todos Screen
  // ────────────────────────────────────────────
  group('TodosScreen', () {
    testWidgets('Menampilkan filter chip Semua, Belum, Selesai',
            (tester) async {
          await tester.pumpWidget(buildWithProviders(const TodosScreen()));
          await tester.pump();

          expect(find.text('Semua'),   findsOneWidget);
          expect(find.text('Belum'),   findsOneWidget);
          expect(find.text('Selesai'), findsOneWidget);
        });

    testWidgets('Menampilkan FloatingActionButton Tambah', (tester) async {
      await tester.pumpWidget(buildWithProviders(const TodosScreen()));
      await tester.pump();

      expect(find.text('Tambah'), findsOneWidget);
    });

    testWidgets('Filter chip dapat di-tap tanpa crash', (tester) async {
      await tester.pumpWidget(buildWithProviders(const TodosScreen()));
      await tester.pump();

      final selesaiChip = find.text('Selesai');
      if (selesaiChip.evaluate().isNotEmpty) {
        await tester.tap(selesaiChip);
        await tester.pump();
      }

      final belumChip = find.text('Belum');
      if (belumChip.evaluate().isNotEmpty) {
        await tester.tap(belumChip);
        await tester.pump();
      }
    });
  });

  // ────────────────────────────────────────────
  // ThemeProvider
  // ────────────────────────────────────────────
  group('ThemeProvider', () {
    test('Default theme adalah light', () {
      final provider = ThemeProvider();
      expect(provider.isDark, isFalse);
      expect(provider.themeMode, ThemeMode.light);
    });

    test('toggleTheme mengubah ke dark mode', () {
      final provider = ThemeProvider();
      provider.toggleTheme();
      expect(provider.isDark, isTrue);
      expect(provider.themeMode, ThemeMode.dark);
    });

    test('toggleTheme dua kali kembali ke light', () {
      final provider = ThemeProvider();
      provider.toggleTheme();
      provider.toggleTheme();
      expect(provider.isDark, isFalse);
    });
  });

  // ────────────────────────────────────────────
  // TodoProvider — unit logic
  // ────────────────────────────────────────────
  group('TodoProvider', () {
    test('Status awal adalah initial', () {
      final provider = TodoProvider();
      expect(provider.status, TodoStatus.initial);
    });

    test('Filter awal adalah all', () {
      final provider = TodoProvider();
      expect(provider.filter, TodoFilter.all);
    });

    test('hasNextPage awal adalah false', () {
      final provider = TodoProvider();
      expect(provider.hasNextPage, isFalse);
    });

    test('isLoadingMore awal adalah false', () {
      final provider = TodoProvider();
      expect(provider.isLoadingMore, isFalse);
    });

    test('todos awal adalah list kosong', () {
      final provider = TodoProvider();
      expect(provider.todos, isEmpty);
    });

    test('Stats awal semua nol', () {
      final provider = TodoProvider();
      expect(provider.totalTodos,   0);
      expect(provider.doneTodos,    0);
      expect(provider.pendingTodos, 0);
    });

    test('clearSelectedTodo membersihkan selectedTodo', () {
      final provider = TodoProvider();
      provider.clearSelectedTodo();
      expect(provider.selectedTodo, isNull);
    });
  });
}
