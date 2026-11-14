/// Immutable ordered collection of [Preset] identifiers (FR-PRE-06..10, Section 6.2).
///
/// Pure Dart domain model with zero Flutter dependencies (NFR-MAN-01).
class const Setlist({
  required this.id,
  required this.name,
  this.presetIds = const [],
  required this.createdAt,
  required this.updatedAt,
}) {
  final String id;
  final String name;

  /// Ordered list of preset identifiers referencing presets in the library.
  final List<String> presetIds;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Whether [presetId] appears at least once in this setlist (FR-PRE-10).
  bool containsPreset(String presetId) => presetIds.contains(presetId);

  /// Returns a new [Setlist] with all occurrences of [presetId] removed
  /// (Section 6.3).
  Setlist removePresetReferences(
    String presetId, {
    required DateTime updatedAt,
  }) {
    if (!containsPreset(presetId)) return this;
    final remaining = presetIds
        .where((id) => id != presetId)
        .toList(growable: false);
    return copyWith(presetIds: remaining, updatedAt: updatedAt);
  }

  /// Returns a new [Setlist] with the item at [oldIndex] moved to [newIndex],
  /// using `ReorderableListView` index semantics (FR-PRE-07).
  Setlist reorder(int oldIndex, int newIndex, {required DateTime updatedAt}) {
    if (oldIndex < 0 || oldIndex >= presetIds.length) return this;
    var targetIndex = newIndex;
    if (oldIndex < targetIndex) {
      targetIndex -= 1;
    }
    targetIndex = targetIndex.clamp(0, presetIds.length - 1);
    if (oldIndex == targetIndex) return this;

    final next = List<String>.of(presetIds);
    final moved = next.removeAt(oldIndex);
    next.insert(targetIndex, moved);
    return copyWith(
      presetIds: List<String>.unmodifiable(next),
      updatedAt: updatedAt,
    );
  }

  Setlist copyWith({
    String? id,
    String? name,
    List<String>? presetIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Setlist(
      id: id ?? this.id,
      name: name ?? this.name,
      presetIds: presetIds != null
          ? List<String>.unmodifiable(presetIds)
          : this.presetIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Serializes this setlist to a JSON-compatible map.
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'presetIds': presetIds,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Deserializes a [Setlist] from a JSON map with safe validation and fallbacks.
  factory Setlist.fromJson(Map<String, Object?> json) {
    final rawId = json['id'];
    if (rawId is! String || rawId.isEmpty) {
      throw const FormatException('Setlist JSON is missing a valid id.');
    }

    final rawName = json['name'];
    final name = rawName is String && rawName.trim().isNotEmpty
        ? rawName
        : 'Untitled Setlist';

    final rawPresetIds = json['presetIds'];
    final presetIds = rawPresetIds is List<Object?>
        ? List<String>.unmodifiable(
            rawPresetIds.whereType<String>().where((id) => id.isNotEmpty),
          )
        : const <String>[];

    final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final rawCreatedAt = json['createdAt'];
    final createdAt = rawCreatedAt is String
        ? (DateTime.tryParse(rawCreatedAt) ?? epoch)
        : epoch;

    final rawUpdatedAt = json['updatedAt'];
    final updatedAt = rawUpdatedAt is String
        ? (DateTime.tryParse(rawUpdatedAt) ?? createdAt)
        : createdAt;

    return Setlist(
      id: rawId,
      name: name,
      presetIds: presetIds,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setlist &&
          other.id == id &&
          other.name == name &&
          _stringListEquals(other.presetIds, presetIds) &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt);

  @override
  int get hashCode =>
      Object.hash(id, name, Object.hashAll(presetIds), createdAt, updatedAt);
}

bool _stringListEquals(List<String> a, List<String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
