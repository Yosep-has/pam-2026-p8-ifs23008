// test/widget/bottom_nav_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pam_p8_ifs23008/providers/theme_provider.dart';
import 'package:pam_p8_ifs23008/shared/widgets/bottom_nav_widget.dart';

Widget buildNavTestApp(String initialRoute) {
  final router = GoRouter(
    initialLocation: initialRoute,
    routes: [
      ShellRoute(
        builder: (context, state, child) => Scaffold(
          body: child,
          bottomNavigationBar: const BottomNavWidget(),
        ),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const SizedBox(key: Key('home')),
          ),
          GoRoute(
            path: '/todos',
            builder: (_, __) => const SizedBox(key: Key('todos')),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const SizedBox(key: Key('profile')),
          ),
        ],
      ),
    ],
  );

  return ChangeNotifierProvider(
    create: (_) => ThemeProvider(),
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('BottomNavWidget', () {
    testWidgets('merender tiga item navigasi', (tester) async {
      await tester.pumpWidget(buildNavTestApp('/home'));
      await tester.pumpAndSettle();

      expect(find.text('Home'),  findsOneWidget);
      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });

    testWidgets('menampilkan NavigationBar sebagai bottom bar', (tester) async {
      await tester.pumpWidget(buildNavTestApp('/home'));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('menampilkan ikon home di halaman home', (tester) async {
      await tester.pumpWidget(buildNavTestApp('/home'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    });

    testWidgets('menekan Todos menavigasi ke halaman todos', (tester) async {
      await tester.pumpWidget(buildNavTestApp('/home'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Todos'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('todos')), findsOneWidget);
    });

    testWidgets('menekan Profil menavigasi ke halaman profil', (tester) async {
      await tester.pumpWidget(buildNavTestApp('/home'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile')), findsOneWidget);
    });

    testWidgets('menekan Home menavigasi kembali ke halaman home', (tester) async {
      await tester.pumpWidget(buildNavTestApp('/todos'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home')), findsOneWidget);
    });

    testWidgets('ikon task aktif saat di halaman todos', (tester) async {
      await tester.pumpWidget(buildNavTestApp('/todos'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.task_rounded), findsOneWidget);
    });

    testWidgets('ikon person aktif saat di halaman profil', (tester) async {
      await tester.pumpWidget(buildNavTestApp('/profile'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    });
  });
}
