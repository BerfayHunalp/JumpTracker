export 'sensor_service.dart';

import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sensor_service.dart';
import '../../features/session/providers/sensor_simulator.dart';

/// Whether to use simulated sensors (desktop/web) or real hardware sensors.
final useMockSensorsProvider = StateProvider<bool>((ref) {
  if (kIsWeb) return true;
  final platform = defaultTargetPlatform;
  if (platform == TargetPlatform.windows ||
      platform == TargetPlatform.macOS ||
      platform == TargetPlatform.linux) {
    return true;
  }
  return false;
});

/// Returns a SensorSimulator on desktop or a SensorService on mobile.
/// Both expose the same fields (currentGForce, currentSpeedKmh, etc.).
final sensorSourceProvider = Provider((ref) {
  final useMock = ref.watch(useMockSensorsProvider);
  if (useMock) {
    return SensorSimulator();
  }
  return SensorService();
});
