import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart' as geo_android;

/// Real hardware sensor service that mirrors the SensorSimulator API.
/// Provides accelerometer, GPS, and barometer data from device sensors.
class SensorService {
  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<Position>? _gpsSub;

  // Callbacks for SessionNotifier
  void Function(int timestampUs, double x, double y, double z)? onAccel;
  void Function({
    required double latitude,
    required double longitude,
    required double altitude,
    required double speed,
    required double bearing,
    required double accuracy,
    required double speedAccuracy,
    required int timestampUs,
  })? onGps;
  void Function(double pressureHpa)? onPressure;

  // Current values for UI display
  double currentGForce = 1.0;
  double currentSpeedKmh = 0;
  double currentAltitude = 0;
  double currentPressure = 1013.25;

  Future<void> start() async {
    // ---- GPS permissions ----
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    // Request background location (Android 10+)
    if (permission == LocationPermission.whileInUse) {
      final bgPermission = await Geolocator.requestPermission();
      // If they still only grant whileInUse, that's ok — we'll work with it
      if (bgPermission == LocationPermission.always) {
        permission = bgPermission;
      }
    }

    // ---- Accelerometer (~100Hz) ----
    _accelSub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 10),
    ).listen((event) {
      final now = DateTime.now().microsecondsSinceEpoch;
      final mag = math.sqrt(
          event.x * event.x + event.y * event.y + event.z * event.z);
      currentGForce = mag / 9.80665;
      onAccel?.call(now, event.x, event.y, event.z);
    });

    // ---- GPS position stream (with foreground service for background tracking) ----
    final LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = geo_android.AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        intervalDuration: const Duration(milliseconds: 500),
        forceLocationManager: false,
        foregroundNotificationConfig: const geo_android.ForegroundNotificationConfig(
          notificationText: 'Ski Tracker is recording your session',
          notificationTitle: 'Recording session',
          enableWakeLock: true,
        ),
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      );
    }
    _gpsSub = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((position) {
      // Use GPS-reported timestamp (satellite time) instead of DateTime.now()
      // to avoid ~50-200ms callback delivery latency.
      final timestampUs = position.timestamp.microsecondsSinceEpoch;
      currentSpeedKmh = position.speed * 3.6;
      currentAltitude = position.altitude;
      onGps?.call(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        speed: position.speed,
        bearing: position.heading,
        accuracy: position.accuracy,
        speedAccuracy: position.speedAccuracy,
        timestampUs: timestampUs,
      );
    });

    // Note: environment_sensors barometer omitted for now — many devices
    // don't have one. Altitude comes from GPS instead.
  }

  void stop() {
    _accelSub?.cancel();
    _accelSub = null;
    _gpsSub?.cancel();
    _gpsSub = null;
  }

  void reset() {
    currentGForce = 1.0;
    currentSpeedKmh = 0;
    currentAltitude = 0;
  }
}
