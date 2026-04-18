// test/screens/login_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pam_p8_ifs23008/providers/auth_provider.dart';
import 'package:pam_p8_ifs23008/providers/theme_provider.dart';
import 'package:pam_p8_ifs23008/features/auth/login_screen.dart';

Widget buildLoginTest() {
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const SizedBox()),
    GoRoute(path: '/home', builder: (_, __) => const SizedBox()),
  ]);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('LoginScreen', () {
    testWidgets('merender tanpa error', (tester) async {
      await tester.pumpWidget(buildLoginTest());
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('menampilkan subtitle masuk ke akun', (tester) async {
      await tester.pumpWidget(buildLoginTest());
      await tester.pumpAndSettle();

      expect(find.text('Masuk ke akun Delcom Todos kamu'), findsOneWidget);
    });

    testWidgets('menampilkan field Username', (tester) async {
      await tester.pumpWidget(buildLoginTest());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Username'), findsOneWidget);
    });

    testWidgets('menampilkan field Kata Sandi', (tester) async {
      await tester.pumpWidget(buildLoginTest());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Kata Sandi'), findsOneWidget);
    });

    testWidgets('menampilkan tombol Masuk', (tester) async {
      await tester.pumpWidget(buildLoginTest());
      await tester.pumpAndSettle();

      expect(find.text('Masuk'), findsAtLeastNWidgets(1));
    });

    testWidgets('menampilkan teks Belum punya akun?', (tester) async {
      await tester.pumpWidget(buildLoginTest());
      await tester.pumpAndSettle();

      expect(find.text('Belum punya akun?'), findsOneWidget);
    });

    testWidgets('menampilkan tombol Daftar', (tester) async {
      await tester.pumpWidget(buildLoginTest());
      await tester.pumpAndSettle();

      expect(find.text('Daftar'), findsOneWidget);
    });

    testWidgets('validasi form — username kosong menampilkan pesan error',
        (tester) async {
      await tester.pumpWidget(buildLoginTest());
      await tester.pumpAndSettle();

      // Tap tombol Masuk tanpa mengisi field
      await tester.tap(find.text('Masuk').last);
      await tester.pump();

      expect(find.text('Username tidak boleh kosong.'), findsOneWidget);
    });

    testWidgets('validasi form — kata sandi kosong menampilkan pesan error',
        (tester) async {
      await tester.pumpWidget(buildLoginTest());
      await tester.pumpAndSettle();

      // Isi username, tapi biarkan password kosong
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'),
        'testuser',
      );
      await tester.tap(find.text('Masuk').last);
      await tester.pump();

      expect(find.text('Kata sandi tidak boleh kosong.'), findsOneWidget);
    });

    testWidgets('tombol visibility password dapat ditekan', (tester) async {
      await tester.pumpWidget(buildLoginTest());
      await tester.pumpAndSettle();

      // Ikon visibility ada di password field
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('halaman dapat di-scroll', (tester) async {
      await tester.pumpWidget(buildLoginTest());
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
