import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const int _sampleRate = 44100;

void main() {
  final outDir = Directory('assets/sounds');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  final generators = <String, List<double> Function(String accent)>{
    'click': _synthesizeClick,
    'wood_block': _synthesizeWoodBlock,
    'beep': _synthesizeBeep,
    'drums': _synthesizeDrums,
  };

  const accents = ['strong', 'medium', 'weak', 'subdivision'];

  for (final entry in generators.entries) {
    final sound = entry.key;
    final synthesize = entry.value;
    for (final accent in accents) {
      final samples = synthesize(accent);
      final normalized = _normalizeAndFade(samples, targetPeak: 0.90);
      final wavBytes = _encodeWav16Mono(normalized, _sampleRate);
      final path = 'assets/sounds/${sound}_$accent.wav';
      File(path).writeAsBytesSync(wavBytes, flush: true);
      stdout.writeln(
        'Generated $path (${normalized.length} samples, ${wavBytes.length} bytes)',
      );
    }
  }
}

List<double> _synthesizeClick(String accent) {
  final (freq, durationSec) = switch (accent) {
    'strong' => (1600.0, 0.030),
    'medium' => (1250.0, 0.026),
    'weak' => (950.0, 0.024),
    'subdivision' => (700.0, 0.018),
    _ => throw ArgumentError('Unknown accent: $accent'),
  };

  final count = (_sampleRate * durationSec).round();
  return List<double>.generate(count, (i) {
    final t = i / _sampleRate;
    final progress = i / count;
    final attack = t < 0.0012 ? (t / 0.0012) : 1.0;
    final decay = math.exp(-7.5 * progress);
    final fundamental = math.sin(2.0 * math.pi * freq * t);
    final transient =
        0.35 *
        math.sin(2.0 * math.pi * (freq * 2.0) * t) *
        math.exp(-18.0 * progress);
    return (fundamental + transient) * attack * decay;
  });
}

List<double> _synthesizeWoodBlock(String accent) {
  final (baseFreq, durationSec) = switch (accent) {
    'strong' => (1180.0, 0.048),
    'medium' => (980.0, 0.044),
    'weak' => (800.0, 0.040),
    'subdivision' => (640.0, 0.032),
    _ => throw ArgumentError('Unknown accent: $accent'),
  };

  final count = (_sampleRate * durationSec).round();
  final rng = _LcgRandom(42 + baseFreq.round());
  var prevNoise = 0.0;

  return List<double>.generate(count, (i) {
    final t = i / _sampleRate;
    final progress = i / count;
    final attack = t < 0.0010 ? (t / 0.0010) : 1.0;

    // Hollow wooden modal partials (inharmonic ratios characteristic of wood)
    final mode1 =
        math.sin(2.0 * math.pi * baseFreq * t) * math.exp(-8.0 * progress);
    final mode2 =
        0.48 *
        math.sin(2.0 * math.pi * (baseFreq * 1.47) * t) *
        math.exp(-12.5 * progress);
    final mode3 =
        0.24 *
        math.sin(2.0 * math.pi * (baseFreq * 2.21) * t) *
        math.exp(-18.0 * progress);

    // Short mallet impact transient
    final rawNoise = rng.nextSigned();
    final filteredNoise = rawNoise - 0.65 * prevNoise;
    prevNoise = rawNoise;
    final mallet = 0.35 * filteredNoise * math.exp(-55.0 * progress);

    return (mode1 + mode2 + mode3 + mallet) * attack;
  });
}

List<double> _synthesizeBeep(String accent) {
  final (freq, durationSec) = switch (accent) {
    'strong' => (1760.0, 0.055), // A6
    'medium' => (1318.51, 0.048), // E6
    'weak' => (880.0, 0.045), // A5
    'subdivision' => (659.25, 0.036), // E5
    _ => throw ArgumentError('Unknown accent: $accent'),
  };

  final count = (_sampleRate * durationSec).round();
  final attackSamples = (_sampleRate * 0.0025).round();
  final releaseSamples = (_sampleRate * 0.012).round();

  return List<double>.generate(count, (i) {
    final t = i / _sampleRate;
    var env = 1.0;
    if (i < attackSamples) {
      env = 0.5 * (1.0 - math.cos(math.pi * i / attackSamples));
    } else if (i > count - releaseSamples) {
      final rem = (count - i).clamp(0, releaseSamples);
      env = 0.5 * (1.0 - math.cos(math.pi * rem / releaseSamples));
    }
    final decay = math.exp(-3.0 * (i / count));
    final fundamental = math.sin(2.0 * math.pi * freq * t);
    final softHarmonic = 0.10 * math.sin(2.0 * math.pi * (freq * 3.0) * t);
    return (fundamental + softHarmonic) * env * decay;
  });
}

List<double> _synthesizeDrums(String accent) {
  final rng = _LcgRandom(1337 + accent.hashCode);
  switch (accent) {
    case 'strong':
      // Kick + crisp stick click
      const durationSec = 0.085;
      final count = (_sampleRate * durationSec).round();
      var phase = 0.0;
      return List<double>.generate(count, (i) {
        final t = i / _sampleRate;
        final progress = i / count;
        final instFreq = 52.0 + 140.0 * math.exp(-42.0 * t);
        phase += 2.0 * math.pi * instFreq / _sampleRate;
        final body = math.sin(phase) * math.exp(-5.2 * progress);
        final beater =
            0.45 *
            math.sin(2.0 * math.pi * 1750.0 * t) *
            math.exp(-35.0 * progress);
        final snap = 0.25 * rng.nextSigned() * math.exp(-50.0 * progress);
        final attack = t < 0.0008 ? (t / 0.0008) : 1.0;
        return (body + beater + snap) * attack;
      });

    case 'medium':
      // Cross-stick / rim click
      const durationSec = 0.050;
      final count = (_sampleRate * durationSec).round();
      var prev = 0.0;
      return List<double>.generate(count, (i) {
        final t = i / _sampleRate;
        final progress = i / count;
        final m1 =
            math.sin(2.0 * math.pi * 440.0 * t) * math.exp(-9.0 * progress);
        final m2 =
            0.65 *
            math.sin(2.0 * math.pi * 920.0 * t) *
            math.exp(-13.0 * progress);
        final m3 =
            0.40 *
            math.sin(2.0 * math.pi * 1580.0 * t) *
            math.exp(-18.0 * progress);
        final raw = rng.nextSigned();
        final hp = raw - 0.8 * prev;
        prev = raw;
        final crack = 0.35 * hp * math.exp(-32.0 * progress);
        final attack = t < 0.0006 ? (t / 0.0006) : 1.0;
        return (m1 + m2 + m3 + crack) * attack;
      });

    case 'weak':
      // Tight snare / side stick
      const durationSec = 0.058;
      final count = (_sampleRate * durationSec).round();
      var prev = 0.0;
      return List<double>.generate(count, (i) {
        final t = i / _sampleRate;
        final progress = i / count;
        final shell =
            0.65 *
            math.sin(2.0 * math.pi * 215.0 * t) *
            math.exp(-9.5 * progress);
        final overtone =
            0.30 *
            math.sin(2.0 * math.pi * 380.0 * t) *
            math.exp(-14.0 * progress);
        final raw = rng.nextSigned();
        final snareNoise = raw - 0.72 * prev;
        prev = raw;
        final wires = 0.55 * snareNoise * math.exp(-11.0 * progress);
        final attack = t < 0.0008 ? (t / 0.0008) : 1.0;
        return (shell + overtone + wires) * attack;
      });

    case 'subdivision':
      // Tight closed hi-hat
      const durationSec = 0.032;
      final count = (_sampleRate * durationSec).round();
      var prev1 = 0.0;
      var prev2 = 0.0;
      return List<double>.generate(count, (i) {
        final t = i / _sampleRate;
        final progress = i / count;
        final metallic =
            0.25 * math.sin(2.0 * math.pi * 3120.0 * t) +
            0.22 * math.sin(2.0 * math.pi * 4480.0 * t) +
            0.18 * math.sin(2.0 * math.pi * 6190.0 * t) +
            0.15 * math.sin(2.0 * math.pi * 8110.0 * t);
        final raw = rng.nextSigned();
        final hp1 = raw - prev1;
        final hp2 = hp1 - 0.75 * prev2;
        prev1 = raw;
        prev2 = hp1;
        final sizzle = 0.75 * hp2;
        final attack = t < 0.0005 ? (t / 0.0005) : 1.0;
        return (metallic + sizzle) * attack * math.exp(-10.5 * progress);
      });

    default:
      throw ArgumentError('Unknown accent: $accent');
  }
}

List<double> _normalizeAndFade(
  List<double> samples, {
  required double targetPeak,
}) {
  var maxAbs = 0.0;
  for (final s in samples) {
    final a = s.abs();
    if (a > maxAbs) maxAbs = a;
  }
  final gain = maxAbs > 0 ? (targetPeak / maxAbs) : 1.0;
  final fadeTail = math.min(samples.length, (_sampleRate * 0.004).round());

  return List<double>.generate(samples.length, (i) {
    var value = samples[i] * gain;
    if (i >= samples.length - fadeTail) {
      final rem = samples.length - 1 - i;
      value *= rem / fadeTail;
    }
    return value.clamp(-1.0, 1.0);
  });
}

Uint8List _encodeWav16Mono(List<double> samples, int sampleRate) {
  final dataSize = samples.length * 2;
  final totalSize = 44 + dataSize;
  final buffer = ByteData(totalSize);

  _writeAscii(buffer, 0, 'RIFF');
  buffer.setUint32(4, totalSize - 8, Endian.little);
  _writeAscii(buffer, 8, 'WAVE');

  _writeAscii(buffer, 12, 'fmt ');
  buffer.setUint32(16, 16, Endian.little);
  buffer.setUint16(20, 1, Endian.little);
  buffer.setUint16(22, 1, Endian.little);
  buffer.setUint32(24, sampleRate, Endian.little);
  buffer.setUint32(28, sampleRate * 2, Endian.little);
  buffer.setUint16(32, 2, Endian.little);
  buffer.setUint16(34, 16, Endian.little);

  _writeAscii(buffer, 36, 'data');
  buffer.setUint32(40, dataSize, Endian.little);

  for (var i = 0; i < samples.length; i++) {
    final pcm16 = (samples[i] * 32767).round().clamp(-32768, 32767);
    buffer.setInt16(44 + i * 2, pcm16, Endian.little);
  }

  return buffer.buffer.asUint8List();
}

void _writeAscii(ByteData data, int offset, String value) {
  for (var i = 0; i < value.length; i++) {
    data.setUint8(offset + i, value.codeUnitAt(i));
  }
}

class _LcgRandom {
  _LcgRandom(this._state);
  int _state;

  double nextSigned() {
    _state = (_state * 1664525 + 1013904223) & 0x7fffffff;
    return (_state / 0x3fffffff) - 1.0;
  }
}
