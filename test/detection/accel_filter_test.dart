import 'package:flutter_test/flutter_test.dart';
import 'package:ski_tracker/core/detection/accel_filter.dart';

void main() {
  group('AccelFilter', () {
    test('first sample passes through unfiltered', () {
      final filter = AccelFilter(alpha: 0.3);
      final result = filter.filter(5.0, 10.0, 15.0);
      expect(result.x, 5.0);
      expect(result.y, 10.0);
      expect(result.z, 15.0);
    });

    test('smooths out noise over multiple samples', () {
      final filter = AccelFilter(alpha: 0.3);

      // Feed steady signal of 10.0 with noise spikes
      filter.filter(10.0, 10.0, 10.0);
      filter.filter(10.0, 10.0, 10.0);
      filter.filter(10.0, 10.0, 10.0);

      // Noise spike
      final afterSpike = filter.filter(20.0, 10.0, 10.0);

      // X should be smoothed — not jumping to 20
      expect(afterSpike.x, lessThan(15.0));
      expect(afterSpike.x, greaterThan(10.0));

      // Y and Z should stay near 10
      expect(afterSpike.y, closeTo(10.0, 0.1));
      expect(afterSpike.z, closeTo(10.0, 0.1));
    });

    test('converges to steady input value', () {
      final filter = AccelFilter(alpha: 0.3);

      // Feed constant value for many iterations
      late ({double x, double y, double z}) result;
      for (int i = 0; i < 50; i++) {
        result = filter.filter(5.0, 5.0, 5.0);
      }

      expect(result.x, closeTo(5.0, 0.01));
      expect(result.y, closeTo(5.0, 0.01));
      expect(result.z, closeTo(5.0, 0.01));
    });

    test('higher alpha means less smoothing', () {
      final smoothFilter = AccelFilter(alpha: 0.1);
      final sharpFilter = AccelFilter(alpha: 0.9);

      // Initial
      smoothFilter.filter(0, 0, 0);
      sharpFilter.filter(0, 0, 0);

      // Step input
      final smoothResult = smoothFilter.filter(10.0, 0, 0);
      final sharpResult = sharpFilter.filter(10.0, 0, 0);

      // Sharp filter should react faster
      expect(sharpResult.x, greaterThan(smoothResult.x));
    });

    test('reset clears state', () {
      final filter = AccelFilter(alpha: 0.3);

      // Build up some history
      for (int i = 0; i < 10; i++) {
        filter.filter(100.0, 100.0, 100.0);
      }

      filter.reset();

      // After reset, first sample should pass through as-is
      final result = filter.filter(1.0, 2.0, 3.0);
      expect(result.x, 1.0);
      expect(result.y, 2.0);
      expect(result.z, 3.0);
    });
  });
}
