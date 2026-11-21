import 'package:checks/checks.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metronome/domain/models/app_language.dart';
import 'package:metronome/domain/models/app_theme_mode.dart';
import 'package:metronome/domain/models/bpm.dart';
import 'package:metronome/domain/models/metronome_sound.dart';
import 'package:metronome/domain/models/preset.dart';
import 'package:metronome/domain/models/setlist.dart';
import 'package:metronome/domain/models/subdivision.dart';
import 'package:metronome/domain/models/time_signature.dart';
import 'package:metronome/l10n/app_localizations.dart';
import 'package:metronome/ui/core/l10n/l10n_extensions.dart';

void main() {
  group('L10n extensions (EN & PT)', () {
    late AppLocalizations en;
    late AppLocalizations pt;

    setUp(() async {
      en = await AppLocalizations.delegate.load(const Locale('en'));
      pt = await AppLocalizations.delegate.load(const Locale('pt'));
    });

    test('localizes AppThemeMode labels', () {
      check(AppThemeMode.system.localizedLabel(en)).equals('System');
      check(AppThemeMode.light.localizedLabel(en)).equals('Light');
      check(AppThemeMode.dark.localizedLabel(en)).equals('Dark');

      check(AppThemeMode.system.localizedLabel(pt)).equals('Sistema');
      check(AppThemeMode.light.localizedLabel(pt)).equals('Claro');
      check(AppThemeMode.dark.localizedLabel(pt)).equals('Escuro');
    });

    test('localizes AppLanguage labels', () {
      check(AppLanguage.system.localizedLabel(en)).equals('System');
      check(AppLanguage.english.localizedLabel(en)).equals('English');
      check(AppLanguage.portuguese.localizedLabel(en)).equals('Português');

      check(AppLanguage.system.localizedLabel(pt)).equals('Sistema');
      check(AppLanguage.english.localizedLabel(pt)).equals('English');
      check(AppLanguage.portuguese.localizedLabel(pt)).equals('Português');
    });

    test('localizes MetronomeSound labels and descriptions', () {
      check(MetronomeSound.click.localizedLabel(en)).equals('Click');
      check(MetronomeSound.woodBlock.localizedLabel(en)).equals('Wood Block');
      check(MetronomeSound.beep.localizedLabel(en)).equals('Beep');
      check(MetronomeSound.drums.localizedLabel(en)).equals('Drums');

      check(MetronomeSound.click.localizedLabel(pt)).equals('Click');
      check(MetronomeSound.woodBlock.localizedLabel(pt))
          .equals('Bloco de Madeira');
      check(MetronomeSound.beep.localizedLabel(pt)).equals('Bipe');
      check(MetronomeSound.drums.localizedLabel(pt)).equals('Bateria');

      check(MetronomeSound.drums.localizedDescription(pt)).isNotEmpty();
    });

    test('localizes Subdivision and BeatAccent labels', () {
      check(Subdivision.none.localizedLabel(en)).equals('Quarter');
      check(Subdivision.eighth.localizedLabel(en)).equals('Eighths');
      check(Subdivision.triplet.localizedLabel(en)).equals('Triplets');
      check(Subdivision.sixteenth.localizedLabel(en)).equals('Sixteenths');

      check(Subdivision.none.localizedLabel(pt)).equals('Semínima');
      check(Subdivision.eighth.localizedLabel(pt)).equals('Colcheias');
      check(Subdivision.triplet.localizedLabel(pt)).equals('Tercinas');
      check(Subdivision.sixteenth.localizedLabel(pt)).equals('Semicolcheias');

      check(BeatAccent.strong.localizedLabel(en)).equals('Strong');
      check(BeatAccent.medium.localizedLabel(en)).equals('Medium');
      check(BeatAccent.weak.localizedLabel(en)).equals('Weak');
      check(BeatAccent.subdivision.localizedLabel(en)).equals('Subdivision');

      check(BeatAccent.strong.localizedLabel(pt)).equals('Forte');
      check(BeatAccent.medium.localizedLabel(pt)).equals('Médio');
      check(BeatAccent.weak.localizedLabel(pt)).equals('Fraco');
      check(BeatAccent.subdivision.localizedLabel(pt)).equals('Subdivisão');
    });

    test(
      'localizes untitled Preset/Setlist fallback names and copy suffix',
      () {
        final now = DateTime.utc(2026, 11, 1);
        final untitledPreset = Preset(
          id: 'p1',
          name: '',
          bpm: const Bpm(120),
          timeSignature: TimeSignature.fourFour,
          subdivision: Subdivision.none,
          createdAt: now,
          updatedAt: now,
        );
        final untitledSetlist = Setlist(
          id: 's1',
          name: '',
          presetIds: const [],
          createdAt: now,
          updatedAt: now,
        );

        check(untitledPreset.displayName(en)).equals('Untitled Preset');
        check(untitledPreset.displayName(pt)).equals('Preset sem título');
        check(untitledSetlist.displayName(en)).equals('Untitled Setlist');
        check(untitledSetlist.displayName(pt)).equals('Setlist sem título');

        check(en.presetCopyName('Groove')).equals('Groove (Copy)');
        check(pt.presetCopyName('Groove')).equals('Groove (Cópia)');
      },
    );
  });
}
