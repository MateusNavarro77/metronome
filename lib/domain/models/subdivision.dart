/// Subdivision of each beat into equal parts (FR-SUB-01).
enum const Subdivision(
  final int pulsesPerBeat,
  final String shortLabel,
  final String symbol,
) {
  none(1, '1x', '♩'),
  eighth(2, '2x', '♫'),
  triplet(3, '3x', '♪♪♪'),
  sixteenth(4, '4x', '♬'),
}
