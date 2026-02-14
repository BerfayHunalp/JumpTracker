import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import '../../../core/detection/jump_detector.dart';
import '../../../core/detection/session_recorder.dart';
import '../../../core/models/jump.dart' as model;
import '../../../core/database/database.dart';
import '../../../core/sensors/sensors.dart';
import '../../../core/auth/auth_providers.dart';
import '../../../core/sync/sync_service.dart';

const _uuid = Uuid();

/// Immutable state snapshot for the dashboard UI.
class SessionState {
  final bool isRecording;
  final Duration elapsed;
  final double currentSpeedKmh;
  final double currentAltitudeM;
  final double currentGForce;
  final JumpState detectorState;
  final List<model.Jump> jumps;
  final List<LatLng> gpsTrack;
  final model.Jump? lastJump;

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
    List<model.Jump>? jumps,
    List<LatLng>? gpsTrack,
    model.Jump? lastJump,
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

/// Owns the SessionRecorder, timers, and sensor source.
/// Persists sessions and jumps to the local database.
class SessionNotifier extends StateNotifier<SessionState> {
  final SensorService _sensorSource;
  final SessionRepository _sessionRepo;
  final JumpRepository _jumpRepo;
  final GpsRepository _gpsRepo;
  final SyncService? _syncService;

  late final SessionRecorder _recorder;

  Timer? _uiTimer;
  Timer? _durationTimer;
  DateTime? _startTime;

  String? _currentSessionId;

  /// The session ID of the currently recording (or just-stopped) session.
  String? get currentSessionId => _currentSessionId;

  SessionNotifier({
    required SensorService sensorSource,
    required SessionRepository sessionRepo,
    required JumpRepository jumpRepo,
    required GpsRepository gpsRepo,
    SyncService? syncService,
  })  : _sensorSource = sensorSource,
        _sessionRepo = sessionRepo,
        _jumpRepo = jumpRepo,
        _gpsRepo = gpsRepo,
        _syncService = syncService,
        super(const SessionState()) {
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

  void _startSession() async {
    _currentSessionId = _uuid.v4();
    _startTime = DateTime.now();

    // Persist new session row
    await _sessionRepo.insertSession(
      id: _currentSessionId!,
      startedAt: _startTime!,
    );

    _recorder.start();

    // Real sensors: callback-driven
    _sensorSource.reset();
    _sensorSource.onAccel = (timestampUs, x, y, z) {
      _recorder.processAccelerometer(timestampUs, x, y, z);
    };
    _sensorSource.onGps = ({
      required double latitude,
      required double longitude,
      required double altitude,
      required double speed,
      required double bearing,
      required double accuracy,
      required double speedAccuracy,
      required int timestampUs,
    }) {
      _recorder.processGps(
        latitude: latitude,
        longitude: longitude,
        altitude: altitude,
        speed: speed,
        bearing: bearing,
        accuracy: accuracy,
        speedAccuracy: speedAccuracy,
        timestampUs: timestampUs,
      );
    };
    _sensorSource.onPressure = (pressureHpa) {
      _recorder.processBarometer(pressureHpa);
    };
    _sensorSource.start();

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

  void _stopSession() async {
    _uiTimer?.cancel();
    _durationTimer?.cancel();
    _recorder.stop();
    _sensorSource.stop();

    _emitUiSnapshot();

    // Persist final session stats
    if (_currentSessionId != null) {
      final jumps = _recorder.jumps;
      final maxAirtime =
          jumps.isEmpty ? 0.0 : jumps.map((j) => j.airtimeMs.toDouble()).reduce(max);

      await _sessionRepo.finishSession(
        id: _currentSessionId!,
        endedAt: DateTime.now(),
        totalJumps: jumps.length,
        maxAirtimeMs: maxAirtime,
        totalVerticalM: 0, // Run tracking is a future feature
      );

      // Batch-save GPS track
      final gpsFrames = _recorder.gpsTrack;
      if (gpsFrames.isNotEmpty) {
        final companions = gpsFrames
            .where((f) => f.latitude != null && f.longitude != null)
            .map((f) => GpsPointsCompanion.insert(
                  sessionId: _currentSessionId!,
                  timestampUs: f.timestampUs,
                  latitude: f.latitude!,
                  longitude: f.longitude!,
                  altitude: f.gpsAltitude ?? 0,
                  speed: f.gpsSpeed ?? 0,
                  bearing: f.gpsBearing ?? 0,
                  accuracy: f.gpsAccuracy ?? 0,
                ))
            .toList();
        await _gpsRepo.insertPoints(companions);
      }

      // Trigger cloud sync (fire-and-forget)
      _syncService?.syncPendingSessions();
    }

    state = state.copyWith(isRecording: false);
  }

  void _emitUiSnapshot() {
    final track = _recorder.gpsTrack
        .where((f) => f.latitude != null && f.longitude != null)
        .map((f) => LatLng(f.latitude!, f.longitude!))
        .toList();

    final jumps = _recorder.jumps;

    state = state.copyWith(
      currentGForce: _sensorSource.currentGForce,
      currentSpeedKmh: _sensorSource.currentSpeedKmh,
      currentAltitudeM: _sensorSource.currentAltitude,
      detectorState: _recorder.detectorState,
      jumps: jumps,
      gpsTrack: track,
      lastJump: jumps.isNotEmpty ? jumps.last : null,
    );
  }

  void _onJumpDetected(model.Jump jump) async {
    // Persist jump immediately
    if (_currentSessionId != null) {
      await _jumpRepo.insertJump(
        id: jump.id,
        sessionId: _currentSessionId!,
        runId: jump.runId,
        takeoffTimestampUs: jump.takeoffTimestampUs,
        landingTimestampUs: jump.landingTimestampUs,
        airtimeMs: jump.airtimeMs,
        distanceM: jump.distanceM,
        heightM: jump.heightM,
        speedKmh: jump.speedKmh,
        landingGForce: jump.landingGForce,
        latTakeoff: jump.latTakeoff,
        lonTakeoff: jump.lonTakeoff,
        latLanding: jump.latLanding,
        lonLanding: jump.lonLanding,
        altitudeTakeoff: jump.altitudeTakeoff,
      );
    }
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
    _uiTimer?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }
}

// --- Providers ---

final sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier(
    sensorSource: ref.watch(sensorSourceProvider),
    sessionRepo: ref.watch(sessionRepositoryProvider),
    jumpRepo: ref.watch(jumpRepositoryProvider),
    gpsRepo: ref.watch(gpsRepositoryProvider),
    syncService: ref.watch(_syncServiceProvider),
  );
});

final _syncServiceProvider = Provider<SyncService?>((ref) {
  try {
    return SyncService(
      ref.watch(apiClientProvider),
      ref.watch(sessionRepositoryProvider),
      ref.watch(jumpRepositoryProvider),
    );
  } catch (_) {
    return null;
  }
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

final jumpListProvider = Provider<List<model.Jump>>((ref) {
  return ref.watch(sessionProvider.select((s) => s.jumps));
});

final lastJumpProvider = Provider<model.Jump?>((ref) {
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
