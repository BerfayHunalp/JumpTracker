import 'package:drift/drift.dart';
import 'app_database.dart';

class SessionRepository {
  final AppDatabase _db;

  SessionRepository(this._db);

  // ---- Create / Update ----

  Future<void> insertSession({
    required String id,
    required DateTime startedAt,
  }) {
    return _db.into(_db.sessions).insert(SessionsCompanion.insert(
          id: id,
          startedAt: startedAt,
        ));
  }

  Future<void> finishSession({
    required String id,
    required DateTime endedAt,
    required int totalJumps,
    required double maxAirtimeMs,
    required double totalVerticalM,
  }) {
    return (_db.update(_db.sessions)..where((s) => s.id.equals(id))).write(
      SessionsCompanion(
        endedAt: Value(endedAt),
        totalJumps: Value(totalJumps),
        maxAirtimeMs: Value(maxAirtimeMs),
        totalVerticalM: Value(totalVerticalM),
      ),
    );
  }

  // ---- Read ----

  Future<List<Session>> getAllSessions() {
    return (_db.select(_db.sessions)
          ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
        .get();
  }

  Future<Session?> getSessionById(String id) {
    return (_db.select(_db.sessions)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  // ---- Sync ----

  Future<List<Session>> getUnsyncedSessions() {
    return (_db.select(_db.sessions)
          ..where((s) =>
              s.syncedAt.isNull() & s.endedAt.isNotNull())
          ..orderBy([(s) => OrderingTerm.asc(s.startedAt)]))
        .get();
  }

  Future<void> markSessionSynced(String id) {
    return (_db.update(_db.sessions)..where((s) => s.id.equals(id))).write(
      SessionsCompanion(syncedAt: Value(DateTime.now())),
    );
  }

  // ---- Aggregate stats ----

  Future<int> getTotalSessionCount() async {
    final query = _db.selectOnly(_db.sessions)
      ..addColumns([_db.sessions.id.count()]);
    final row = await query.getSingle();
    return row.read(_db.sessions.id.count()) ?? 0;
  }

  Future<int> getTotalJumpCount() async {
    final query = _db.selectOnly(_db.jumps)
      ..addColumns([_db.jumps.id.count()]);
    final row = await query.getSingle();
    return row.read(_db.jumps.id.count()) ?? 0;
  }

  Future<double> getMaxAirtimeAllTime() async {
    final query = _db.selectOnly(_db.jumps)
      ..addColumns([_db.jumps.airtimeMs.max()]);
    final row = await query.getSingle();
    return row.read(_db.jumps.airtimeMs.max()) ?? 0;
  }

  Future<double> getTotalVerticalAllTime() async {
    final query = _db.selectOnly(_db.sessions)
      ..addColumns([_db.sessions.totalVerticalM.sum()]);
    final row = await query.getSingle();
    return row.read(_db.sessions.totalVerticalM.sum()) ?? 0;
  }
}
