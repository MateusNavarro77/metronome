import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metronome/domain/models/app_theme_mode.dart';

void main() {
  group('AppThemeMode', () {
    test('contains expected enum values', () {
      check(AppThemeMode.values).deepEquals([
        AppThemeMode.system,
        AppThemeMode.light,
        AppThemeMode.dark,
      ]);
    });

    test('label returns human-readable name', () {
      check(AppThemeMode.system.label).equals('System');
      check(AppThemeMode.light.label).equals('Light');
      check(AppThemeMode.dark.label).equals('Dark');
    });
  });
}
