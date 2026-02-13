import 'package:drift/drift.dart';
import 'app_database.dart';
import '../models/trick.dart';

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
    required int airtimeMs,
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

  // ---- Update ----

  Future<void> updateJumpTricks(String jumpId, String? trickLabel) {
    return (_db.update(_db.jumps)..where((j) => j.id.equals(jumpId))).write(
      JumpsCompanion(trickLabel: Value(trickLabel)),
    );
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

  Future<List<Jump>> getAllJumpsChronological() {
    return (_db.select(_db.jumps)
          ..orderBy([(j) => OrderingTerm.asc(j.takeoffTimestampUs)]))
        .get();
  }

  Future<double> getMaxSpeedAllTime() async {
    final query = _db.selectOnly(_db.jumps)
      ..addColumns([_db.jumps.speedKmh.max()]);
    final row = await query.getSingle();
    return row.read(_db.jumps.speedKmh.max()) ?? 0;
  }

  Future<double> getMaxLandingGForceAllTime() async {
    final query = _db.selectOnly(_db.jumps)
      ..addColumns([_db.jumps.landingGForce.max()]);
    final row = await query.getSingle();
    return row.read(_db.jumps.landingGForce.max()) ?? 0;
  }

  Future<double> getMaxHeightAllTime() async {
    final query = _db.selectOnly(_db.jumps)
      ..addColumns([_db.jumps.heightM.max()]);
    final row = await query.getSingle();
    return row.read(_db.jumps.heightM.max()) ?? 0;
  }

  Future<double> getMaxDistanceAllTime() async {
    final query = _db.selectOnly(_db.jumps)
      ..addColumns([_db.jumps.distanceM.max()]);
    final row = await query.getSingle();
    return row.read(_db.jumps.distanceM.max()) ?? 0;
  }

  Future<double> getMaxScoreAllTime() async {
    final all = await _db.select(_db.jumps).get();
    if (all.isEmpty) return 0;
    double maxScore = 0;
    for (final j in all) {
      final score = computeJumpScore(
        airtimeMs: j.airtimeMs,
        heightM: j.heightM,
        distanceM: j.distanceM,
        trickLabel: j.trickLabel,
      );
      if (score > maxScore) maxScore = score;
    }
    return maxScore;
  }

  Future<int> getTrickedJumpCount() async {
    final all = await (_db.select(_db.jumps)
          ..where((j) => j.trickLabel.isNotNull()))
        .get();
    return all.where((j) => j.trickLabel != null && j.trickLabel!.isNotEmpty).length;
  }

  Future<List<String>> getAllTrickLabelsRaw() async {
    final all = await (_db.select(_db.jumps)
          ..where((j) => j.trickLabel.isNotNull()))
        .get();
    return all
        .map((j) => j.trickLabel)
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toList();
  }

  Future<Jump?> getBestJumpByScore() async {
    // Score is computed, so fetch all and sort in-memory
    // (for small datasets this is fine)
    final all = await _db.select(_db.jumps).get();
    if (all.isEmpty) return null;
    all.sort((a, b) {
      final scoreA = computeJumpScore(
        airtimeMs: a.airtimeMs,
        heightM: a.heightM,
        distanceM: a.distanceM,
        trickLabel: a.trickLabel,
      );
      final scoreB = computeJumpScore(
        airtimeMs: b.airtimeMs,
        heightM: b.heightM,
        distanceM: b.distanceM,
        trickLabel: b.trickLabel,
      );
      return scoreB.compareTo(scoreA);
    });
    return all.first;
  }
}
