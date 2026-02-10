/// Low-pass filter for accelerometer data to reduce noise.
///
/// Uses an exponential moving average (EMA) which is:
/// - Computationally cheap (runs at 100Hz)
/// - Introduces minimal lag
/// - Smooths out vibrations from skiing over rough terrain
class AccelFilter {
  /// Smoothing factor: 0 = no smoothing, 1 = no filtering.
  /// 0.3 provides good noise reduction with ~30ms effective lag at 100Hz.
  final double alpha;

  double _filteredX = 0;
  double _filteredY = 0;
  double _filteredZ = 0;
  bool _initialized = false;

  AccelFilter({this.alpha = 0.3});

  /// Apply the filter and return smoothed values.
  /// Returns (x, y, z) tuple as a record.
  ({double x, double y, double z}) filter(
    double rawX,
    double rawY,
    double rawZ,
  ) {
    if (!_initialized) {
      _filteredX = rawX;
      _filteredY = rawY;
      _filteredZ = rawZ;
      _initialized = true;
    } else {
      _filteredX = alpha * rawX + (1 - alpha) * _filteredX;
      _filteredY = alpha * rawY + (1 - alpha) * _filteredY;
      _filteredZ = alpha * rawZ + (1 - alpha) * _filteredZ;
    }

    return (x: _filteredX, y: _filteredY, z: _filteredZ);
  }

  void reset() {
    _filteredX = 0;
    _filteredY = 0;
    _filteredZ = 0;
    _initialized = false;
  }
}
