import 'dart:math' as math;

/// Raw sensor data captured at a single point in time.
/// This is the input to the jump detection algorithm.
class SensorFrame {
  /// Microseconds since epoch for precise timing
  final int timestampUs;

  /// Accelerometer readings (m/s^2) in device frame
  final double accelX;
  final double accelY;
  final double accelZ;

  /// GPS data (may be null if no fix available at this sample)
  final double? latitude;
  final double? longitude;
  final double? gpsAltitude;
  final double? gpsSpeed; // m/s
  final double? gpsBearing; // degrees
  final double? gpsAccuracy; // meters

  /// Barometric pressure in hPa (may be null if sensor unavailable)
  final double? pressure;

  const SensorFrame({
    required this.timestampUs,
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    this.latitude,
    this.longitude,
    this.gpsAltitude,
    this.gpsSpeed,
    this.gpsBearing,
    this.gpsAccuracy,
    this.pressure,
  });

  /// Total acceleration magnitude (gravity-inclusive).
  /// At rest on Earth this is ~9.81 m/s^2.
  double get accelMagnitude {
    return math.sqrt(accelX * accelX + accelY * accelY + accelZ * accelZ);
  }

  /// Acceleration magnitude in G units (1G = 9.80665 m/s^2).
  /// In freefall this approaches 0. At rest it's ~1.0.
  double get accelG => accelMagnitude / 9.80665;

  /// Estimated altitude from barometric pressure using the
  /// international barometric formula.
  /// Reference: sea level = 1013.25 hPa, temp = 15C.
  double? get baroAltitude {
    if (pressure == null) return null;
    return 44330.0 * (1.0 - math.pow(pressure! / 1013.25, 0.1903));
  }

  /// Duration in microseconds from another frame to this one.
  int deltaUs(SensorFrame other) => timestampUs - other.timestampUs;

  /// Duration in milliseconds from another frame to this one.
  double deltaMs(SensorFrame other) => deltaUs(other) / 1000.0;

  @override
  String toString() =>
      'SensorFrame(t=${timestampUs}us, accel=${accelG.toStringAsFixed(2)}G, '
      'lat=$latitude, lon=$longitude, pressure=$pressure)';
}
