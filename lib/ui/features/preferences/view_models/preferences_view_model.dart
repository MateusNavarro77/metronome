import 'package:material_ui/material_ui.dart';

import '../../../../data/repositories/metronome_repository.dart';
import '../../../../data/repositories/preferences_repository.dart';
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

/// ViewModel managing state for user preferences: theme mode and sound/volume
/// configuration (FR-CFG-01..04, FR-SND-01..08).
class PreferencesViewModel extends ChangeNotifier {
  PreferencesViewModel({
    required PreferencesRepository repository,
    MetronomeRepository? metronomeRepository,
  }) : _repository = repository,
       _metronomeRepository = metronomeRepository,
       _themeMode = repository.getThemeMode(),
       _soundSettings = repository.getSoundSettings() {
    _metronomeRepository?.setSoundSettings(_soundSettings);
  }

  final PreferencesRepository _repository;
  final MetronomeRepository? _metronomeRepository;
  AppThemeMode _themeMode;
  SoundSettings _soundSettings;

  /// Current active domain [AppThemeMode].
  AppThemeMode get themeMode => _themeMode;

  /// Current active theme as Flutter's [ThemeMode] for `MaterialApp`.
  ThemeMode get materialThemeMode => _themeMode.toMaterialThemeMode;

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

  /// Updates the theme mode, notifies listeners, and persists the choice.
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _repository.setThemeMode(mode);
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
