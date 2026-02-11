export 'app_database.dart';
export 'session_repository.dart';
export 'jump_repository.dart';
export 'gps_repository.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';
import 'session_repository.dart';
import 'jump_repository.dart';
import 'gps_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref.watch(appDatabaseProvider));
});

final jumpRepositoryProvider = Provider<JumpRepository>((ref) {
  return JumpRepository(ref.watch(appDatabaseProvider));
});

final gpsRepositoryProvider = Provider<GpsRepository>((ref) {
  return GpsRepository(ref.watch(appDatabaseProvider));
});
