import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metronome/data/repositories/metronome_repository.dart';
import 'package:metronome/data/repositories/preferences_repository.dart';
import 'package:metronome/data/services/simulated_metronome_engine.dart';
import 'package:metronome/domain/models/app_language.dart';
import 'package:metronome/domain/models/app_theme_mode.dart';
import 'package:metronome/domain/models/metronome_sound.dart';
import 'package:metronome/domain/models/sound_settings.dart';
import 'package:metronome/domain/models/time_signature.dart';
import 'package:metronome/ui/features/preferences/view_models/preferences_view_model.dart';

void main() {
  group('PreferencesViewModel', () {
    test('initializes with repository theme mode and sound settings', () {
      final repo = PreferencesRepository(preferences: null);
      final engine = SimulatedMetronomeEngine();
      final metronomeRepo = MetronomeRepository(engine: engine);
      final vm = PreferencesViewModel(
        repository: repo,
        metronomeRepository: metronomeRepo,
      );

      check(vm.themeMode).equals(AppThemeMode.system);
      check(vm.materialThemeMode).equals(ThemeMode.system);
      check(vm.language).equals(AppLanguage.system);
      check(vm.materialLocale).isNull();
      check(vm.soundSettings).equals(const SoundSettings());
      check(metronomeRepo.state.soundSettings).equals(const SoundSettings());
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

    test('updates language, resolves Locale, and notifies listeners', () async {
      final repo = PreferencesRepository(preferences: null);
      final vm = PreferencesViewModel(repository: repo);

      var notified = 0;
      vm.addListener(() => notified++);

      await vm.setLanguage(AppLanguage.portuguese);

      check(vm.language).equals(AppLanguage.portuguese);
      check(vm.materialLocale).equals(const Locale('pt'));
      check(repo.getLanguage()).equals(AppLanguage.portuguese);
      check(notified).equals(1);

      await vm.setLanguage(AppLanguage.portuguese);
      check(notified).equals(1);

      await vm.setLanguage(AppLanguage.english);
      check(vm.materialLocale).equals(const Locale('en'));

      await vm.setLanguage(AppLanguage.system);
      check(vm.materialLocale).isNull();
    });

    test('selects sound, syncs to engine, and plays preview when stopped & unmuted', () async {
      final repo = PreferencesRepository(preferences: null);
      final engine = SimulatedMetronomeEngine();
      final metronomeRepo = MetronomeRepository(engine: engine);
      final vm = PreferencesViewModel(
        repository: repo,
        metronomeRepository: metronomeRepo,
      );

      await vm.selectSound(MetronomeSound.woodBlock);

      check(vm.selectedSound).equals(MetronomeSound.woodBlock);
      check(repo.getSoundSettings().sound).equals(MetronomeSound.woodBlock);
      check(metronomeRepo.state.soundSettings.sound)
          .equals(MetronomeSound.woodBlock);
      check(engine.previewedSounds).length.equals(1);
      check(engine.previewedSounds.first.sound)
          .equals(MetronomeSound.woodBlock);
      check(engine.previewedSounds.first.accent).equals(BeatAccent.strong);
      check(engine.previewedSounds.first.volume).equals(1.0);
    });

    test('does not preview sound while playing or when muted', () async {
      final repo = PreferencesRepository(preferences: null);
      final engine = SimulatedMetronomeEngine();
      final metronomeRepo = MetronomeRepository(engine: engine);
      final vm = PreferencesViewModel(
        repository: repo,
        metronomeRepository: metronomeRepo,
      );

      // Muted while stopped: updates timbre, no preview
      await vm.setMuted(true);
      await vm.selectSound(MetronomeSound.beep);
      check(vm.selectedSound).equals(MetronomeSound.beep);
      check(engine.previewedSounds).isEmpty();

      // Unmuted while playing: updates timbre live on engine, no overlapping preview
      await vm.setMuted(false);
      await metronomeRepo.start();
      await vm.selectSound(MetronomeSound.drums);
      check(vm.selectedSound).equals(MetronomeSound.drums);
      check(engine.soundSettings.sound).equals(MetronomeSound.drums);
      check(engine.previewedSounds).isEmpty();

      await metronomeRepo.stop();
    });

    test(
      'updates independent volumes and mute preserving saved levels',
      () async {
        final repo = PreferencesRepository(preferences: null);
        final engine = SimulatedMetronomeEngine();
        final metronomeRepo = MetronomeRepository(engine: engine);
        final vm = PreferencesViewModel(
          repository: repo,
          metronomeRepository: metronomeRepo,
        );

        await vm.setStrongVolume(80);
        await vm.setWeakVolume(45);
        await vm.setSubdivisionVolume(20);

        check(vm.strongVolume).equals(80);
        check(vm.weakVolume).equals(45);
        check(vm.subdivisionVolume).equals(20);
        check(engine.soundSettings).equals(
          const SoundSettings(
            strongVolume: 80,
            weakVolume: 45,
            subdivisionVolume: 20,
          ),
        );

        await vm.setMuted(true);
        check(vm.isMuted).isTrue();
        check(vm.strongVolume).equals(80);
        check(vm.weakVolume).equals(45);
        check(vm.subdivisionVolume).equals(20);
        check(repo.getSoundSettings().isMuted).isTrue();
        check(engine.soundSettings.effectiveVolumeFor(BeatAccent.strong))
            .equals(0.0);
      },
    );
  });
}
