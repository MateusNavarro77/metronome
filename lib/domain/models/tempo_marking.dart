/// Traditional musical tempo markings mapped to BPM ranges (FR-AND-01).
///
/// The ranges follow Section 3.8 of `specs/prd_metronomo.md`:
/// - Largo: 30 to 59
/// - Larghetto: 60 to 65
/// - Adagio: 66 to 75
/// - Andante: 76 to 107
/// - Moderato: 108 to 119
/// - Allegro: 120 to 155
/// - Vivace: 156 to 175
/// - Presto: 176 to 199
/// - Prestissimo: 200 to 300
enum const TempoMarking(
  final String label,
  final int minBpm,
  final int maxBpm,
  final String description,
) {
  largo('Largo', 30, 59, 'Broad and very slow'),
  larghetto('Larghetto', 60, 65, 'Rather broad and slow'),
  adagio('Adagio', 66, 75, 'Slow and stately'),
  andante('Andante', 76, 107, 'At a walking pace'),
  moderato('Moderato', 108, 119, 'Moderate speed'),
  allegro('Allegro', 120, 155, 'Fast, quickly, and bright'),
  vivace('Vivace', 156, 175, 'Lively and fast'),
  presto('Presto', 176, 199, 'Very fast'),
  prestissimo('Prestissimo', 200, 300, 'Extremely fast');

  /// Resolves the [TempoMarking] corresponding to a given [bpm] value.
  ///
  /// Values outside [30, 300] are clamped to the nearest boundary marking.
  static TempoMarking fromBpm(int bpm) => switch (bpm) {
    <= 59 => TempoMarking.largo,
    <= 65 => TempoMarking.larghetto,
    <= 75 => TempoMarking.adagio,
    <= 107 => TempoMarking.andante,
    <= 119 => TempoMarking.moderato,
    <= 155 => TempoMarking.allegro,
    <= 175 => TempoMarking.vivace,
    <= 199 => TempoMarking.presto,
    _ => TempoMarking.prestissimo,
  };
}
