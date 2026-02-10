import 'dart:math' as math;

enum SimPhase { skiing, approach, takeoff, airborne, landing, cooldown }

class AccelSample {
  final double x, y, z;
  const AccelSample(this.x, this.y, this.z);
}

class GpsSample {
  final double lat, lon, alt, speed, bearing, accuracy;
  const GpsSample(this.lat, this.lon, this.alt, this.speed, this.bearing, this.accuracy);
}

/// Generates realistic ski sensor data for desktop testing.
/// Cycles through phases: skiing → approach → airborne → landing → cooldown → repeat.
class SensorSimulator {
  final math.Random _rng;

  SimPhase _phase = SimPhase.skiing;
  int _phaseTick = 0;
  int _phaseDuration = 500; // ticks at 100Hz

  // GPS state — starts at Val Thorens
  double _lat = 45.298;
  double _lon = 6.580;
  double _altitude = 2800;
  double _bearing = 170; // heading roughly south-southwest
  double _speed = 0; // m/s

  // Accel target
  double _targetG = 1.0;

  // Expose for providers
  double get currentGForce => _targetG;
  double get currentSpeedKmh => _speed * 3.6;
  double get currentAltitude => _altitude;
  double get currentPressure => _altitudeToPressure(_altitude);

  SensorSimulator({int seed = 42}) : _rng = math.Random(seed);

  void reset() {
    _phase = SimPhase.skiing;
    _phaseTick = 0;
    _phaseDuration = 500;
    _lat = 45.298;
    _lon = 6.580;
    _altitude = 2800;
    _bearing = 170;
    _speed = 0;
    _targetG = 1.0;
  }

  /// Call at 100Hz. Returns an accelerometer sample.
  AccelSample nextAccel(int timestampUs) {
    _advancePhase();
    final g = _targetG + _gaussian(0.08);
    return AccelSample(
      _gaussian(0.2),
      _gaussian(0.2),
      g * 9.80665,
    );
  }

  /// Call at ~1Hz. Returns a GPS sample and advances position.
  GpsSample nextGps(int timestampUs) {
    // Move along bearing at current speed (1 second between calls)
    final distM = _speed;
    final bearingRad = _bearing * math.pi / 180;
    _lat += distM * math.cos(bearingRad) / 111320;
    _lon += distM * math.sin(bearingRad) / (111320 * math.cos(_lat * math.pi / 180));
    _altitude -= distM * 0.15; // ~15% grade slope

    // Slight bearing wander
    _bearing += _gaussian(2.0);
    _bearing = _bearing % 360;

    return GpsSample(
      _lat + _gaussian(0.00002),
      _lon + _gaussian(0.00002),
      _altitude + _gaussian(1.0),
      _speed + _gaussian(0.5).abs(),
      _bearing,
      5.0 + _rng.nextDouble() * 10,
    );
  }

  void _advancePhase() {
    _phaseTick++;
    if (_phaseTick < _phaseDuration) return;

    _phaseTick = 0;
    switch (_phase) {
      case SimPhase.skiing:
        _phase = SimPhase.approach;
        _phaseDuration = 200; // 2s
        _speed = 12 + _rng.nextDouble() * 8; // 12-20 m/s
        _targetG = 1.0;
      case SimPhase.approach:
        _phase = SimPhase.takeoff;
        _phaseDuration = 5; // 50ms
        _targetG = 0.5;
      case SimPhase.takeoff:
        _phase = SimPhase.airborne;
        _phaseDuration = 30 + _rng.nextInt(50); // 300-800ms
        _targetG = 0.05;
      case SimPhase.airborne:
        _phase = SimPhase.landing;
        _phaseDuration = 5; // 50ms
        _targetG = 2.5 + _rng.nextDouble() * 1.5; // 2.5-4G
      case SimPhase.landing:
        _phase = SimPhase.cooldown;
        _phaseDuration = 100; // 1s
        _targetG = 1.0;
        _speed = _speed * 0.8; // slow down after landing
      case SimPhase.cooldown:
        _phase = SimPhase.skiing;
        _phaseDuration = 500 + _rng.nextInt(1000); // 5-15s
        _targetG = 1.0;
        _speed = 8 + _rng.nextDouble() * 12;
    }
  }

  double _gaussian(double stddev) {
    // Box-Muller transform
    final u1 = _rng.nextDouble();
    final u2 = _rng.nextDouble();
    final z = math.sqrt(-2 * math.log(u1 == 0 ? 0.001 : u1)) * math.cos(2 * math.pi * u2);
    return z * stddev;
  }

  static double _altitudeToPressure(double altM) {
    // Inverse of barometric formula
    return 1013.25 * math.pow(1 - altM / 44330.0, 1 / 0.1903);
  }
}
