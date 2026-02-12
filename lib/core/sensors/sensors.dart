export 'sensor_service.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sensor_service.dart';
import '../../features/session/providers/sensor_simulator.dart';

/// Detect if running on an emulator.
/// Android emulators have fingerprints containing "sdk" or "generic".
bool get isEmulator {
  try {
    if (!Platform.isAndroid) return false;
    // On real devices, Platform.operatingSystemVersion contains the build;
    // on emulators it contains "sdk_gphone" or similar
    final osVer = Platform.operatingSystemVersion.toLowerCase();
    return osVer.contains('sdk') || osVer.contains('emulator') || osVer.contains('generic');
  } catch (_) {
    return false;
  }
}

/// Whether to use simulated sensors (desktop/web/emulator) or real hardware sensors.
final useMockSensorsProvider = StateProvider<bool>((ref) {
  if (kIsWeb) return true;
  final platform = defaultTargetPlatform;
  if (platform == TargetPlatform.windows ||
      platform == TargetPlatform.macOS ||
      platform == TargetPlatform.linux) {
    return true;
  }
  // Auto-enable simulator on Android emulator
  if (platform == TargetPlatform.android && isEmulator) {
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
