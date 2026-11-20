import 'dart:io';
import 'dart:typed_data';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metronome/domain/models/metronome_sound.dart';
import 'package:metronome/domain/models/sound_settings.dart';
import 'package:metronome/domain/models/time_signature.dart';

void main() {
  group('MetronomeSound', () {
    test('includes the four required timbres and resolves by id', () {
      check(MetronomeSound.values).deepEquals([
        MetronomeSound.click,
        MetronomeSound.woodBlock,
        MetronomeSound.beep,
        MetronomeSound.drums,
      ]);

      check(MetronomeSound.fromId('click')).equals(MetronomeSound.click);
      check(MetronomeSound.fromId('wood_block'))
          .equals(MetronomeSound.woodBlock);
      check(MetronomeSound.fromId('beep')).equals(MetronomeSound.beep);
      check(MetronomeSound.fromId('drums')).equals(MetronomeSound.drums);
      check(MetronomeSound.fromId('unknown')).equals(MetronomeSound.click);
      check(MetronomeSound.fromId(null)).equals(MetronomeSound.click);
    });

    test('pre-generated WAV assets exist for every timbre and accent', () {
      for (final sound in MetronomeSound.values) {
        for (final accent in BeatAccent.values) {
          final file = File(sound.assetPathFor(accent));
          check(file.existsSync()).isTrue();
          final bytes = file.readAsBytesSync();
          check(bytes.length).isGreaterThan(44);
          final header = String.fromCharCodes(bytes.sublist(0, 4));
          final wave = String.fromCharCodes(bytes.sublist(8, 12));
          check(header).equals('RIFF');
          check(wave).equals('WAVE');
          final data = ByteData.sublistView(bytes);
          check(data.getUint16(20, Endian.little)).equals(1); // PCM
          check(data.getUint16(22, Endian.little)).equals(1); // Mono
        }
      }
    });
  });

  group('SoundSettings', () {
    test('uses expected defaults and clamps out-of-range volumes', () {
      const defaults = SoundSettings();
      check(defaults.sound).equals(MetronomeSound.click);
      check(defaults.strongVolume).equals(100);
      check(defaults.weakVolume).equals(65);
      check(defaults.subdivisionVolume).equals(35);
      check(defaults.isMuted).isFalse();

      final clamped = SoundSettings.clamped(
        sound: MetronomeSound.drums,
        strongVolume: 150,
        weakVolume: -20,
        subdivisionVolume: 80,
        isMuted: false,
      );
      check(clamped.strongVolume).equals(100);
      check(clamped.weakVolume).equals(0);
      check(clamped.subdivisionVolume).equals(80);
    });

    test('computes effective volumes and zeroes output when muted', () {
      const settings = SoundSettings(
        sound: MetronomeSound.woodBlock,
        strongVolume: 90,
        weakVolume: 50,
        subdivisionVolume: 20,
        isMuted: false,
      );

      check(settings.effectiveVolumeFor(BeatAccent.strong)).equals(0.9);
      check(settings.effectiveVolumeFor(BeatAccent.medium)).equals(0.5);
      check(settings.effectiveVolumeFor(BeatAccent.weak)).equals(0.5);
      check(settings.effectiveVolumeFor(BeatAccent.subdivision)).equals(0.2);

      final muted = settings.copyWith(isMuted: true);
      check(muted.strongVolume).equals(90);
      check(muted.weakVolume).equals(50);
      check(muted.subdivisionVolume).equals(20);
      check(muted.effectiveVolumeFor(BeatAccent.strong)).equals(0.0);
      check(muted.effectiveVolumeFor(BeatAccent.medium)).equals(0.0);
      check(muted.effectiveVolumeFor(BeatAccent.weak)).equals(0.0);
      check(muted.effectiveVolumeFor(BeatAccent.subdivision)).equals(0.0);
    });
  });
}
