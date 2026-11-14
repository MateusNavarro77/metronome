import 'package:checks/checks.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metronome/data/repositories/preferences_repository.dart';
import 'package:metronome/domain/models/app_theme_mode.dart';
import 'package:metronome/ui/features/preferences/view_models/preferences_view_model.dart';

void main() {
  group('PreferencesViewModel', () {
    test('initializes with repository theme mode', () {
      final repo = PreferencesRepository(preferences: null);
      final vm = PreferencesViewModel(repository: repo);

      check(vm.themeMode).equals(AppThemeMode.system);
      check(vm.materialThemeMode).equals(ThemeMode.system);
    });

    test('updates theme mode and notifies listeners', () async {
      final repo = PreferencesRepository(preferences: null);
      final vm = PreferencesViewModel(repository: repo);

      var notified = 0;
      vm.addListener(() => notified++);

      await vm.setThemeMode(AppThemeMode.light);

      check(vm.themeMode).equals(AppThemeMode.light);
      check(vm.materialThemeMode).equals(ThemeMode.light);
      check(repo.getThemeMode()).equals(AppThemeMode.light);
      check(notified).equals(1);

      // Setting same mode again does not re-notify
      await vm.setThemeMode(AppThemeMode.light);
      check(notified).equals(1);
    });
  });
}
