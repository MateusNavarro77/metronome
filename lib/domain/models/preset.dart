import 'bpm.dart';
import 'subdivision.dart';
import 'time_signature.dart';

/// Immutable saved metronome configuration (FR-PRE-01..05, FR-PRE-11, Section 6.2).
///
/// Pure Dart domain model with zero Flutter dependencies (NFR-MAN-01).
class const Preset({
  required this.id,
  required this.name,
  required this.bpm,
  required this.timeSignature,
  required this.subdivision,
  this.isAccentEnabled = true,
  this.isFavorite = false,
  this.note = '',
  required this.createdAt,
  required this.updatedAt,
}) {
  final String id;
  final String name;
  final Bpm bpm;
  final TimeSignature timeSignature;
  final Subdivision subdivision;
  final bool isAccentEnabled;
  final bool isFavorite;

  /// Optional free-text performance or rehearsal note (FR-PRE-11).
  final String note;

  final DateTime createdAt;
  final DateTime updatedAt;

  Preset copyWith({
    String? id,
    String? name,
    Bpm? bpm,
    TimeSignature? timeSignature,
    Subdivision? subdivision,
    bool? isAccentEnabled,
    bool? isFavorite,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Preset(
      id: id ?? this.id,
      name: name ?? this.name,
      bpm: bpm ?? this.bpm,
      timeSignature: timeSignature ?? this.timeSignature,
      subdivision: subdivision ?? this.subdivision,
      isAccentEnabled: isAccentEnabled ?? this.isAccentEnabled,
      isFavorite: isFavorite ?? this.isFavorite,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Serializes this preset to a JSON-compatible map.
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'bpm': bpm.value,
    'timeSignatureNumerator': timeSignature.numerator,
    'timeSignatureDenominator': timeSignature.denominator,
    'subdivision': subdivision.name,
    'isAccentEnabled': isAccentEnabled,
    'isFavorite': isFavorite,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Deserializes a [Preset] from a JSON map with safe validation and fallbacks.
  factory Preset.fromJson(Map<String, Object?> json) {
    final rawId = json['id'];
    if (rawId is! String || rawId.isEmpty) {
      throw const FormatException('Preset JSON is missing a valid id.');
    }

    final rawName = json['name'];
    final name = rawName is String && rawName.trim().isNotEmpty
        ? rawName
        : 'Untitled Preset';

    final rawBpm = json['bpm'];
    final bpm = switch (rawBpm) {
      final int value => Bpm.clamped(value),
      final num value => Bpm.clamped(value.round()),
      _ => Bpm.initial,
    };

    final rawNumerator = json['timeSignatureNumerator'];
    final numerator = switch (rawNumerator) {
      final int value => value.clamp(1, 16),
      final num value => value.round().clamp(1, 16),
      _ => TimeSignature.fourFour.numerator,
    };

    final rawDenominator = json['timeSignatureDenominator'];
    final denominatorInt = switch (rawDenominator) {
      final int value => value,
      final num value => value.round(),
      _ => TimeSignature.fourFour.denominator,
    };
    final denominator = switch (denominatorInt) {
      2 || 4 || 8 || 16 => denominatorInt,
      _ => TimeSignature.fourFour.denominator,
    };

    final rawSubdivision = json['subdivision'];
    final subdivision = rawSubdivision is String
        ? Subdivision.values.firstWhere(
            (item) => item.name == rawSubdivision,
            orElse: () => Subdivision.none,
          )
        : Subdivision.none;

    final rawAccent = json['isAccentEnabled'];
    final isAccentEnabled = rawAccent is bool ? rawAccent : true;

    final rawFavorite = json['isFavorite'];
    final isFavorite = rawFavorite is bool ? rawFavorite : false;

    final rawNote = json['note'];
    final note = rawNote is String ? rawNote : '';

    final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final rawCreatedAt = json['createdAt'];
    final createdAt = rawCreatedAt is String
        ? (DateTime.tryParse(rawCreatedAt) ?? epoch)
        : epoch;

    final rawUpdatedAt = json['updatedAt'];
    final updatedAt = rawUpdatedAt is String
        ? (DateTime.tryParse(rawUpdatedAt) ?? createdAt)
        : createdAt;

    return Preset(
      id: rawId,
      name: name,
      bpm: bpm,
      timeSignature: TimeSignature(numerator, denominator),
      subdivision: subdivision,
      isAccentEnabled: isAccentEnabled,
      isFavorite: isFavorite,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Preset &&
          other.id == id &&
          other.name == name &&
          other.bpm == bpm &&
          other.timeSignature == timeSignature &&
          other.subdivision == subdivision &&
          other.isAccentEnabled == isAccentEnabled &&
          other.isFavorite == isFavorite &&
          other.note == note &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    bpm,
    timeSignature,
    subdivision,
    isAccentEnabled,
    isFavorite,
    note,
    createdAt,
    updatedAt,
  );
}
