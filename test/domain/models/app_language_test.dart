import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metronome/domain/models/app_language.dart';

void main() {
  group('AppLanguage', () {
    test('contains expected enum values and codes', () {
      check(AppLanguage.values).deepEquals([
        AppLanguage.system,
        AppLanguage.english,
        AppLanguage.portuguese,
      ]);
      check(AppLanguage.system.code).equals('system');
      check(AppLanguage.english.code).equals('en');
      check(AppLanguage.portuguese.code).equals('pt');
    });

    test('fromCode resolves known codes and defaults to system', () {
      check(AppLanguage.fromCode('en')).equals(AppLanguage.english);
      check(AppLanguage.fromCode('pt')).equals(AppLanguage.portuguese);
      check(AppLanguage.fromCode('system')).equals(AppLanguage.system);
      check(AppLanguage.fromCode(null)).equals(AppLanguage.system);
      check(AppLanguage.fromCode('unknown')).equals(AppLanguage.system);
    });
  });
}
