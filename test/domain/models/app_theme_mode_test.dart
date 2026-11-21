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
  });
}
