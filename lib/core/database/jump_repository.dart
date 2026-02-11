import 'package:drift/drift.dart';
import 'app_database.dart';

class JumpRepository {
  final AppDatabase _db;

  JumpRepository(this._db);

  // ---- Create ----

  Future<void> insertJump({
    required String id,
    required String sessionId,
    required String runId,
    required int takeoffTimestampUs,
    required int landingTimestampUs,
    required double airtimeMs,
    required double distanceM,
    required double heightM,
    required double speedKmh,
    required double landingGForce,
    double? latTakeoff,
    double? lonTakeoff,
    double? latLanding,
    double? lonLanding,
    double? altitudeTakeoff,
  }) {
    return _db.into(_db.jumps).insert(JumpsCompanion.insert(
          id: id,
          sessionId: sessionId,
          runId: runId,
          takeoffTimestampUs: takeoffTimestampUs,
          landingTimestampUs: landingTimestampUs,
          airtimeMs: airtimeMs,
          distanceM: distanceM,
          heightM: heightM,
          speedKmh: speedKmh,
          landingGForce: landingGForce,
          latTakeoff: Value(latTakeoff),
          lonTakeoff: Value(lonTakeoff),
          latLanding: Value(latLanding),
          lonLanding: Value(lonLanding),
          altitudeTakeoff: Value(altitudeTakeoff),
        ));
  }

  // ---- Read ----

  Future<Jump?> getJumpById(String id) {
    return (_db.select(_db.jumps)..where((j) => j.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<Jump>> getJumpsForSession(String sessionId) {
    return (_db.select(_db.jumps)
          ..where((j) => j.sessionId.equals(sessionId))
          ..orderBy([(j) => OrderingTerm.asc(j.takeoffTimestampUs)]))
        .get();
  }

  // ---- Best-of queries ----

  Future<Jump?> getBestJumpByAirtime() {
    return (_db.select(_db.jumps)
          ..orderBy([(j) => OrderingTerm.desc(j.airtimeMs)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<Jump?> getBestJumpByDistance() {
    return (_db.select(_db.jumps)
          ..orderBy([(j) => OrderingTerm.desc(j.distanceM)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<Jump?> getBestJumpByHeight() {
    return (_db.select(_db.jumps)
          ..orderBy([(j) => OrderingTerm.desc(j.heightM)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<Jump?> getBestJumpByScore() async {
    // Score is computed, so fetch all and sort in-memory
    // (for small datasets this is fine)
    final all = await _db.select(_db.jumps).get();
    if (all.isEmpty) return null;
    all.sort((a, b) {
      final scoreA = (a.airtimeMs / 100) * 40 + a.heightM * 30 + a.distanceM * 10;
      final scoreB = (b.airtimeMs / 100) * 40 + b.heightM * 30 + b.distanceM * 10;
      return scoreB.compareTo(scoreA);
    });
    return all.first;
  }
}
