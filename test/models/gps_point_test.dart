import 'package:flutter_test/flutter_test.dart';
import 'package:ski_tracker/core/models/gps_point.dart';

void main() {
  group('GpsPoint', () {
    test('haversine distance for known points', () {
      // Paris (48.8566, 2.3522) to London (51.5074, -0.1278)
      // Known distance: ~343 km
      const paris = GpsPoint(
        timestampUs: 0,
        latitude: 48.8566,
        longitude: 2.3522,
        altitude: 0,
        speed: 0,
        bearing: 0,
        accuracy: 0,
      );
      const london = GpsPoint(
        timestampUs: 0,
        latitude: 51.5074,
        longitude: -0.1278,
        altitude: 0,
        speed: 0,
        bearing: 0,
        accuracy: 0,
      );

      final distance = paris.distanceTo(london);
      expect(distance, greaterThan(340000));
      expect(distance, lessThan(346000));
    });

    test('distance to same point is ~0', () {
      const point = GpsPoint(
        timestampUs: 0,
        latitude: 45.0,
        longitude: 6.5,
        altitude: 2000,
        speed: 10,
        bearing: 180,
        accuracy: 5,
      );
      expect(point.distanceTo(point), closeTo(0, 0.1));
    });

    test('short ski distance (~50m)', () {
      const start = GpsPoint(
        timestampUs: 0,
        latitude: 45.00000,
        longitude: 6.50000,
        altitude: 2000,
        speed: 10,
        bearing: 180,
        accuracy: 5,
      );
      const end = GpsPoint(
        timestampUs: 0,
        latitude: 45.00045,
        longitude: 6.50000,
        altitude: 1990,
        speed: 10,
        bearing: 180,
        accuracy: 5,
      );

      final distance = start.distanceTo(end);
      expect(distance, greaterThan(40));
      expect(distance, lessThan(60));
    });
  });
}
