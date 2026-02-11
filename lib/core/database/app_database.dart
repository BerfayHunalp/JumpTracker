import 'package:drift/drift.dart';

import 'connection/native.dart' if (dart.library.html) 'connection/web.dart'
    as connection;

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Table definitions
// ---------------------------------------------------------------------------

class Sessions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get resortName => text().nullable()();
  IntColumn get totalJumps => integer().withDefault(const Constant(0))();
  RealColumn get maxAirtimeMs => real().withDefault(const Constant(0))();
  RealColumn get totalVerticalM => real().withDefault(const Constant(0))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Jumps extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get runId => text()();
  IntColumn get takeoffTimestampUs => integer()();
  IntColumn get landingTimestampUs => integer()();
  RealColumn get airtimeMs => real()();
  RealColumn get distanceM => real()();
  RealColumn get heightM => real()();
  RealColumn get speedKmh => real()();
  RealColumn get landingGForce => real()();
  RealColumn get latTakeoff => real().nullable()();
  RealColumn get lonTakeoff => real().nullable()();
  RealColumn get latLanding => real().nullable()();
  RealColumn get lonLanding => real().nullable()();
  RealColumn get altitudeTakeoff => real().nullable()();
  TextColumn get trickLabel => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Runs extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  RealColumn get startAltitude => real()();
  RealColumn get endAltitude => real()();
  RealColumn get verticalDropM => real()();
  RealColumn get maxSpeedKmh => real()();
  RealColumn get distanceM => real()();
  RealColumn get durationS => real()();
  BoolColumn get isLift => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class GpsPoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text()();
  IntColumn get timestampUs => integer()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get altitude => real()();
  RealColumn get speed => real()();
  RealColumn get bearing => real()();
  RealColumn get accuracy => real()();
  TextColumn get runId => text().nullable()();
}

// ---------------------------------------------------------------------------
// Database class
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [Sessions, Jumps, Runs, GpsPoints])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connection.openConnection());

  // For testing
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.addColumn(sessions, sessions.syncedAt);
          }
          if (from < 3) {
            await migrator.addColumn(jumps, jumps.trickLabel);
          }
        },
      );
}
