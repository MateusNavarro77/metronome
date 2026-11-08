/// Accent level of a beat or subdivision click (FR-CMP-02, FR-CMP-05, FR-SUB-02).
enum const BeatAccent(final String label, final double defaultRelativeVolume) {
  /// First beat of the bar (strong accent).
  strong('Strong', 1.0),

  /// Secondary group accent in compound meters (e.g. beat 4 in 6/8).
  medium('Medium', 0.8),

  /// Remaining main beats of the bar (weak beat).
  weak('Weak', 0.65),

  /// Subdivision pulse inside a beat (quietest).
  subdivision('Subdivision', 0.35),
}

/// Musical time signature such as 2/4, 3/4, 4/4, or 6/8 (FR-CMP-01, FR-CMP-03).
class const TimeSignature(final int numerator, final int denominator) {
  this
    : assert(numerator >= 1 && numerator <= 16, 'Numerator must be 1..16'),
      assert(
        denominator == 2 ||
            denominator == 4 ||
            denominator == 8 ||
            denominator == 16,
        'Denominator must be 2, 4, 8, or 16',
      );

  static const TimeSignature twoFour = TimeSignature(2, 4);
  static const TimeSignature threeFour = TimeSignature(3, 4);
  static const TimeSignature fourFour = TimeSignature(4, 4);
  static const TimeSignature sixEight = TimeSignature(6, 8);

  /// Standard preset time signatures required in v1 (FR-CMP-01).
  static const List<TimeSignature> presets = [
    twoFour,
    threeFour,
    fourFour,
    sixEight,
  ];

  /// Whether this time signature is a compound meter (e.g. 6/8, 9/8, 12/8).
  bool get isCompound =>
      denominator == 8 && numerator > 3 && numerator % 3 == 0;

  /// Returns the [BeatAccent] for a 0-based [beatIndex] within the bar.
  ///
  /// Beat 0 is always [BeatAccent.strong]. In compound meters (such as 6/8),
  /// the start of each 3-beat group (e.g. beat index 3) receives
  /// [BeatAccent.medium], and all other beats receive [BeatAccent.weak].
  BeatAccent accentForBeat(int beatIndex) {
    assert(beatIndex >= 0 && beatIndex < numerator);
    if (beatIndex == 0) {
      return BeatAccent.strong;
    }
    if (isCompound && beatIndex % 3 == 0) {
      return BeatAccent.medium;
    }
    return BeatAccent.weak;
  }

  /// Display string such as `'4/4'` or `'6/8'`.
  String get label => '$numerator/$denominator';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimeSignature &&
          other.numerator == numerator &&
          other.denominator == denominator);

  @override
  int get hashCode => Object.hash(numerator, denominator);

  @override
  String toString() => label;
}
