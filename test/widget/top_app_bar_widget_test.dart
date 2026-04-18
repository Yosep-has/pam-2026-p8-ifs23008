// test/widget/top_app_bar_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pam_p8_ifs23008/providers/theme_provider.dart';
import 'package:pam_p8_ifs23008/shared/widgets/top_app_bar_widget.dart';

Widget buildTestApp({required Widget child}) {
  return ChangeNotifierProvider(
    create: (_) => ThemeProvider(),
    child: MaterialApp(home: child),
  );
}

void main() {
  group('TopAppBarWidget', () {
    testWidgets('menampilkan judul dengan benar', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: const Scaffold(
          appBar: TopAppBarWidget(title: 'Todo Saya'),
          body: SizedBox(),
        ),
      ));
      await tester.pump();

      expect(find.text('Todo Saya'), findsOneWidget);
    });

    testWidgets('tidak menampilkan tombol back secara default', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: const Scaffold(
          appBar: TopAppBarWidget(title: 'Home'),
          body: SizedBox(),
        ),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('menampilkan tombol back saat showBackButton = true',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: const Scaffold(
          appBar: TopAppBarWidget(title: 'Detail Todo', showBackButton: true),
          body: SizedBox(),
        ),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('menampilkan tombol toggle light/dark mode', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: const Scaffold(
          appBar: TopAppBarWidget(title: 'Home'),
          body: SizedBox(),
        ),
      ));
      await tester.pump();

      // Light mode default → ikon light_mode_rounded
      expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    });

    testWidgets('tombol toggle mengubah ikon setelah ditekan', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: const Scaffold(
          appBar: TopAppBarWidget(title: 'Home'),
          body: SizedBox(),
        ),
      ));
      await tester.pump();

      // Awal: light mode
      expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.light_mode_rounded));
      await tester.pumpAndSettle();

      // Setelah toggle: dark mode
      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
    });

    testWidgets('tidak menampilkan tombol search secara default', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: const Scaffold(
          appBar: TopAppBarWidget(title: 'Profil Saya'),
          body: SizedBox(),
        ),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.search), findsNothing);
    });

    testWidgets('menampilkan tombol search saat withSearch = true',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: const Scaffold(
          appBar: TopAppBarWidget(title: 'Todo Saya', withSearch: true),
          body: SizedBox(),
        ),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('menekan tombol search menampilkan TextField', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: const Scaffold(
          appBar: TopAppBarWidget(title: 'Todo Saya', withSearch: true),
          body: SizedBox(),
        ),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('menekan back di mode search menutup search', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: const Scaffold(
          appBar: TopAppBarWidget(title: 'Todo Saya', withSearch: true),
          body: SizedBox(),
        ),
      ));
      await tester.pump();

      // Buka search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);

      // Tutup search via tombol back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
      expect(find.text('Todo Saya'), findsOneWidget);
    });

    testWidgets('mengetik di search field memanggil onSearchChanged',
        (tester) async {
      String result = '';
      await tester.pumpWidget(buildTestApp(
        child: Scaffold(
          appBar: TopAppBarWidget(
            title: 'Todo Saya',
            withSearch: true,
            onSearchChanged: (q) => result = q,
          ),
          body: const SizedBox(),
        ),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pump();

      expect(result, equals('flutter'));
    });
  });
}
