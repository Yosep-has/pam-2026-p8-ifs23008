// test/screens/home_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pam_p8_ifs23008/providers/auth_provider.dart';
import 'package:pam_p8_ifs23008/providers/todo_provider.dart';
import 'package:pam_p8_ifs23008/providers/theme_provider.dart';
import 'package:pam_p8_ifs23008/features/home/home_screen.dart';

Widget buildHomeTest() {
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/todos', builder: (_, __) => const SizedBox()),
    GoRoute(path: '/todos/add', builder: (_, __) => const SizedBox()),
  ]);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => TodoProvider()),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('HomeScreen', () {
    testWidgets('merender tanpa error', (tester) async {
      await tester.pumpWidget(buildHomeTest());
      await tester.pump();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('menampilkan salam kepada pengguna', (tester) async {
      await tester.pumpWidget(buildHomeTest());
      await tester.pump();

      expect(find.textContaining('Halo'), findsOneWidget);
    });

    testWidgets('menampilkan subtitle kelola todo', (tester) async {
      await tester.pumpWidget(buildHomeTest());
      await tester.pump();

      expect(find.text('Kelola todo-mu hari ini'), findsOneWidget);
    });

    testWidgets('menampilkan LinearProgressIndicator', (tester) async {
      await tester.pumpWidget(buildHomeTest());
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('menampilkan teks Progres Hari Ini', (tester) async {
      await tester.pumpWidget(buildHomeTest());
      await tester.pump();

      expect(find.text('Progres Hari Ini'), findsOneWidget);
    });

    testWidgets('menampilkan tiga stat chip: Total, Selesai, Tertunda',
        (tester) async {
      await tester.pumpWidget(buildHomeTest());
      await tester.pump();

      expect(find.text('Total'),    findsOneWidget);
      expect(find.text('Selesai'),  findsOneWidget);
      expect(find.text('Tertunda'), findsOneWidget);
    });

    testWidgets('menampilkan section Akses Cepat', (tester) async {
      await tester.pumpWidget(buildHomeTest());
      await tester.pump();

      expect(find.text('Akses Cepat'), findsOneWidget);
    });

    testWidgets('menampilkan card Daftar Todo', (tester) async {
      await tester.pumpWidget(buildHomeTest());
      await tester.pump();

      expect(find.text('Daftar Todo'), findsOneWidget);
    });

    testWidgets('menampilkan card Buat Todo Baru', (tester) async {
      await tester.pumpWidget(buildHomeTest());
      await tester.pump();

      expect(find.text('Buat Todo Baru'), findsOneWidget);
    });

    testWidgets('menampilkan tombol toggle light/dark mode', (tester) async {
      await tester.pumpWidget(buildHomeTest());
      await tester.pump();

      expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    });

    testWidgets('halaman dapat di-scroll', (tester) async {
      await tester.pumpWidget(buildHomeTest());
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('toggle dark mode mengubah ikon', (tester) async {
      await tester.pumpWidget(buildHomeTest());
      await tester.pump();

      expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.light_mode_rounded));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
    });
  });
}
