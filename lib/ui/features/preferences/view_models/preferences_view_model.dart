import 'package:material_ui/material_ui.dart';

import '../../../../data/repositories/metronome_repository.dart';
import '../../../../data/repositories/preferences_repository.dart';
import '../../../../data/services/background_playback_coordinator.dart';
import '../../../../domain/models/app_language.dart';
import '../../../../domain/models/app_theme_mode.dart';
import '../../../../domain/models/metronome_sound.dart';
import '../../../../domain/models/sound_settings.dart';
import '../../../../domain/models/time_signature.dart';

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

/// Mapping extension converting domain [AppLanguage] to Flutter [Locale].
extension AppLanguageFlutterMapping on AppLanguage {
  Locale? get toMaterialLocale {
    return switch (this) {
      AppLanguage.system => null,
      AppLanguage.english => const Locale('en'),
      AppLanguage.portuguese => const Locale('pt'),
    };
  }
}

/// ViewModel managing state for user preferences: theme mode, language, and
/// sound/volume configuration (FR-CFG-01..04, FR-SND-01..08).
class PreferencesViewModel extends ChangeNotifier {
  PreferencesViewModel({
    required PreferencesRepository repository,
    MetronomeRepository? metronomeRepository,
    BackgroundPlaybackCoordinator? backgroundPlaybackCoordinator,
  }) : _repository = repository,
       _metronomeRepository = metronomeRepository,
       _backgroundPlaybackCoordinator = backgroundPlaybackCoordinator,
       _themeMode = repository.getThemeMode(),
       _language = repository.getLanguage(),
       _soundSettings = repository.getSoundSettings(),
       _isBackgroundPlaybackEnabled = repository
           .getBackgroundPlaybackEnabled() {
    _metronomeRepository?.setSoundSettings(_soundSettings);
  }

  final PreferencesRepository _repository;
  final MetronomeRepository? _metronomeRepository;
  final BackgroundPlaybackCoordinator? _backgroundPlaybackCoordinator;
  AppThemeMode _themeMode;
  AppLanguage _language;
  SoundSettings _soundSettings;
  bool _isBackgroundPlaybackEnabled;

  /// Current active domain [AppThemeMode].
  AppThemeMode get themeMode => _themeMode;

  /// Current active theme as Flutter's [ThemeMode] for `MaterialApp`.
  ThemeMode get materialThemeMode => _themeMode.toMaterialThemeMode;

  /// Current active domain [AppLanguage].
  AppLanguage get language => _language;

  /// Current active [Locale] override for `MaterialApp`, or `null` for system.
  Locale? get materialLocale => _language.toMaterialLocale;

  /// Current [SoundSettings] snapshot.
  SoundSettings get soundSettings => _soundSettings;

  /// Selected metronome timbre.
  MetronomeSound get selectedSound => _soundSettings.sound;

  /// Strong-beat volume (`0..100`).
  int get strongVolume => _soundSettings.strongVolume;

  /// Weak-beat volume (`0..100`).
  int get weakVolume => _soundSettings.weakVolume;

  /// Subdivision volume (`0..100`).
  int get subdivisionVolume => _soundSettings.subdivisionVolume;

  /// Whether audio playback is muted while visual feedback remains active.
  bool get isMuted => _soundSettings.isMuted;

  /// Whether playback continues in the background with media notification controls.
  bool get isBackgroundPlaybackEnabled => _isBackgroundPlaybackEnabled;

  /// Enables or disables background playback and media notification controls.
  Future<void> setBackgroundPlaybackEnabled(bool enabled) async {
    if (_isBackgroundPlaybackEnabled == enabled) return;
    _isBackgroundPlaybackEnabled = enabled;
    notifyListeners();
    await _repository.setBackgroundPlaybackEnabled(enabled);
    await _backgroundPlaybackCoordinator?.setBackgroundPlaybackEnabled(enabled);
  }

  /// Updates the theme mode, notifies listeners, and persists the choice.
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _repository.setThemeMode(mode);
  }

  /// Updates the app language, notifies listeners, and persists the choice.
  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language) return;
    _language = language;
    notifyListeners();
    await _repository.setLanguage(language);
  }

  /// Selects a [MetronomeSound], persists it, applies it to the engine, and
  /// plays a short strong-beat preview when stopped and not muted (FR-SND-02, FR-SND-07).
  Future<void> selectSound(MetronomeSound sound) async {
    if (_soundSettings.sound != sound) {
      await _updateSoundSettings(_soundSettings.copyWith(sound: sound));
    }

    final isPlaying = _metronomeRepository?.state.isPlaying ?? false;
    if (!isPlaying && !_soundSettings.isMuted) {
      final previewVolume = _soundSettings.effectiveVolumeFor(
        BeatAccent.strong,
      );
      if (previewVolume > 0.0) {
        await _metronomeRepository?.previewSound(
          sound: sound,
          accent: BeatAccent.strong,
          volume: previewVolume,
        );
      }
    }
  }

  /// Updates the strong-beat volume percentage (`0..100`) (FR-SND-04).
  Future<void> setStrongVolume(int volume) =>
      _updateSoundSettings(_soundSettings.copyWith(strongVolume: volume));

  /// Updates the weak-beat volume percentage (`0..100`) (FR-SND-04).
  Future<void> setWeakVolume(int volume) =>
      _updateSoundSettings(_soundSettings.copyWith(weakVolume: volume));

  /// Updates the subdivision volume percentage (`0..100`) (FR-SND-04).
  Future<void> setSubdivisionVolume(int volume) =>
      _updateSoundSettings(_soundSettings.copyWith(subdivisionVolume: volume));

  /// Enables or disables mute mode while preserving saved volume levels (FR-SND-08).
  Future<void> setMuted(bool muted) =>
      _updateSoundSettings(_soundSettings.copyWith(isMuted: muted));

  Future<void> _updateSoundSettings(SoundSettings next) async {
    if (_soundSettings == next) return;
    _soundSettings = next;
    _metronomeRepository?.setSoundSettings(next);
    notifyListeners();
    await _repository.setSoundSettings(next);
  }
}
