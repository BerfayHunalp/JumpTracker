import 'package:flutter_test/flutter_test.dart';
import 'package:ski_tracker/core/detection/session_recorder.dart';
import 'package:ski_tracker/core/models/jump.dart';

void main() {
  group('SessionRecorder', () {
    late SessionRecorder recorder;

    setUp(() {
      recorder = SessionRecorder();
    });

    test('starts inactive', () {
      expect(recorder.isRecording, false);
      expect(recorder.frameCount, 0);
    });

    test('ignores data when not recording', () {
      recorder.processAccelerometer(1000, 0, 0, 9.81);
      expect(recorder.frameCount, 0);
    });

    test('processes frames when recording', () {
      recorder.start();
      recorder.processAccelerometer(1000, 0, 0, 9.81);
      recorder.processAccelerometer(2000, 0, 0, 9.81);
      expect(recorder.frameCount, 2);
      expect(recorder.isRecording, true);
    });

    test('stop halts processing', () {
      recorder.start();
      recorder.processAccelerometer(1000, 0, 0, 9.81);
      recorder.stop();
      recorder.processAccelerometer(2000, 0, 0, 9.81);
      expect(recorder.frameCount, 1);
      expect(recorder.isRecording, false);
    });

    test('detects jump through full pipeline', () {
      final detectedJumps = <Jump>[];
      recorder = SessionRecorder(onJump: (j) => detectedJumps.add(j));
      recorder.start();

      int time = 0;
      const dt = 10000; // 100Hz

      // Feed GPS data
      recorder.processGps(
        latitude: 45.0,
        longitude: 6.5,
        altitude: 2000,
        speed: 15.0,
        bearing: 180,
        accuracy: 5,
        timestampUs: time,
      );

      // Feed barometer
      recorder.processBarometer(900.0);

      // Normal skiing: 500ms
      for (int i = 0; i < 50; i++) {
        time += dt;
        recorder.processAccelerometer(time, 0.2, 0.3, 9.7);
      }

      // Freefall: 400ms
      for (int i = 0; i < 40; i++) {
        time += dt;
        recorder.processAccelerometer(time, 0.05, 0.05, 0.1);
      }

      // Landing impact — multiple frames needed because the EMA filter
      // smooths the sudden spike. We send several high-G frames until
      // the filtered value crosses the 1.8G landing threshold.
      Jump? jump;
      for (int i = 0; i < 10; i++) {
        time += dt;
        jump = recorder.processAccelerometer(
            time, 0, 0, 5.0 * 9.80665);
        if (jump != null) break;
      }

      expect(jump, isNotNull);
      expect(detectedJumps.length, 1);
      expect(recorder.jumps.length, 1);
      expect(jump!.airtimeMs, greaterThan(300));
    });

    test('merges GPS data into accelerometer frames', () {
      recorder.start();

      // Set GPS before accel data
      recorder.processGps(
        latitude: 45.123,
        longitude: 6.456,
        altitude: 1800,
        speed: 20.0,
        bearing: 90,
        accuracy: 3,
        timestampUs: 0,
      );

      expect(recorder.gpsTrack.length, 1);
      expect(recorder.gpsTrack.first.latitude, 45.123);
    });

    test('stores GPS track points', () {
      recorder.start();

      for (int i = 0; i < 5; i++) {
        recorder.processGps(
          latitude: 45.0 + i * 0.001,
          longitude: 6.5 + i * 0.001,
          altitude: 2000 - i * 10,
          speed: 15.0,
          bearing: 180,
          accuracy: 5,
          timestampUs: i * 1000000,
        );
      }

      expect(recorder.gpsTrack.length, 5);
    });

    test('start resets state', () {
      recorder.start();

      int time = 0;
      const dt = 10000;

      for (int i = 0; i < 20; i++) {
        time += dt;
        recorder.processAccelerometer(time, 0, 0, 9.81);
      }

      expect(recorder.frameCount, 20);

      // Restart
      recorder.start();
      expect(recorder.frameCount, 0);
      expect(recorder.jumps.length, 0);
      expect(recorder.gpsTrack.length, 0);
    });
  });
}
