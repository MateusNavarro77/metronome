import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/app_theme_mode.dart';

/// Single source of truth for user preferences (FR-CFG-03, FR-CFG-04).
///
/// Accepts an optional [SharedPreferences] instance. If null, operates
/// safely in-memory (useful for unit/widget tests and headless runners).
///
/// Exposes pure domain types and does not depend on Flutter Material (NFR-MAN-01).
class PreferencesRepository {
  PreferencesRepository({SharedPreferences? preferences})
    : _preferences = preferences;

  final SharedPreferences? _preferences;
  AppThemeMode _inMemoryThemeMode = AppThemeMode.system;
  bool _inMemoryAccentEnabled = true;

  static const String _keyThemeMode = 'app_theme_mode';
  static const String _keyAccentEnabled = 'accent_enabled';

  /// Loads the persisted [AppThemeMode], defaulting to [AppThemeMode.system].
  AppThemeMode getThemeMode() {
    final prefs = _preferences;
    if (prefs == null) return _inMemoryThemeMode;

    final raw = prefs.getString(_keyThemeMode);
    switch (raw) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
      default:
        return AppThemeMode.system;
    }
  }

  /// Persists the selected [AppThemeMode].
  Future<void> setThemeMode(AppThemeMode mode) async {
    _inMemoryThemeMode = mode;
    final prefs = _preferences;
    if (prefs == null) return;

    final String value;
    switch (mode) {
      case AppThemeMode.light:
        value = 'light';
        break;
      case AppThemeMode.dark:
        value = 'dark';
        break;
      case AppThemeMode.system:
        value = 'system';
        break;
    }
    await prefs.setString(_keyThemeMode, value);
  }

  /// Loads whether the accented beat is enabled, defaulting to true.
  bool getAccentEnabled() {
    final prefs = _preferences;
    if (prefs == null) return _inMemoryAccentEnabled;
    return prefs.getBool(_keyAccentEnabled) ?? true;
  }

  /// Persists whether the accented beat is enabled.
  Future<void> setAccentEnabled(bool enabled) async {
    _inMemoryAccentEnabled = enabled;
    final prefs = _preferences;
    if (prefs == null) return;
    await prefs.setBool(_keyAccentEnabled, enabled);
  }
}
