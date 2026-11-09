import 'package:flutter/material.dart';

import '../../../../data/repositories/preferences_repository.dart';
import '../../../../domain/models/app_theme_mode.dart';

/// Mapping extension converting domain [AppThemeMode] to Flutter [ThemeMode].
extension AppThemeModeFlutterMapping on AppThemeMode {
  ThemeMode get toMaterialThemeMode {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}

/// ViewModel managing state for user preferences and the active theme mode.
class PreferencesViewModel extends ChangeNotifier {
  PreferencesViewModel({required PreferencesRepository repository})
    : _repository = repository,
      _themeMode = repository.getThemeMode();

  final PreferencesRepository _repository;
  AppThemeMode _themeMode;

  /// Current active domain [AppThemeMode].
  AppThemeMode get themeMode => _themeMode;

  /// Current active theme as Flutter's [ThemeMode] for `MaterialApp`.
  ThemeMode get materialThemeMode => _themeMode.toMaterialThemeMode;

  /// Updates the theme mode, notifies listeners, and persists the choice.
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _repository.setThemeMode(mode);
  }
}
