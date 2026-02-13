import 'dart:math' as math;
import '../models/sensor_frame.dart';
import '../models/jump.dart';

/// Configuration for the jump detection algorithm.
/// These thresholds are tuned for skiing and can be adjusted.
class JumpDetectorConfig {
  /// Acceleration below this (in G) triggers freefall detection.
  /// True freefall = 0G, but sensor noise + rotation means we use ~0.4G.
  final double freefallThresholdG;

  /// Acceleration above this (in G) confirms a landing impact.
  final double landingThresholdG;

  /// Minimum airtime (ms) to count as a real jump.
  /// Filters out bumps, moguls, and sensor noise.
  final double minAirtimeMs;

  /// Maximum airtime (ms) — anything longer is likely a sensor glitch.
  final double maxAirtimeMs;

  /// Number of consecutive freefall samples needed to confirm takeoff.
  /// At 100Hz, 3 samples = 30ms of sustained low-G.
  final int freefallConfirmSamples;

  /// Cooldown after landing before detecting the next jump (ms).
  /// Prevents double-detection from landing bounce.
  final double cooldownMs;

  /// Window (ms) after landing to search for peak G-force.
  final double landingGForceWindowMs;

  const JumpDetectorConfig({
    this.freefallThresholdG = 0.4,
    this.landingThresholdG = 1.8,
    this.minAirtimeMs = 250,
    this.maxAirtimeMs = 8000,
    this.freefallConfirmSamples = 3,
    this.cooldownMs = 500,
    this.landingGForceWindowMs = 150,
  });
}

/// The states of the jump detection FSM.
enum JumpState {
  /// Normal skiing — watching for freefall.
  skiing,

  /// Potential freefall detected, accumulating confirmation samples.
  freefallPending,

  /// Confirmed airborne — timing the jump.
  airborne,

  /// Just landed — in cooldown, computing metrics.
  cooldown,
}

/// Emitted when a jump is fully detected and computed.
typedef JumpCallback = void Function(Jump jump);

/// Core jump detection engine using a finite state machine.
///
/// Feed it [SensorFrame]s at ~100Hz from the accelerometer
/// (with GPS/baro data when available). It detects jumps by:
///
/// 1. **Takeoff**: sustained low-G (freefall) across multiple samples
/// 2. **Airborne**: tracking duration while G stays low
/// 3. **Landing**: sudden high-G impact spike
/// 4. **Compute**: airtime, distance (GPS), height (baro), speed, g-force
class JumpDetector {
  final JumpDetectorConfig config;
  final JumpCallback? onJump;
  final String Function() generateId;

  JumpState _state = JumpState.skiing;
  int _freefallSampleCount = 0;

  /// Frame at the moment of takeoff (first freefall frame).
  SensorFrame? _takeoffFrame;

  /// Most recent GPS data at takeoff.
  SensorFrame? _takeoffGpsFrame;

  /// Last frame that had GPS data — kept rolling during skiing
  /// so that when takeoff happens (on a freefall frame with no GPS),
  /// we still have recent GPS info.
  SensorFrame? _lastGpsFrame;

  /// Barometric altitude at takeoff.
  double? _takeoffBaroAltitude;

  /// Peak G-force observed in the landing window.
  double _peakLandingG = 0;

  /// Timestamp when cooldown started.
  int _cooldownStartUs = 0;

  /// All frames collected during the airborne phase for analysis.
  final List<SensorFrame> _airborneFrames = [];

  /// Running counter of detected jumps (for generating run IDs).
  int _jumpCount = 0;

  /// Current run ID — set externally by the session manager.
  String currentRunId = 'default';

  JumpDetector({
    this.config = const JumpDetectorConfig(),
    this.onJump,
    String Function()? idGenerator,
  }) : generateId = idGenerator ?? _defaultIdGenerator;

  JumpState get state => _state;
  int get jumpCount => _jumpCount;

  static String _defaultId = '';
  static String _defaultIdGenerator() {
    _defaultId = 'jump_${DateTime.now().microsecondsSinceEpoch}';
    return _defaultId;
  }

  /// Process a single sensor frame. Call this at ~100Hz.
  Jump? process(SensorFrame frame) {
    switch (_state) {
      case JumpState.skiing:
        return _handleSkiing(frame);
      case JumpState.freefallPending:
        return _handleFreefallPending(frame);
      case JumpState.airborne:
        return _handleAirborne(frame);
      case JumpState.cooldown:
        return _handleCooldown(frame);
    }
  }

  /// Reset the detector to initial state.
  void reset() {
    _state = JumpState.skiing;
    _freefallSampleCount = 0;
    _takeoffFrame = null;
    _takeoffGpsFrame = null;
    _lastGpsFrame = null;
    _takeoffBaroAltitude = null;
    _peakLandingG = 0;
    _cooldownStartUs = 0;
    _airborneFrames.clear();
  }

  // --- State handlers ---

  Jump? _handleSkiing(SensorFrame frame) {
    if (frame.accelG < config.freefallThresholdG) {
      // Potential freefall — capture GPS from skiing BEFORE updating
      // _lastGpsFrame, so we get the last frame with speed data.
      _freefallSampleCount = 1;
      _takeoffFrame = frame;
      _takeoffGpsFrame = _lastGpsFrame;
      _takeoffBaroAltitude = frame.baroAltitude;
      _state = JumpState.freefallPending;
    } else {
      // Track latest GPS during normal skiing for use at takeoff
      if (frame.latitude != null) {
        _lastGpsFrame = frame;
      }
    }
    return null;
  }

  Jump? _handleFreefallPending(SensorFrame frame) {
    if (frame.accelG < config.freefallThresholdG) {
      _freefallSampleCount++;
      if (_freefallSampleCount >= config.freefallConfirmSamples) {
        // Confirmed takeoff!
        _state = JumpState.airborne;
        _airborneFrames.clear();
        _airborneFrames.add(frame);
      }
    } else {
      // False alarm — back to skiing
      _state = JumpState.skiing;
      _freefallSampleCount = 0;
      _takeoffFrame = null;
    }
    return null;
  }

  Jump? _handleAirborne(SensorFrame frame) {
    _airborneFrames.add(frame);

    // Check for timeout (sensor glitch protection)
    final airtimeMs = frame.deltaMs(_takeoffFrame!);
    if (airtimeMs > config.maxAirtimeMs) {
      // Too long — not a real jump, probably sensor issue
      _state = JumpState.skiing;
      _airborneFrames.clear();
      _takeoffFrame = null;
      return null;
    }

    // Detect landing: high-G impact
    if (frame.accelG > config.landingThresholdG) {
      return _processLanding(frame);
    }

    return null;
  }

  Jump? _handleCooldown(SensorFrame frame) {
    // Track peak G-force during landing window
    if (frame.accelG > _peakLandingG) {
      _peakLandingG = frame.accelG;
    }

    final cooldownElapsed =
        (frame.timestampUs - _cooldownStartUs) / 1000.0;
    if (cooldownElapsed >= config.cooldownMs) {
      _state = JumpState.skiing;
    }
    return null;
  }

  // --- Jump computation ---

  Jump? _processLanding(SensorFrame landingFrame) {
    final airtime = landingFrame.deltaMs(_takeoffFrame!);

    // Filter: too short = bump/mogul, not a jump
    if (airtime < config.minAirtimeMs) {
      _state = JumpState.skiing;
      _airborneFrames.clear();
      _takeoffFrame = null;
      return null;
    }

    // Compute all metrics
    final distance = _computeDistance(landingFrame);
    final height = _computeHeight(landingFrame);
    final speed = _computeTakeoffSpeed();
    _peakLandingG = landingFrame.accelG;

    final jump = Jump(
      id: generateId(),
      runId: currentRunId,
      takeoffTimestampUs: _takeoffFrame!.timestampUs,
      landingTimestampUs: landingFrame.timestampUs,
      airtimeMs: airtime,
      distanceM: distance,
      heightM: height,
      speedKmh: speed,
      landingGForce: _peakLandingG,
      latTakeoff: _takeoffGpsFrame?.latitude,
      lonTakeoff: _takeoffGpsFrame?.longitude,
      latLanding: landingFrame.latitude,
      lonLanding: landingFrame.longitude,
      altitudeTakeoff: _takeoffBaroAltitude,
    );

    _jumpCount++;
    onJump?.call(jump);

    // Enter cooldown
    _cooldownStartUs = landingFrame.timestampUs;
    _state = JumpState.cooldown;
    _airborneFrames.clear();
    _takeoffFrame = null;

    return jump;
  }

  /// Compute horizontal distance using physics-first approach.
  ///
  /// During a jump, GPS cannot reliably update mid-air (0.3–3s airtime),
  /// so speed × time is more accurate than comparing two stale GPS fixes.
  double _computeDistance(SensorFrame landingFrame) {
    final airtimeS = landingFrame.deltaMs(_takeoffFrame!) / 1000.0;

    // Method 1 (primary): Physics — takeoff speed × airtime
    final speedMs = _takeoffGpsFrame?.gpsSpeed ?? 0;
    if (speedMs > 0.5) {
      final physicsDistance = speedMs * airtimeS;

      // Cross-validate with GPS if both endpoints available
      if (_takeoffGpsFrame?.latitude != null &&
          landingFrame.latitude != null) {
        final gpsDistance = _haversineDistance(
          _takeoffGpsFrame!.latitude!,
          _takeoffGpsFrame!.longitude!,
          landingFrame.latitude!,
          landingFrame.longitude!,
        );
        // If GPS and physics agree within 50%, trust physics.
        // If they diverge wildly, average them to hedge.
        if (gpsDistance > 0 &&
            (physicsDistance / gpsDistance - 1).abs() > 0.5) {
          return (physicsDistance + gpsDistance) / 2;
        }
      }
      return physicsDistance;
    }

    // Method 2 (fallback): GPS haversine when no speed data
    if (_takeoffGpsFrame != null &&
        _takeoffGpsFrame!.latitude != null &&
        landingFrame.latitude != null) {
      return _haversineDistance(
        _takeoffGpsFrame!.latitude!,
        _takeoffGpsFrame!.longitude!,
        landingFrame.latitude!,
        landingFrame.longitude!,
      );
    }

    return 0;
  }

  /// Compute jump height from barometer delta or physics fallback.
  double _computeHeight(SensorFrame landingFrame) {
    // Method 1: Barometric altitude difference
    final landingBaro = landingFrame.baroAltitude;
    if (_takeoffBaroAltitude != null && landingBaro != null) {
      // The peak height is approximately reached at midpoint of jump.
      // On a ski jump, you go UP then come down. The baro difference
      // at landing is ~0 (same slope), so we estimate peak height
      // from airtime using physics: h = 0.5 * g * (t/2)^2
      final halfTimeS =
          (landingFrame.deltaMs(_takeoffFrame!) / 1000.0) / 2.0;
      return 0.5 * 9.80665 * halfTimeS * halfTimeS;
    }

    // Method 2: Pure physics from airtime
    final halfTimeS =
        (landingFrame.deltaMs(_takeoffFrame!) / 1000.0) / 2.0;
    return 0.5 * 9.80665 * halfTimeS * halfTimeS;
  }

  /// Get takeoff speed from GPS data.
  double _computeTakeoffSpeed() {
    final speedMs = _takeoffGpsFrame?.gpsSpeed;
    if (speedMs != null) {
      return speedMs * 3.6; // m/s → km/h
    }
    return 0;
  }

  /// Haversine formula for distance between two GPS coordinates.
  static double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  static double _toRad(double deg) => deg * math.pi / 180;
}
