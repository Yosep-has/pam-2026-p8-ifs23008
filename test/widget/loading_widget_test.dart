// test/widget/loading_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pam_p8_ifs23008/shared/widgets/loading_widget.dart';

void main() {
  group('LoadingWidget', () {
    testWidgets('merender tanpa error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingWidget()),
        ),
      );

      expect(find.byType(LoadingWidget), findsOneWidget);
    });

    testWidgets('menampilkan CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingWidget()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('widget berada di posisi tengah layar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingWidget()),
        ),
      );

      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('tidak menampilkan pesan jika message null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingWidget()),
        ),
      );

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('menampilkan pesan jika message diberikan', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingWidget(message: 'Memuat todo...')),
        ),
      );

      expect(find.text('Memuat todo...'), findsOneWidget);
    });
  });
}
