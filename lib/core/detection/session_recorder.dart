import '../models/sensor_frame.dart';
import '../models/jump.dart';
import 'jump_detector.dart';
import 'accel_filter.dart';
import 'gps_filter.dart';

/// Orchestrates sensor input, filtering, jump detection, and data logging
/// for an active ski session.
class SessionRecorder {
  final JumpDetector _detector;
  final AccelFilter _accelFilter;
  final GpsKalmanFilter _gpsFilter;
  final List<Jump> _jumps = [];
  final List<SensorFrame> _gpsTrack = [];

  bool _isRecording = false;
  int _frameCount = 0;

  /// Maximum GPS accuracy (in meters) to accept. Readings above this
  /// are discarded to prevent noisy fixes from corrupting the track.
  static const double _maxAccuracyM = 20.0;

  /// Most recent GPS data — held and merged into accel-only frames.
  double? _lastLat;
  double? _lastLon;
  double? _lastGpsAlt;
  double? _lastGpsSpeed;
  double? _lastGpsBearing;
  double? _lastGpsAccuracy;

  /// Most recent barometric pressure.
  double? _lastPressure;

  SessionRecorder({
    JumpDetectorConfig? config,
    void Function(Jump)? onJump,
  })  : _detector = JumpDetector(
          config: config ?? const JumpDetectorConfig(),
          onJump: onJump,
        ),
        _accelFilter = AccelFilter(),
        _gpsFilter = GpsKalmanFilter();

  bool get isRecording => _isRecording;
  List<Jump> get jumps => List.unmodifiable(_jumps);
  List<SensorFrame> get gpsTrack => List.unmodifiable(_gpsTrack);
  int get frameCount => _frameCount;
  JumpState get detectorState => _detector.state;

  void start() {
    _isRecording = true;
    _detector.reset();
    _accelFilter.reset();
    _gpsFilter.reset();
    _jumps.clear();
    _gpsTrack.clear();
    _frameCount = 0;
  }

  void stop() {
    _isRecording = false;
  }

  /// Feed raw accelerometer data at ~100Hz.
  /// GPS and baro data are merged from their latest values.
  Jump? processAccelerometer(int timestampUs, double x, double y, double z) {
    if (!_isRecording) return null;

    // Apply low-pass filter
    final filtered = _accelFilter.filter(x, y, z);

    final frame = SensorFrame(
      timestampUs: timestampUs,
      accelX: filtered.x,
      accelY: filtered.y,
      accelZ: filtered.z,
      latitude: _lastLat,
      longitude: _lastLon,
      gpsAltitude: _lastGpsAlt,
      gpsSpeed: _lastGpsSpeed,
      gpsBearing: _lastGpsBearing,
      gpsAccuracy: _lastGpsAccuracy,
      pressure: _lastPressure,
    );

    _frameCount++;

    final jump = _detector.process(frame);
    if (jump != null) {
      _jumps.add(jump);
    }
    return jump;
  }

  /// Feed GPS data at ~1-2Hz. Filtered by accuracy and smoothed via Kalman.
  void processGps({
    required double latitude,
    required double longitude,
    required double altitude,
    required double speed,
    required double bearing,
    required double accuracy,
    required int timestampUs,
  }) {
    if (!_isRecording) return;

    // Always store raw GPS for map replay (even poor accuracy)
    _gpsTrack.add(SensorFrame(
      timestampUs: timestampUs,
      accelX: 0,
      accelY: 0,
      accelZ: 9.81,
      latitude: latitude,
      longitude: longitude,
      gpsAltitude: altitude,
      gpsSpeed: speed,
      gpsBearing: bearing,
      gpsAccuracy: accuracy,
      pressure: _lastPressure,
    ));

    // Reject poor-accuracy readings for detection pipeline
    if (accuracy > _maxAccuracyM) return;

    // Smooth through Kalman filter
    final filtered = _gpsFilter.update(
      latitude: latitude,
      longitude: longitude,
      accuracyM: accuracy,
      speedMs: speed,
      bearingDeg: bearing,
      timestampUs: timestampUs,
    );

    _lastLat = filtered.lat;
    _lastLon = filtered.lon;
    _lastGpsAlt = altitude; // altitude not filtered (GPS altitude is noisy anyway)
    _lastGpsSpeed = filtered.speedMs;
    _lastGpsBearing = filtered.bearing;
    _lastGpsAccuracy = accuracy;
  }

  /// Feed barometric pressure at ~10Hz.
  void processBarometer(double pressureHpa) {
    if (!_isRecording) return;
    _lastPressure = pressureHpa;
  }
}
