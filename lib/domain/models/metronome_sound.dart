import 'time_signature.dart';

/// Available metronome click timbres (FR-SND-01, FR-SND-02).
///
/// Pure Dart domain enum with zero Flutter dependencies (NFR-MAN-01).
enum const MetronomeSound(
  final String id,
  final String label,
  final String description,
) {
  click('click', 'Click', 'Crisp studio precision click'),
  woodBlock('wood_block', 'Wood Block', 'Warm resonant wooden block'),
  beep('beep', 'Beep', 'Clear digital metronome tone'),
  drums('drums', 'Drums', 'Acoustic kick, rim & hi-hat');

  /// Resolves a [MetronomeSound] from its persisted [id], falling back to
  /// [MetronomeSound.click].
  static MetronomeSound fromId(String? id) {
    return switch (id) {
      'click' => MetronomeSound.click,
      'wood_block' => MetronomeSound.woodBlock,
      'beep' => MetronomeSound.beep,
      'drums' => MetronomeSound.drums,
      _ => MetronomeSound.click,
    };
  }

  /// Asset path for the pre-generated WAV sample matching [accent].
  String assetPathFor(BeatAccent accent) =>
      'assets/sounds/${id}_${accent.name}.wav';
}
