// test/widget_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pam_p8_ifs23008/main.dart';
import 'package:pam_p8_ifs23008/providers/auth_provider.dart';
import 'package:pam_p8_ifs23008/providers/todo_provider.dart';
import 'package:pam_p8_ifs23008/providers/theme_provider.dart';

void main() {
  testWidgets('Aplikasi dapat dirender tanpa error', (WidgetTester tester) async {
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
    await tester.pump();

    // Aplikasi berhasil dirender (tidak ada exception)
    expect(find.byType(DelcomTodosApp), findsOneWidget);
  });
}
