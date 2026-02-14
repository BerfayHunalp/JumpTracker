export 'sensor_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sensor_service.dart';

/// Provides the real sensor service. No simulator.
final sensorSourceProvider = Provider((ref) {
  return SensorService();
});
