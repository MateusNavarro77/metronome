import 'dart:math' as math;
import 'dart:typed_data';

import '../../domain/models/time_signature.dart';

/// Synthesizes crisp, zero-asset 16-bit mono PCM WAV click samples in memory.
///
/// Generates distinct pitches and harmonic envelopes for each [BeatAccent]
/// (FR-SND-03, NFR-LAT-02):
/// - [BeatAccent.strong]: High-pitched studio click (1600 Hz fundamental + 3200 Hz harmonic transient)
/// - [BeatAccent.medium]: Mid-high group accent (1250 Hz)
/// - [BeatAccent.weak]: Balanced warm pulse (950 Hz)
/// - [BeatAccent.subdivision]: Short soft tick (700 Hz)
class PcmClickSynthesizer {
  const PcmClickSynthesizer({this.sampleRate = 44100});

  final int sampleRate;

  /// Generates a complete RIFF WAV byte buffer for [accent].
  Uint8List buildWavBytes(BeatAccent accent) {
    final (frequency, durationSeconds, amplitude) = switch (accent) {
      BeatAccent.strong => (1600.0, 0.028, 0.95),
      BeatAccent.medium => (1250.0, 0.024, 0.80),
      BeatAccent.weak => (950.0, 0.022, 0.68),
      BeatAccent.subdivision => (700.0, 0.016, 0.42),
    };

    final numSamples = (sampleRate * durationSeconds).round();
    final dataSize = numSamples * 2; // 16-bit mono = 2 bytes per sample
    final totalSize = 44 + dataSize;
    final buffer = ByteData(totalSize);

    // RIFF header
    _writeAscii(buffer, 0, 'RIFF');
    buffer.setUint32(4, totalSize - 8, Endian.little);
    _writeAscii(buffer, 8, 'WAVE');

    // fmt subchunk
    _writeAscii(buffer, 12, 'fmt ');
    buffer.setUint32(16, 16, Endian.little); // PCM chunk size
    buffer.setUint16(20, 1, Endian.little); // AudioFormat 1 = PCM
    buffer.setUint16(22, 1, Endian.little); // NumChannels = 1 (Mono)
    buffer.setUint32(24, sampleRate, Endian.little);
    buffer.setUint32(28, sampleRate * 2, Endian.little); // ByteRate
    buffer.setUint16(32, 2, Endian.little); // BlockAlign
    buffer.setUint16(34, 16, Endian.little); // BitsPerSample

    // data subchunk
    _writeAscii(buffer, 36, 'data');
    buffer.setUint32(40, dataSize, Endian.little);

    // Synthesize exponentially decaying sine + transient click
    for (var i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final progress = i / numSamples;
      // Fast attack (first 1.5 ms) + exponential decay to prevent clicks/pops
      final attack = (t < 0.0015) ? (t / 0.0015) : 1.0;
      final decay = math.exp(-7.5 * progress);
      final envelope = attack * decay * amplitude;

      final fundamental = math.sin(2.0 * math.pi * frequency * t);
      final octaveTransient =
          0.35 *
          math.sin(2.0 * math.pi * (frequency * 2.0) * t) *
          math.exp(-18.0 * progress);
      final sampleValue = ((fundamental + octaveTransient) * envelope).clamp(
        -1.0,
        1.0,
      );
      final pcm16 = (sampleValue * 32767).round().clamp(-32768, 32767);
      buffer.setInt16(44 + i * 2, pcm16, Endian.little);
    }

    return buffer.buffer.asUint8List();
  }

  static void _writeAscii(ByteData data, int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      data.setUint8(offset + i, value.codeUnitAt(i));
    }
  }
}
