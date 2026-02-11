import 'package:drift/drift.dart';
import 'app_database.dart';

class GpsRepository {
  final AppDatabase _db;

  GpsRepository(this._db);

  Future<void> insertPoints(List<GpsPointsCompanion> points) async {
    await _db.batch((batch) {
      batch.insertAll(_db.gpsPoints, points);
    });
  }

  Future<List<GpsPoint>> getPointsForSession(String sessionId) {
    return (_db.select(_db.gpsPoints)
          ..where((p) => p.sessionId.equals(sessionId))
          ..orderBy([(p) => OrderingTerm.asc(p.timestampUs)]))
        .get();
  }
}
