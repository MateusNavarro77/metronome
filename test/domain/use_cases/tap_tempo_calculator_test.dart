import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metronome/domain/models/bpm.dart';
import 'package:metronome/domain/use_cases/tap_tempo_calculator.dart';

void main() {
  group('TapTempoCalculator (FR-TAP-02..05)', () {
    late TapTempoCalculator calculator;

    setUp(() {
      calculator = TapTempoCalculator();
    });

    test(
      'returns null on first tap and computes BPM from the second tap onwards',
      () {
        final first = calculator.registerTap(Duration.zero);
        check(first).isNull();
        check(calculator.tapCount).equals(1);

        // 500 ms interval = 120 BPM
        final second = calculator.registerTap(
          const Duration(milliseconds: 500),
        );
        check(second).equals(const Bpm(120));
        check(calculator.tapCount).equals(2);
      },
    );

    test('averages up to the last 8 taps (7 intervals)', () {
      // First tap at 0ms, then 8 taps spaced at 600ms (100 BPM)
      for (var i = 0; i < 8; i++) {
        calculator.registerTap(Duration(milliseconds: i * 600));
      }
      check(calculator.tapCount).equals(8);

      // Add a 9th tap 600ms later; window stays capped at 8 taps
      final result = calculator.registerTap(
        const Duration(milliseconds: 8 * 600),
      );
      check(calculator.tapCount).equals(8);
      check(result).equals(const Bpm(100));
    });

    test('resets sequence when interval exceeds 2 seconds (FR-TAP-03)', () {
      calculator.registerTap(Duration.zero);
      final second = calculator.registerTap(const Duration(milliseconds: 500));
      check(second).equals(const Bpm(120));

      // Pause of 2001 ms (> 2 seconds) resets sequence
      final afterPause = calculator.registerTap(
        const Duration(milliseconds: 2501),
      );
      check(afterPause).isNull();
      check(calculator.tapCount).equals(1);

      // Next tap 1000 ms later -> 60 BPM
      final resumed = calculator.registerTap(
        const Duration(milliseconds: 3501),
      );
      check(resumed).equals(const Bpm(60));
    });

    test('clamps fast taps to 300 BPM maximum (FR-TAP-04)', () {
      calculator.registerTap(Duration.zero);
      // 100 ms interval = 600 BPM -> clamped to 300 BPM
      final result = calculator.registerTap(const Duration(milliseconds: 100));
      check(result).equals(const Bpm(300));
    });
  });
}
