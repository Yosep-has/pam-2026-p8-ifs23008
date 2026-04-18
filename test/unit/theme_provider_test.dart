// test/unit/theme_provider_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pam_p8_ifs23008/providers/theme_provider.dart';

void main() {
  group('ThemeProvider', () {
    late ThemeProvider provider;

    setUp(() {
      provider = ThemeProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('nilai awal adalah light mode', () {
      expect(provider.isDark, isFalse);
      expect(provider.themeMode, equals(ThemeMode.light));
    });

    test('isDark mengembalikan true setelah toggle', () {
      provider.toggleTheme();
      expect(provider.isDark, isTrue);
    });

    test('themeMode menjadi dark setelah toggle', () {
      provider.toggleTheme();
      expect(provider.themeMode, equals(ThemeMode.dark));
    });

    test('toggle dua kali kembali ke light mode', () {
      provider.toggleTheme();
      provider.toggleTheme();
      expect(provider.isDark, isFalse);
      expect(provider.themeMode, equals(ThemeMode.light));
    });

    test('toggle memanggil listener saat nilai berubah', () {
      int callCount = 0;
      provider.addListener(() => callCount++);

      provider.toggleTheme();
      provider.toggleTheme();

      expect(callCount, equals(2));
    });
  });
}
