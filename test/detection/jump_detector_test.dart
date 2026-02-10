import 'package:flutter_test/flutter_test.dart';
import 'package:ski_tracker/core/detection/jump_detector.dart';
import 'package:ski_tracker/core/models/sensor_frame.dart';
import 'package:ski_tracker/core/models/jump.dart';

/// Helper to generate sensor frames simulating different scenarios.
class FrameGenerator {
  int _timeUs;
  final int intervalUs; // microseconds between frames (10000 = 100Hz)

  FrameGenerator({int startTimeUs = 0, this.intervalUs = 10000})
      : _timeUs = startTimeUs;

  /// Generate N frames of normal skiing (accel ~1G).
  List<SensorFrame> skiing(int count, {double gpsSpeed = 15.0}) {
    return List.generate(count, (_) {
      _timeUs += intervalUs;
      return SensorFrame(
        timestampUs: _timeUs,
        accelX: 0.2, // slight noise
        accelY: 0.3,
        accelZ: 9.75, // ~1G total
        gpsSpeed: gpsSpeed,
        latitude: 45.0,
        longitude: 6.5,
      );
    });
  }

  /// Generate N frames of freefall (accel ~0G).
  List<SensorFrame> freefall(int count) {
    return List.generate(count, (_) {
      _timeUs += intervalUs;
      return SensorFrame(
        timestampUs: _timeUs,
        accelX: 0.05,
        accelY: 0.1,
        accelZ: 0.15, // ~0.02G — deep freefall
        latitude: 45.0001,
        longitude: 6.5001,
        pressure: 900.0,
      );
    });
  }

  /// Generate a landing impact frame.
  SensorFrame landingImpact({double gForce = 3.0}) {
    _timeUs += intervalUs;
    final accel = gForce * 9.80665;
    return SensorFrame(
      timestampUs: _timeUs,
      accelX: 0,
      accelY: 0,
      accelZ: accel,
      latitude: 45.0005,
      longitude: 6.5005,
      pressure: 900.5,
    );
  }

  /// Generate N frames of mogul bumps (brief spikes, not sustained freefall).
  List<SensorFrame> moguls(int count) {
    return List.generate(count, (i) {
      _timeUs += intervalUs;
      // Alternating high-G bump and brief low-G between bumps
      final isUp = i % 4 == 0;
      return SensorFrame(
        timestampUs: _timeUs,
        accelX: 0.5,
        accelY: 0.5,
        accelZ: isUp ? 2.0 : 8.5, // brief low-G but not sustained
      );
    });
  }

  /// Generate a single frame with custom accel magnitude in G.
  SensorFrame customG(double g) {
    _timeUs += intervalUs;
    return SensorFrame(
      timestampUs: _timeUs,
      accelX: 0,
      accelY: 0,
      accelZ: g * 9.80665,
    );
  }
}

void main() {
  late JumpDetector detector;
  late FrameGenerator gen;
  int idCounter = 0;

  setUp(() {
    idCounter = 0;
    detector = JumpDetector(
      idGenerator: () => 'jump_${idCounter++}',
    );
    gen = FrameGenerator();
  });

  group('JumpDetector FSM', () {
    test('starts in skiing state', () {
      expect(detector.state, JumpState.skiing);
      expect(detector.jumpCount, 0);
    });

    test('detects a clean jump', () {
      // Ski normally for a bit
      for (final f in gen.skiing(50)) {
        expect(detector.process(f), isNull);
      }
      expect(detector.state, JumpState.skiing);

      // Enter freefall for 400ms (40 frames at 100Hz)
      Jump? detectedJump;
      for (final f in gen.freefall(40)) {
        final result = detector.process(f);
        if (result != null) detectedJump = result;
      }

      // Should be airborne after confirmation samples
      // (hasn't landed yet so no jump returned)
      expect(detectedJump, isNull);
      expect(detector.state, JumpState.airborne);

      // Land with impact
      detectedJump = detector.process(gen.landingImpact(gForce: 3.0));

      expect(detectedJump, isNotNull);
      expect(detectedJump!.airtimeMs, greaterThan(300));
      expect(detectedJump.airtimeMs, lessThan(500));
      expect(detectedJump.landingGForce, closeTo(3.0, 0.1));
      expect(detectedJump.id, 'jump_0');
      expect(detector.jumpCount, 1);
    });

    test('filters out short hops (< 200ms)', () {
      // Normal skiing
      for (final f in gen.skiing(20)) {
        detector.process(f);
      }

      // Very brief freefall — only 10 frames = 100ms
      for (final f in gen.freefall(10)) {
        detector.process(f);
      }

      // Land
      final result = detector.process(gen.landingImpact());

      // Should NOT register as a jump
      expect(result, isNull);
      expect(detector.jumpCount, 0);
    });

    test('rejects mogul bumps as false positives', () {
      // Moguls create brief low-G moments but not sustained freefall
      for (final f in gen.moguls(100)) {
        final result = detector.process(f);
        expect(result, isNull);
      }
      expect(detector.jumpCount, 0);
    });

    test('detects multiple consecutive jumps', () {
      final jumps = <Jump>[];

      for (int i = 0; i < 3; i++) {
        // Ski between jumps
        for (final f in gen.skiing(100)) {
          detector.process(f);
        }

        // Jump: 300ms freefall
        for (final f in gen.freefall(30)) {
          detector.process(f);
        }

        // Land
        final result = detector.process(gen.landingImpact(gForce: 2.5));
        if (result != null) jumps.add(result);

        // Cooldown frames
        for (final f in gen.skiing(60)) {
          detector.process(f);
        }
      }

      expect(jumps.length, 3);
      expect(detector.jumpCount, 3);
      // Each jump should have unique IDs
      expect(jumps.map((j) => j.id).toSet().length, 3);
    });

    test('respects cooldown between jumps', () {
      // First jump
      for (final f in gen.skiing(20)) {
        detector.process(f);
      }
      for (final f in gen.freefall(30)) {
        detector.process(f);
      }
      detector.process(gen.landingImpact());

      expect(detector.state, JumpState.cooldown);

      // Immediately try another freefall during cooldown
      for (final f in gen.freefall(5)) {
        detector.process(f);
      }

      // Should still be in cooldown, not detecting new jump
      expect(detector.state, JumpState.cooldown);
    });

    test('aborts on impossibly long airtime (>8s)', () {
      for (final f in gen.skiing(20)) {
        detector.process(f);
      }

      // Feed freefall frames one at a time so we can check when it resets.
      // 3 frames to confirm takeoff, then ~800 more to reach 8000ms.
      // At 10ms/frame, frame ~803 should trigger the timeout.
      bool didReset = false;
      for (final f in gen.freefall(900)) {
        detector.process(f);
        if (!didReset && detector.state == JumpState.skiing) {
          didReset = true;
          break;
        }
      }

      // Should have reset before all 900 frames (around frame 803)
      expect(didReset, isTrue);
      expect(detector.jumpCount, 0);
    });

    test('handles freefall-pending to skiing transition on noise', () {
      for (final f in gen.skiing(20)) {
        detector.process(f);
      }

      // One low-G frame (not enough to confirm)
      detector.process(gen.customG(0.2));
      expect(detector.state, JumpState.freefallPending);

      // Immediately back to normal G — false alarm
      detector.process(gen.customG(1.0));
      expect(detector.state, JumpState.skiing);
    });

    test('reset clears all state', () {
      // Get into airborne state
      for (final f in gen.skiing(20)) {
        detector.process(f);
      }
      for (final f in gen.freefall(10)) {
        detector.process(f);
      }

      detector.reset();

      expect(detector.state, JumpState.skiing);
      // jump count persists through reset (it's a session counter)
    });
  });

  group('Jump metrics', () {
    test('computes airtime correctly', () {
      for (final f in gen.skiing(20)) {
        detector.process(f);
      }

      // 50 frames at 100Hz = 500ms freefall
      for (final f in gen.freefall(50)) {
        detector.process(f);
      }

      final jump = detector.process(gen.landingImpact())!;

      // Airtime should be roughly 500ms (freefall frames)
      // plus the confirmation delay. Actual value depends on
      // takeoff frame timing.
      expect(jump.airtimeMs, greaterThan(400));
      expect(jump.airtimeMs, lessThan(600));
    });

    test('computes height from airtime physics', () {
      for (final f in gen.skiing(20)) {
        detector.process(f);
      }
      for (final f in gen.freefall(50)) {
        detector.process(f);
      }

      final jump = detector.process(gen.landingImpact())!;

      // h = 0.5 * g * (t/2)^2
      // For ~500ms airtime: h = 0.5 * 9.81 * 0.25^2 = ~0.31m
      expect(jump.heightM, greaterThan(0.1));
      expect(jump.heightM, lessThan(2.0));
    });

    test('captures GPS coordinates at takeoff and landing', () {
      for (final f in gen.skiing(20)) {
        detector.process(f);
      }
      for (final f in gen.freefall(30)) {
        detector.process(f);
      }

      final jump = detector.process(gen.landingImpact())!;

      expect(jump.latTakeoff, isNotNull);
      expect(jump.lonTakeoff, isNotNull);
      expect(jump.latLanding, isNotNull);
      expect(jump.lonLanding, isNotNull);
    });

    test('computes takeoff speed from GPS', () {
      for (final f in gen.skiing(20, gpsSpeed: 20.0)) {
        detector.process(f);
      }
      for (final f in gen.freefall(30)) {
        detector.process(f);
      }

      final jump = detector.process(gen.landingImpact())!;

      // 20 m/s = 72 km/h
      expect(jump.speedKmh, closeTo(72, 1));
    });

    test('jump score increases with airtime', () {
      final jumps = <Jump>[];

      // Short jump: 250ms
      for (final f in gen.skiing(50)) {
        detector.process(f);
      }
      for (final f in gen.freefall(25)) {
        detector.process(f);
      }
      jumps.add(detector.process(gen.landingImpact())!);
      for (final f in gen.skiing(60)) {
        detector.process(f);
      }

      // Long jump: 700ms
      for (final f in gen.freefall(70)) {
        detector.process(f);
      }
      jumps.add(detector.process(gen.landingImpact())!);

      expect(jumps[1].score, greaterThan(jumps[0].score));
    });
  });

  group('JumpDetector callback', () {
    test('invokes onJump callback when jump detected', () {
      final callbackJumps = <Jump>[];
      final callbackDetector = JumpDetector(
        onJump: (j) => callbackJumps.add(j),
        idGenerator: () => 'cb_jump_${idCounter++}',
      );
      final cbGen = FrameGenerator();

      for (final f in cbGen.skiing(20)) {
        callbackDetector.process(f);
      }
      for (final f in cbGen.freefall(30)) {
        callbackDetector.process(f);
      }
      callbackDetector.process(cbGen.landingImpact());

      expect(callbackJumps.length, 1);
      expect(callbackJumps.first.id, startsWith('cb_jump_'));
    });
  });

  group('Custom config', () {
    test('stricter freefall threshold requires deeper freefall', () {
      final strictDetector = JumpDetector(
        config: const JumpDetectorConfig(freefallThresholdG: 0.2),
        idGenerator: () => 'strict_${idCounter++}',
      );
      final strictGen = FrameGenerator();

      for (final f in strictGen.skiing(20)) {
        strictDetector.process(f);
      }

      // Moderate low-G (0.3G) — below default threshold but above strict
      for (int i = 0; i < 30; i++) {
        strictDetector.process(strictGen.customG(0.3));
      }

      // Should NOT have entered airborne with strict threshold
      expect(strictDetector.state, JumpState.skiing);
    });

    test('lower min airtime catches smaller jumps', () {
      final sensitiveDetector = JumpDetector(
        config: const JumpDetectorConfig(minAirtimeMs: 100),
        idGenerator: () => 'sens_${idCounter++}',
      );
      final sensGen = FrameGenerator();

      for (final f in sensGen.skiing(20)) {
        sensitiveDetector.process(f);
      }

      // 15 frames = 150ms — too short for default but OK for 100ms min
      for (final f in sensGen.freefall(15)) {
        sensitiveDetector.process(f);
      }

      final result = sensitiveDetector.process(sensGen.landingImpact());
      expect(result, isNotNull);
      expect(result!.airtimeMs, greaterThan(100));
    });
  });
}
