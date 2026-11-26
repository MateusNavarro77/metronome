import 'package:sqflite/sqflite.dart';

import '../../../domain/models/bpm.dart';
import '../../../domain/models/preset.dart';
import '../../../domain/models/subdivision.dart';
import '../../../domain/models/time_signature.dart';

/// Data Access Object for the `presets` SQLite table.
class PresetDao {
  const PresetDao(this._db);

  static const String tableName = 'presets';

  static const String colId = 'id';
  static const String colName = 'name';
  static const String colBpm = 'bpm';
  static const String colTimeSignatureNumerator = 'time_signature_numerator';
  static const String colTimeSignatureDenominator =
      'time_signature_denominator';
  static const String colSubdivision = 'subdivision';
  static const String colIsAccentEnabled = 'is_accent_enabled';
  static const String colIsFavorite = 'is_favorite';
  static const String colNote = 'note';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  final Database _db;

  /// Returns all persisted presets.
  Future<List<Preset>> getAll({DatabaseExecutor? executor}) async {
    final db = executor ?? _db;
    final rows = await db.query(tableName);
    return rows.map(fromRow).toList(growable: false);
  }

  /// Finds a single preset by [id], or `null` if not found.
  Future<Preset?> getById(String id, {DatabaseExecutor? executor}) async {
    final db = executor ?? _db;
    final rows = await db.query(
      tableName,
      where: '$colId = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromRow(rows.first);
  }

  /// Inserts a new [preset] row.
  ///
  /// Does not use `ConflictAlgorithm.replace` so existing foreign-key
  /// references in `setlist_presets` are never inadvertently cascaded.
  Future<void> insert(Preset preset, {DatabaseExecutor? executor}) async {
    final db = executor ?? _db;
    await db.insert(tableName, toRow(preset));
  }

  /// Updates an existing [preset] row by its [Preset.id].
  Future<int> update(Preset preset, {DatabaseExecutor? executor}) async {
    final db = executor ?? _db;
    return db.update(
      tableName,
      toRow(preset),
      where: '$colId = ?',
      whereArgs: [preset.id],
    );
  }

  /// Deletes the preset with [id]. Foreign keys cascade its `setlist_presets`
  /// rows automatically when `PRAGMA foreign_keys = ON`.
  Future<int> delete(String id, {DatabaseExecutor? executor}) async {
    final db = executor ?? _db;
    return db.delete(tableName, where: '$colId = ?', whereArgs: [id]);
  }

  /// Converts a [Preset] domain model into a SQLite column map.
  static Map<String, Object?> toRow(Preset preset) => {
    colId: preset.id,
    colName: preset.name,
    colBpm: preset.bpm.value,
    colTimeSignatureNumerator: preset.timeSignature.numerator,
    colTimeSignatureDenominator: preset.timeSignature.denominator,
    colSubdivision: preset.subdivision.name,
    colIsAccentEnabled: preset.isAccentEnabled ? 1 : 0,
    colIsFavorite: preset.isFavorite ? 1 : 0,
    colNote: preset.note,
    colCreatedAt: preset.createdAt.toIso8601String(),
    colUpdatedAt: preset.updatedAt.toIso8601String(),
  };

  /// Converts a SQLite column map into a [Preset] domain model with safe
  /// validation fallbacks.
  static Preset fromRow(Map<String, Object?> row) {
    final id = row[colId] as String;
    final name = row[colName] as String? ?? '';
    final bpmValue = (row[colBpm] as num?)?.round() ?? Bpm.initial.value;
    final rawNumerator =
        (row[colTimeSignatureNumerator] as num?)?.round() ??
        TimeSignature.fourFour.numerator;
    final numerator = rawNumerator.clamp(1, 16);
    final rawDenominator =
        (row[colTimeSignatureDenominator] as num?)?.round() ??
        TimeSignature.fourFour.denominator;
    final denominator = switch (rawDenominator) {
      2 || 4 || 8 || 16 => rawDenominator,
      _ => TimeSignature.fourFour.denominator,
    };

    final rawSubdivision = row[colSubdivision] as String?;
    final subdivision = rawSubdivision != null
        ? Subdivision.values.firstWhere(
            (item) => item.name == rawSubdivision,
            orElse: () => Subdivision.none,
          )
        : Subdivision.none;

    final isAccentEnabled = (row[colIsAccentEnabled] as num? ?? 1) != 0;
    final isFavorite = (row[colIsFavorite] as num? ?? 0) != 0;
    final note = row[colNote] as String? ?? '';

    final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final rawCreatedAt = row[colCreatedAt] as String?;
    final createdAt = rawCreatedAt != null
        ? (DateTime.tryParse(rawCreatedAt) ?? epoch)
        : epoch;
    final rawUpdatedAt = row[colUpdatedAt] as String?;
    final updatedAt = rawUpdatedAt != null
        ? (DateTime.tryParse(rawUpdatedAt) ?? createdAt)
        : createdAt;

    return Preset(
      id: id,
      name: name,
      bpm: Bpm.clamped(bpmValue),
      timeSignature: TimeSignature(numerator, denominator),
      subdivision: subdivision,
      isAccentEnabled: isAccentEnabled,
      isFavorite: isFavorite,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
