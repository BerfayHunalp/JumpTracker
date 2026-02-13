import 'dart:math' as math;

/// Lightweight Kalman filter for GPS position smoothing.
///
/// Maintains a 4-state vector [lat, lon, vLat, vLon] and uses
/// reported GPS accuracy to weight corrections. Reduces GPS jitter
/// while preserving true movement during skiing/riding.
class GpsKalmanFilter {
  // State: [latitude, longitude, velocity_lat (deg/s), velocity_lon (deg/s)]
  double _lat = 0;
  double _lon = 0;
  double _vLat = 0;
  double _vLon = 0;

  // Covariance diagonal (simplified — uncorrelated states)
  double _pLat = 1000;
  double _pLon = 1000;
  double _pVLat = 1000;
  double _pVLon = 1000;

  /// Process noise per second — models how much we expect position to change
  /// unexpectedly. Higher = trusts GPS more, lower = smoother output.
  static const double _qPos = 3e-10; // ~0.02m/s drift in degrees
  static const double _qVel = 1e-8; // velocity can change (acceleration)

  int _lastTimestampUs = 0;
  bool _initialized = false;

  /// Smoothed latitude after last update.
  double get latitude => _lat;

  /// Smoothed longitude after last update.
  double get longitude => _lon;

  /// Smoothed speed in m/s.
  double get speedMs {
    // Convert velocity from deg/s to m/s
    final vLatMs = _vLat * 111320; // 1 deg lat ≈ 111,320 m
    final vLonMs = _vLon * 111320 * math.cos(_lat * math.pi / 180);
    return math.sqrt(vLatMs * vLatMs + vLonMs * vLonMs);
  }

  /// Smoothed bearing in degrees (0-360).
  double get bearing {
    final vLatMs = _vLat * 111320;
    final vLonMs = _vLon * 111320 * math.cos(_lat * math.pi / 180);
    if (vLatMs == 0 && vLonMs == 0) return 0;
    final rad = math.atan2(vLonMs, vLatMs);
    return (rad * 180 / math.pi + 360) % 360;
  }

  /// Feed a new GPS reading. Returns smoothed position.
  ({double lat, double lon, double speedMs, double bearing}) update({
    required double latitude,
    required double longitude,
    required double accuracyM,
    required double speedMs,
    required double speedAccuracyMs,
    required double bearingDeg,
    required int timestampUs,
  }) {
    if (!_initialized) {
      _lat = latitude;
      _lon = longitude;
      _lastTimestampUs = timestampUs;
      _initialized = true;

      // Initialize velocity from GPS speed + bearing
      final bearingRad = bearingDeg * math.pi / 180;
      final speedDegPerS = speedMs / 111320;
      _vLat = speedDegPerS * math.cos(bearingRad);
      _vLon = speedDegPerS * math.sin(bearingRad) /
          math.cos(latitude * math.pi / 180);

      return (
        lat: _lat,
        lon: _lon,
        speedMs: speedMs,
        bearing: bearing,
      );
    }

    final dt = (timestampUs - _lastTimestampUs) / 1e6; // seconds
    _lastTimestampUs = timestampUs;

    if (dt <= 0 || dt > 10) {
      // Bad timestamp gap — reset
      _lat = latitude;
      _lon = longitude;
      _pLat = 1000;
      _pLon = 1000;
      _pVLat = 1000;
      _pVLon = 1000;
      return (
        lat: _lat,
        lon: _lon,
        speedMs: speedMs,
        bearing: bearing,
      );
    }

    // --- PREDICT ---
    // Position predicted from velocity
    _lat += _vLat * dt;
    _lon += _vLon * dt;

    // Covariance grows with time
    _pLat += _pVLat * dt * dt + _qPos * dt;
    _pLon += _pVLon * dt * dt + _qPos * dt;
    _pVLat += _qVel * dt;
    _pVLon += _qVel * dt;

    // --- UPDATE (measurement correction) ---
    // Convert GPS accuracy (meters) to degrees variance
    final accDeg = accuracyM / 111320; // rough m → deg conversion
    final rLat = accDeg * accDeg;
    final rLon = (accDeg / math.cos(_lat * math.pi / 180)) *
        (accDeg / math.cos(_lat * math.pi / 180));

    // Kalman gain for position
    final kLat = _pLat / (_pLat + rLat);
    final kLon = _pLon / (_pLon + rLon);

    // Correct position
    final innovLat = latitude - _lat;
    final innovLon = longitude - _lon;
    _lat += kLat * innovLat;
    _lon += kLon * innovLon;

    // Update velocity from GPS speed + bearing (blended)
    final bearingRad = bearingDeg * math.pi / 180;
    final speedDegPerS = speedMs / 111320;
    final measVLat = speedDegPerS * math.cos(bearingRad);
    final measVLon = speedDegPerS * math.sin(bearingRad) /
        math.cos(_lat * math.pi / 180);

    // Velocity measurement noise from reported speed accuracy.
    // Convert speed accuracy (m/s) to deg/s variance.
    // Clamp to a minimum to avoid division by zero when accuracy is 0.
    final spdAccMs = speedAccuracyMs > 0 ? speedAccuracyMs : 1.0;
    final spdAccDeg = spdAccMs / 111320;
    final rVel = spdAccDeg * spdAccDeg;
    final kVLat = _pVLat / (_pVLat + rVel);
    final kVLon = _pVLon / (_pVLon + rVel);
    _vLat += kVLat * (measVLat - _vLat);
    _vLon += kVLon * (measVLon - _vLon);

    // Update covariance
    _pLat *= (1 - kLat);
    _pLon *= (1 - kLon);
    _pVLat *= (1 - kVLat);
    _pVLon *= (1 - kVLon);

    return (
      lat: _lat,
      lon: _lon,
      speedMs: speedMs,
      bearing: bearing,
    );
  }

  void reset() {
    _initialized = false;
    _lat = 0;
    _lon = 0;
    _vLat = 0;
    _vLon = 0;
    _pLat = 1000;
    _pLon = 1000;
    _pVLat = 1000;
    _pVLon = 1000;
    _lastTimestampUs = 0;
  }
}
