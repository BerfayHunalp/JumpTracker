import 'package:flutter_test/flutter_test.dart';
import 'package:ski_tracker/core/models/sensor_frame.dart';

void main() {
  group('SensorFrame', () {
    test('accelMagnitude at rest is ~9.81', () {
      const frame = SensorFrame(
        timestampUs: 0,
        accelX: 0,
        accelY: 0,
        accelZ: 9.80665,
      );
      expect(frame.accelMagnitude, closeTo(9.80665, 0.01));
    });

    test('accelG at rest is ~1.0', () {
      const frame = SensorFrame(
        timestampUs: 0,
        accelX: 0,
        accelY: 0,
        accelZ: 9.80665,
      );
      expect(frame.accelG, closeTo(1.0, 0.01));
    });

    test('accelG in freefall is ~0', () {
      const frame = SensorFrame(
        timestampUs: 0,
        accelX: 0,
        accelY: 0,
        accelZ: 0,
      );
      expect(frame.accelG, closeTo(0.0, 0.01));
    });

    test('accelMagnitude with multi-axis input', () {
      const frame = SensorFrame(
        timestampUs: 0,
        accelX: 3.0,
        accelY: 4.0,
        accelZ: 0,
      );
      // sqrt(9 + 16) = 5.0
      expect(frame.accelMagnitude, closeTo(5.0, 0.01));
    });

    test('baroAltitude at sea level pressure', () {
      const frame = SensorFrame(
        timestampUs: 0,
        accelX: 0,
        accelY: 0,
        accelZ: 9.81,
        pressure: 1013.25,
      );
      expect(frame.baroAltitude, closeTo(0, 1));
    });

    test('baroAltitude at mountain pressure (~900hPa ~ 1000m)', () {
      const frame = SensorFrame(
        timestampUs: 0,
        accelX: 0,
        accelY: 0,
        accelZ: 9.81,
        pressure: 900.0,
      );
      // 900 hPa is roughly 1000m altitude
      expect(frame.baroAltitude!, greaterThan(900));
      expect(frame.baroAltitude!, lessThan(1200));
    });

    test('baroAltitude is null when no pressure', () {
      const frame = SensorFrame(
        timestampUs: 0,
        accelX: 0,
        accelY: 0,
        accelZ: 9.81,
      );
      expect(frame.baroAltitude, isNull);
    });

    test('deltaMs computes time difference correctly', () {
      const frame1 = SensorFrame(
        timestampUs: 1000000,
        accelX: 0,
        accelY: 0,
        accelZ: 9.81,
      );
      const frame2 = SensorFrame(
        timestampUs: 1500000,
        accelX: 0,
        accelY: 0,
        accelZ: 9.81,
      );
      expect(frame2.deltaMs(frame1), closeTo(500, 0.1));
    });
  });
}
