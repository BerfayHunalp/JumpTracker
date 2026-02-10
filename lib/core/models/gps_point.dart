import 'dart:math' as math;

/// A single GPS track point recorded during a session.
class GpsPoint {
  final int timestampUs;
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed; // m/s
  final double bearing; // degrees
  final double accuracy; // meters
  final String? runId;

  const GpsPoint({
    required this.timestampUs,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.bearing,
    required this.accuracy,
    this.runId,
  });

  /// Haversine distance to another point in meters.
  double distanceTo(GpsPoint other) {
    const R = 6371000.0; // Earth radius in meters
    final dLat = _toRad(other.latitude - latitude);
    final dLon = _toRad(other.longitude - longitude);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(latitude)) *
            math.cos(_toRad(other.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  static double _toRad(double deg) => deg * math.pi / 180;
}
