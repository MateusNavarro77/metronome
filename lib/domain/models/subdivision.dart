/// Subdivision of each beat into equal parts (FR-SUB-01).
enum const Subdivision(
  final int pulsesPerBeat,
  final String label,
  final String shortLabel,
  final String symbol,
) {
  none(1, 'Quarter', '1x', '♩'),
  eighth(2, 'Eighths', '2x', '♫'),
  triplet(3, 'Triplets', '3x', '♪♪♪'),
  sixteenth(4, 'Sixteenths', '4x', '♬'),
}
