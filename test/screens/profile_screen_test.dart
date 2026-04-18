// test/screens/profile_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pam_p8_ifs23008/providers/auth_provider.dart';
import 'package:pam_p8_ifs23008/providers/theme_provider.dart';
import 'package:pam_p8_ifs23008/features/profile/profile_screen.dart';

Widget buildProfileTest() {
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/login', builder: (_, __) => const SizedBox()),
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
  group('ProfileScreen', () {
    testWidgets('merender tanpa error', (tester) async {
      await tester.pumpWidget(buildProfileTest());
      await tester.pump();

      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('menampilkan judul "Profil Saya" di AppBar', (tester) async {
      await tester.pumpWidget(buildProfileTest());
      await tester.pump();

      expect(find.text('Profil Saya'), findsOneWidget);
    });

    testWidgets('menampilkan CircleAvatar untuk foto profil', (tester) async {
      await tester.pumpWidget(buildProfileTest());
      await tester.pump();

      expect(find.byType(CircleAvatar), findsAtLeastNWidgets(1));
    });

    testWidgets('menampilkan teks Ubah Foto', (tester) async {
      await tester.pumpWidget(buildProfileTest());
      await tester.pump();

      expect(find.text('Ubah Foto'), findsOneWidget);
    });

    testWidgets('menampilkan section Edit Profil', (tester) async {
      await tester.pumpWidget(buildProfileTest());
      await tester.pump();

      expect(find.text('Edit Profil'), findsOneWidget);
    });

    testWidgets('menampilkan field Nama Lengkap', (tester) async {
      await tester.pumpWidget(buildProfileTest());
      await tester.pump();

      expect(find.widgetWithText(TextFormField, 'Nama Lengkap'), findsOneWidget);
    });

    testWidgets('menampilkan field Username', (tester) async {
      await tester.pumpWidget(buildProfileTest());
      await tester.pump();

      expect(find.widgetWithText(TextFormField, 'Username'), findsOneWidget);
    });

    testWidgets('menampilkan tombol Simpan Profil', (tester) async {
      await tester.pumpWidget(buildProfileTest());
      await tester.pump();

      expect(find.text('Simpan Profil'), findsOneWidget);
    });

    testWidgets('menampilkan section Ganti Kata Sandi', (tester) async {
      await tester.pumpWidget(buildProfileTest());
      await tester.pump();

      expect(find.text('Ganti Kata Sandi'), findsOneWidget);
    });

    testWidgets('menampilkan field Kata Sandi Saat Ini', (tester) async {
      await tester.pumpWidget(buildProfileTest());
      await tester.pump();

      expect(
        find.widgetWithText(TextFormField, 'Kata Sandi Saat Ini'),
        findsOneWidget,
      );
    });

    testWidgets('menampilkan field Kata Sandi Baru', (tester) async {
      await tester.pumpWidget(buildProfileTest());
      await tester.pump();

      expect(
        find.widgetWithText(TextFormField, 'Kata Sandi Baru'),
        findsOneWidget,
      );
    });

    testWidgets('menampilkan field Konfirmasi Kata Sandi Baru', (tester) async {
      await tester.pumpWidget(buildProfileTest());
      await tester.pump();

      expect(
        find.widgetWithText(TextFormField, 'Konfirmasi Kata Sandi Baru'),
        findsOneWidget,
      );
    });

    testWidgets('menampilkan tombol Ganti Kata Sandi', (tester) async {
      await tester.pumpWidget(buildProfileTest());
      await tester.pump();

      expect(find.text('Ganti Kata Sandi'), findsAtLeastNWidgets(1));
    });

    testWidgets('validasi Nama Lengkap kosong menampilkan error', (tester) async {
      await tester.pumpWidget(buildProfileTest());
      await tester.pump();

      // Kosongkan field nama lalu tekan simpan
      await tester.tap(find.widgetWithText(TextFormField, 'Nama Lengkap'));
      await tester.pump();
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama Lengkap'), '');
      await tester.tap(find.text('Simpan Profil'));
      await tester.pump();

      expect(find.text('Nama tidak boleh kosong.'), findsOneWidget);
    });

    testWidgets('validasi Kata Sandi Baru terlalu pendek menampilkan error',
        (tester) async {
      await tester.pumpWidget(buildProfileTest());
      await tester.pump();

      // Isi kata sandi saat ini
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Kata Sandi Saat Ini'), 'rahasia');
      // Isi kata sandi baru terlalu pendek
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Kata Sandi Baru'), '123');
      await tester.tap(find.text('Ganti Kata Sandi').last);
      await tester.pump();

      expect(find.text('Minimal 6 karakter.'), findsOneWidget);
    });

    testWidgets('validasi konfirmasi kata sandi tidak cocok', (tester) async {
      await tester.pumpWidget(buildProfileTest());
      await tester.pump();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Kata Sandi Saat Ini'), 'rahasia');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Kata Sandi Baru'), 'password123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Konfirmasi Kata Sandi Baru'),
          'passwordbeda');
      await tester.tap(find.text('Ganti Kata Sandi').last);
      await tester.pump();

      expect(find.text('Kata sandi tidak cocok.'), findsOneWidget);
    });

    testWidgets('halaman dapat di-scroll', (tester) async {
      await tester.pumpWidget(buildProfileTest());
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('menampilkan menu titik tiga di AppBar', (tester) async {
      await tester.pumpWidget(buildProfileTest());
      await tester.pump();

      expect(find.byType(PopupMenuButton<int>), findsOneWidget);
    });

    testWidgets('membuka menu titik tiga menampilkan opsi Keluar', (tester) async {
      await tester.pumpWidget(buildProfileTest());
      await tester.pump();

      await tester.tap(find.byType(PopupMenuButton<int>));
      await tester.pumpAndSettle();

      expect(find.text('Keluar'), findsAtLeastNWidgets(1));
    });
  });
}
