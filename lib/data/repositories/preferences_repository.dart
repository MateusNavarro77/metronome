import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/app_theme_mode.dart';
import '../../domain/models/metronome_sound.dart';
import '../../domain/models/sound_settings.dart';

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
  SoundSettings _inMemorySoundSettings = const SoundSettings();

  static const String _keyThemeMode = 'app_theme_mode';
  static const String _keyAccentEnabled = 'accent_enabled';
  static const String _keySound = 'metronome_sound';
  static const String _keyStrongVolume = 'sound_strong_volume';
  static const String _keyWeakVolume = 'sound_weak_volume';
  static const String _keySubdivisionVolume = 'sound_subdivision_volume';
  static const String _keyMuted = 'sound_muted';

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

  /// Loads persisted [SoundSettings], falling back to defaults (FR-SND-01..08, FR-CFG-03).
  SoundSettings getSoundSettings() {
    final prefs = _preferences;
    if (prefs == null) return _inMemorySoundSettings;

    final sound = MetronomeSound.fromId(prefs.getString(_keySound));
    final strongVolume =
        prefs.getInt(_keyStrongVolume) ?? SoundSettings.defaultStrongVolume;
    final weakVolume =
        prefs.getInt(_keyWeakVolume) ?? SoundSettings.defaultWeakVolume;
    final subdivisionVolume =
        prefs.getInt(_keySubdivisionVolume) ??
        SoundSettings.defaultSubdivisionVolume;
    final isMuted = prefs.getBool(_keyMuted) ?? false;

    return SoundSettings.clamped(
      sound: sound,
      strongVolume: strongVolume,
      weakVolume: weakVolume,
      subdivisionVolume: subdivisionVolume,
      isMuted: isMuted,
    );
  }

  /// Persists [SoundSettings] to local storage.
  Future<void> setSoundSettings(SoundSettings settings) async {
    _inMemorySoundSettings = settings;
    final prefs = _preferences;
    if (prefs == null) return;

    await prefs.setString(_keySound, settings.sound.id);
    await prefs.setInt(_keyStrongVolume, settings.strongVolume);
    await prefs.setInt(_keyWeakVolume, settings.weakVolume);
    await prefs.setInt(_keySubdivisionVolume, settings.subdivisionVolume);
    await prefs.setBool(_keyMuted, settings.isMuted);
  }
}
