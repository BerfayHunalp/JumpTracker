import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/detection/jump_detector.dart';
import '../../../core/detection/session_recorder.dart';
import '../../../core/models/jump.dart';
import 'sensor_simulator.dart';

/// Immutable state snapshot for the dashboard UI.
class SessionState {
  final bool isRecording;
  final Duration elapsed;
  final double currentSpeedKmh;
  final double currentAltitudeM;
  final double currentGForce;
  final JumpState detectorState;
  final List<Jump> jumps;
  final List<LatLng> gpsTrack;
  final Jump? lastJump;

  const SessionState({
    this.isRecording = false,
    this.elapsed = Duration.zero,
    this.currentSpeedKmh = 0,
    this.currentAltitudeM = 0,
    this.currentGForce = 1.0,
    this.detectorState = JumpState.skiing,
    this.jumps = const [],
    this.gpsTrack = const [],
    this.lastJump,
  });

  SessionState copyWith({
    bool? isRecording,
    Duration? elapsed,
    double? currentSpeedKmh,
    double? currentAltitudeM,
    double? currentGForce,
    JumpState? detectorState,
    List<Jump>? jumps,
    List<LatLng>? gpsTrack,
    Jump? lastJump,
    bool clearLastJump = false,
  }) {
    return SessionState(
      isRecording: isRecording ?? this.isRecording,
      elapsed: elapsed ?? this.elapsed,
      currentSpeedKmh: currentSpeedKmh ?? this.currentSpeedKmh,
      currentAltitudeM: currentAltitudeM ?? this.currentAltitudeM,
      currentGForce: currentGForce ?? this.currentGForce,
      detectorState: detectorState ?? this.detectorState,
      jumps: jumps ?? this.jumps,
      gpsTrack: gpsTrack ?? this.gpsTrack,
      lastJump: clearLastJump ? null : (lastJump ?? this.lastJump),
    );
  }
}

/// Owns the SessionRecorder, timers, and simulator.
/// Exposes immutable SessionState snapshots to the UI.
class SessionNotifier extends StateNotifier<SessionState> {
  late final SessionRecorder _recorder;
  final SensorSimulator _simulator = SensorSimulator();

  Timer? _sensorTimer;
  Timer? _uiTimer;
  Timer? _durationTimer;
  DateTime? _startTime;

  SessionNotifier() : super(const SessionState()) {
    _recorder = SessionRecorder(
      onJump: _onJumpDetected,
    );
  }

  void toggleRecording() {
    if (state.isRecording) {
      _stopSession();
    } else {
      _startSession();
    }
  }

  void _startSession() {
    _recorder.start();
    _simulator.reset();
    _startTime = DateTime.now();

    // Sensor processing at 100Hz (pure computation)
    _sensorTimer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      _processSensorTick();
    });

    // UI state snapshot at ~12Hz
    _uiTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      _emitUiSnapshot();
    });

    // Duration counter at 1Hz
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateDuration();
    });

    state = state.copyWith(
      isRecording: true,
      elapsed: Duration.zero,
      jumps: const [],
      gpsTrack: const [],
      clearLastJump: true,
    );
  }

  void _stopSession() {
    _sensorTimer?.cancel();
    _uiTimer?.cancel();
    _durationTimer?.cancel();
    _recorder.stop();
    _emitUiSnapshot();
    state = state.copyWith(isRecording: false);
  }

  void _processSensorTick() {
    final now = DateTime.now().microsecondsSinceEpoch;

    // Accel at every tick (100Hz)
    final accel = _simulator.nextAccel(now);
    _recorder.processAccelerometer(now, accel.x, accel.y, accel.z);

    // GPS at ~1Hz (every 100th tick)
    if (_recorder.frameCount % 100 == 0) {
      final gps = _simulator.nextGps(now);
      _recorder.processGps(
        latitude: gps.lat,
        longitude: gps.lon,
        altitude: gps.alt,
        speed: gps.speed,
        bearing: gps.bearing,
        accuracy: gps.accuracy,
        timestampUs: now,
      );
    }

    // Baro at ~10Hz (every 10th tick)
    if (_recorder.frameCount % 10 == 0) {
      _recorder.processBarometer(_simulator.currentPressure);
    }
  }

  void _emitUiSnapshot() {
    final track = _recorder.gpsTrack
        .where((f) => f.latitude != null && f.longitude != null)
        .map((f) => LatLng(f.latitude!, f.longitude!))
        .toList();

    final jumps = _recorder.jumps;

    state = state.copyWith(
      currentGForce: _simulator.currentGForce,
      currentSpeedKmh: _simulator.currentSpeedKmh,
      currentAltitudeM: _simulator.currentAltitude,
      detectorState: _recorder.detectorState,
      jumps: jumps,
      gpsTrack: track,
      lastJump: jumps.isNotEmpty ? jumps.last : null,
    );
  }

  void _onJumpDetected(Jump jump) {
    // Immediate UI update on jump detection
    _emitUiSnapshot();
  }

  void _updateDuration() {
    if (_startTime != null) {
      state = state.copyWith(
        elapsed: DateTime.now().difference(_startTime!),
      );
    }
  }

  @override
  void dispose() {
    _sensorTimer?.cancel();
    _uiTimer?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }
}

// --- Providers ---

final sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier();
});

final isRecordingProvider = Provider<bool>((ref) {
  return ref.watch(sessionProvider.select((s) => s.isRecording));
});

final currentGForceProvider = Provider<double>((ref) {
  return ref.watch(sessionProvider.select((s) => s.currentGForce));
});

final detectorStateProvider = Provider<JumpState>((ref) {
  return ref.watch(sessionProvider.select((s) => s.detectorState));
});

final jumpListProvider = Provider<List<Jump>>((ref) {
  return ref.watch(sessionProvider.select((s) => s.jumps));
});

final lastJumpProvider = Provider<Jump?>((ref) {
  return ref.watch(sessionProvider.select((s) => s.lastJump));
});

final liveStatsProvider =
    Provider<({double speed, double altitude, Duration elapsed})>((ref) {
  final s = ref.watch(sessionProvider);
  return (speed: s.currentSpeedKmh, altitude: s.currentAltitudeM, elapsed: s.elapsed);
});

final gpsTrackProvider = Provider<List<LatLng>>((ref) {
  return ref.watch(sessionProvider.select((s) => s.gpsTrack));
});
