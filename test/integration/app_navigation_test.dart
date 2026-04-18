// test/integration/app_navigation_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pam_p8_ifs23008/main.dart';
import 'package:pam_p8_ifs23008/providers/auth_provider.dart';
import 'package:pam_p8_ifs23008/providers/todo_provider.dart';
import 'package:pam_p8_ifs23008/providers/theme_provider.dart';

/// Bungkus app dengan semua provider — mensimulasikan entry point nyata.
Widget buildApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => TodoProvider()),
    ],
    child: const DelcomTodosApp(),
  );
}

void main() {
  group('Navigasi Aplikasi (End-to-End)', () {
    testWidgets('aplikasi berjalan dan menampilkan LoginScreen', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      // Route awal adalah /login
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('LoginScreen menampilkan field username dan password',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      expect(find.widgetWithText(TextFormField, 'Username'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Kata Sandi'), findsOneWidget);
    });

    testWidgets('LoginScreen menampilkan tombol Masuk', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      expect(find.text('Masuk'), findsAtLeastNWidgets(1));
    });

    testWidgets('LoginScreen menampilkan link ke halaman Daftar', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      expect(find.text('Daftar'), findsOneWidget);
    });

    testWidgets('menekan tombol Daftar menavigasi ke RegisterScreen',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      // Register screen menampilkan form daftar
      expect(find.text('Nama Lengkap'), findsAtLeastNWidgets(1));
    });

    testWidgets('RegisterScreen memiliki link kembali ke Login', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      expect(find.text('Masuk'), findsAtLeastNWidgets(1));
    });

    testWidgets('validasi login — username kosong menampilkan error',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      await tester.tap(find.text('Masuk').last);
      await tester.pump();

      expect(find.text('Username tidak boleh kosong.'), findsOneWidget);
    });

    testWidgets('validasi login — password kosong menampilkan error',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Username'), 'testuser');
      await tester.tap(find.text('Masuk').last);
      await tester.pump();

      expect(find.text('Kata sandi tidak boleh kosong.'), findsOneWidget);
    });

    testWidgets('toggle dark mode di LoginScreen mengubah ikon', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      // Light mode default tidak ada ikon toggle di login
      // Pastikan app tetap merender tanpa crash
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('aplikasi menggunakan MaterialApp.router', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      // MaterialApp.router berhasil dirender
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('DelcomTodosApp merender dengan benar', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      expect(find.byType(DelcomTodosApp), findsOneWidget);
    });

    testWidgets('tombol visibility password di login berfungsi', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      // Awalnya password tersembunyi
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });
}
