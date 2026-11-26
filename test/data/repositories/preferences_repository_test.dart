import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metronome/data/repositories/preferences_repository.dart';
import 'package:metronome/domain/models/app_language.dart';
import 'package:metronome/domain/models/app_theme_mode.dart';
import 'package:metronome/domain/models/metronome_sound.dart';
import 'package:metronome/domain/models/sound_settings.dart';
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

      check(repo.getLanguage()).equals(AppLanguage.system);
      await repo.setLanguage(AppLanguage.portuguese);
      check(repo.getLanguage()).equals(AppLanguage.portuguese);

      check(repo.getAccentEnabled()).isTrue();
      await repo.setAccentEnabled(false);
      check(repo.getAccentEnabled()).isFalse();

      check(repo.getBackgroundPlaybackEnabled()).isTrue();
      await repo.setBackgroundPlaybackEnabled(false);
      check(repo.getBackgroundPlaybackEnabled()).isFalse();

      check(repo.getKeepScreenAwake()).isTrue();
      await repo.setKeepScreenAwake(false);
      check(repo.getKeepScreenAwake()).isFalse();
    });

    test(
      'defaults to keep screen awake enabled and persists across instances',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final repo = PreferencesRepository(preferences: prefs);

        check(repo.getKeepScreenAwake()).isTrue();
        await repo.setKeepScreenAwake(false);
        check(repo.getKeepScreenAwake()).isFalse();

        final repo2 = PreferencesRepository(preferences: prefs);
        check(repo2.getKeepScreenAwake()).isFalse();
      },
    );

    test(
      'defaults to background playback enabled and persists across instances',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final repo = PreferencesRepository(preferences: prefs);

        check(repo.getBackgroundPlaybackEnabled()).isTrue();
        await repo.setBackgroundPlaybackEnabled(false);
        check(repo.getBackgroundPlaybackEnabled()).isFalse();

        final repo2 = PreferencesRepository(preferences: prefs);
        check(repo2.getBackgroundPlaybackEnabled()).isFalse();
      },
    );

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

    test('defaults sound settings and persists across instances', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = PreferencesRepository(preferences: prefs);

      check(repo.getSoundSettings()).equals(const SoundSettings());

      const custom = SoundSettings(
        sound: MetronomeSound.drums,
        strongVolume: 85,
        weakVolume: 40,
        subdivisionVolume: 15,
        isMuted: true,
      );
      await repo.setSoundSettings(custom);
      check(repo.getSoundSettings()).equals(custom);

      final repo2 = PreferencesRepository(preferences: prefs);
      check(repo2.getSoundSettings()).equals(custom);
    });

    test(
      'defaults to AppLanguage.system and persists language choice',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final repo = PreferencesRepository(preferences: prefs);

        check(repo.getLanguage()).equals(AppLanguage.system);

        await repo.setLanguage(AppLanguage.portuguese);
        check(repo.getLanguage()).equals(AppLanguage.portuguese);

        final repo2 = PreferencesRepository(preferences: prefs);
        check(repo2.getLanguage()).equals(AppLanguage.portuguese);

        await repo2.setLanguage(AppLanguage.english);
        check(repo2.getLanguage()).equals(AppLanguage.english);
      },
    );

    test('clamps corrupted persisted volume values safely', () async {
      SharedPreferences.setMockInitialValues({
        'metronome_sound': 'wood_block',
        'sound_strong_volume': 250,
        'sound_weak_volume': -10,
        'sound_subdivision_volume': 55,
        'sound_muted': false,
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = PreferencesRepository(preferences: prefs);

      check(repo.getSoundSettings()).equals(
        const SoundSettings(
          sound: MetronomeSound.woodBlock,
          strongVolume: 100,
          weakVolume: 0,
          subdivisionVolume: 55,
          isMuted: false,
        ),
      );
    });
  });
}
