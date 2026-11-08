import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metronome/data/repositories/preferences_repository.dart';
import 'package:metronome/domain/models/app_theme_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PreferencesRepository', () {
    test(
      'defaults to AppThemeMode.system when no preferences stored',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final repo = PreferencesRepository(preferences: prefs);

        check(repo.getThemeMode()).equals(AppThemeMode.system);
      },
    );

    test(
      'persists and retrieves AppThemeMode.light and AppThemeMode.dark',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final repo = PreferencesRepository(preferences: prefs);

        await repo.setThemeMode(AppThemeMode.light);
        check(repo.getThemeMode()).equals(AppThemeMode.light);

        await repo.setThemeMode(AppThemeMode.dark);
        check(repo.getThemeMode()).equals(AppThemeMode.dark);

        await repo.setThemeMode(AppThemeMode.system);
        check(repo.getThemeMode()).equals(AppThemeMode.system);
      },
    );

    test('functions safely in-memory when SharedPreferences is null', () async {
      final repo = PreferencesRepository(preferences: null);

      check(repo.getThemeMode()).equals(AppThemeMode.system);
      await repo.setThemeMode(AppThemeMode.light);
      check(repo.getThemeMode()).equals(AppThemeMode.light);

      check(repo.getAccentEnabled()).isTrue();
      await repo.setAccentEnabled(false);
      check(repo.getAccentEnabled()).isFalse();
    });

    test('defaults to accent enabled and persists accent preference', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = PreferencesRepository(preferences: prefs);

      check(repo.getAccentEnabled()).isTrue();
      await repo.setAccentEnabled(false);
      check(repo.getAccentEnabled()).isFalse();

      final repo2 = PreferencesRepository(preferences: prefs);
      check(repo2.getAccentEnabled()).isFalse();
    });

    test(
      'defaults to accent enabled and persists accent preference',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final repo = PreferencesRepository(preferences: prefs);

        check(repo.getAccentEnabled()).isTrue();
        await repo.setAccentEnabled(false);
        check(repo.getAccentEnabled()).isFalse();

        final repo2 = PreferencesRepository(preferences: prefs);
        check(repo2.getAccentEnabled()).isFalse();
      },
    );
  });
}
