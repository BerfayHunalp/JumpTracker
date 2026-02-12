// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endedAtMeta =
      const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
      'ended_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _resortNameMeta =
      const VerificationMeta('resortName');
  @override
  late final GeneratedColumn<String> resortName = GeneratedColumn<String>(
      'resort_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _totalJumpsMeta =
      const VerificationMeta('totalJumps');
  @override
  late final GeneratedColumn<int> totalJumps = GeneratedColumn<int>(
      'total_jumps', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _maxAirtimeMsMeta =
      const VerificationMeta('maxAirtimeMs');
  @override
  late final GeneratedColumn<double> maxAirtimeMs = GeneratedColumn<double>(
      'max_airtime_ms', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalVerticalMMeta =
      const VerificationMeta('totalVerticalM');
  @override
  late final GeneratedColumn<double> totalVerticalM = GeneratedColumn<double>(
      'total_vertical_m', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        startedAt,
        endedAt,
        resortName,
        totalJumps,
        maxAirtimeMs,
        totalVerticalM,
        syncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(Insertable<Session> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta,
          endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    if (data.containsKey('resort_name')) {
      context.handle(
          _resortNameMeta,
          resortName.isAcceptableOrUnknown(
              data['resort_name']!, _resortNameMeta));
    }
    if (data.containsKey('total_jumps')) {
      context.handle(
          _totalJumpsMeta,
          totalJumps.isAcceptableOrUnknown(
              data['total_jumps']!, _totalJumpsMeta));
    }
    if (data.containsKey('max_airtime_ms')) {
      context.handle(
          _maxAirtimeMsMeta,
          maxAirtimeMs.isAcceptableOrUnknown(
              data['max_airtime_ms']!, _maxAirtimeMsMeta));
    }
    if (data.containsKey('total_vertical_m')) {
      context.handle(
          _totalVerticalMMeta,
          totalVerticalM.isAcceptableOrUnknown(
              data['total_vertical_m']!, _totalVerticalMMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      endedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ended_at']),
      resortName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}resort_name']),
      totalJumps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_jumps'])!,
      maxAirtimeMs: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}max_airtime_ms'])!,
      totalVerticalM: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}total_vertical_m'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? resortName;
  final int totalJumps;
  final double maxAirtimeMs;
  final double totalVerticalM;
  final DateTime? syncedAt;
  const Session(
      {required this.id,
      required this.startedAt,
      this.endedAt,
      this.resortName,
      required this.totalJumps,
      required this.maxAirtimeMs,
      required this.totalVerticalM,
      this.syncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || resortName != null) {
      map['resort_name'] = Variable<String>(resortName);
    }
    map['total_jumps'] = Variable<int>(totalJumps);
    map['max_airtime_ms'] = Variable<double>(maxAirtimeMs);
    map['total_vertical_m'] = Variable<double>(totalVerticalM);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      resortName: resortName == null && nullToAbsent
          ? const Value.absent()
          : Value(resortName),
      totalJumps: Value(totalJumps),
      maxAirtimeMs: Value(maxAirtimeMs),
      totalVerticalM: Value(totalVerticalM),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory Session.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<String>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      resortName: serializer.fromJson<String?>(json['resortName']),
      totalJumps: serializer.fromJson<int>(json['totalJumps']),
      maxAirtimeMs: serializer.fromJson<double>(json['maxAirtimeMs']),
      totalVerticalM: serializer.fromJson<double>(json['totalVerticalM']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'resortName': serializer.toJson<String?>(resortName),
      'totalJumps': serializer.toJson<int>(totalJumps),
      'maxAirtimeMs': serializer.toJson<double>(maxAirtimeMs),
      'totalVerticalM': serializer.toJson<double>(totalVerticalM),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  Session copyWith(
          {String? id,
          DateTime? startedAt,
          Value<DateTime?> endedAt = const Value.absent(),
          Value<String?> resortName = const Value.absent(),
          int? totalJumps,
          double? maxAirtimeMs,
          double? totalVerticalM,
          Value<DateTime?> syncedAt = const Value.absent()}) =>
      Session(
        id: id ?? this.id,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt.present ? endedAt.value : this.endedAt,
        resortName: resortName.present ? resortName.value : this.resortName,
        totalJumps: totalJumps ?? this.totalJumps,
        maxAirtimeMs: maxAirtimeMs ?? this.maxAirtimeMs,
        totalVerticalM: totalVerticalM ?? this.totalVerticalM,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
      );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      resortName:
          data.resortName.present ? data.resortName.value : this.resortName,
      totalJumps:
          data.totalJumps.present ? data.totalJumps.value : this.totalJumps,
      maxAirtimeMs: data.maxAirtimeMs.present
          ? data.maxAirtimeMs.value
          : this.maxAirtimeMs,
      totalVerticalM: data.totalVerticalM.present
          ? data.totalVerticalM.value
          : this.totalVerticalM,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('resortName: $resortName, ')
          ..write('totalJumps: $totalJumps, ')
          ..write('maxAirtimeMs: $maxAirtimeMs, ')
          ..write('totalVerticalM: $totalVerticalM, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, startedAt, endedAt, resortName,
      totalJumps, maxAirtimeMs, totalVerticalM, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.resortName == this.resortName &&
          other.totalJumps == this.totalJumps &&
          other.maxAirtimeMs == this.maxAirtimeMs &&
          other.totalVerticalM == this.totalVerticalM &&
          other.syncedAt == this.syncedAt);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> id;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String?> resortName;
  final Value<int> totalJumps;
  final Value<double> maxAirtimeMs;
  final Value<double> totalVerticalM;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.resortName = const Value.absent(),
    this.totalJumps = const Value.absent(),
    this.maxAirtimeMs = const Value.absent(),
    this.totalVerticalM = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.resortName = const Value.absent(),
    this.totalJumps = const Value.absent(),
    this.maxAirtimeMs = const Value.absent(),
    this.totalVerticalM = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        startedAt = Value(startedAt);
  static Insertable<Session> custom({
    Expression<String>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? resortName,
    Expression<int>? totalJumps,
    Expression<double>? maxAirtimeMs,
    Expression<double>? totalVerticalM,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (resortName != null) 'resort_name': resortName,
      if (totalJumps != null) 'total_jumps': totalJumps,
      if (maxAirtimeMs != null) 'max_airtime_ms': maxAirtimeMs,
      if (totalVerticalM != null) 'total_vertical_m': totalVerticalM,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? startedAt,
      Value<DateTime?>? endedAt,
      Value<String?>? resortName,
      Value<int>? totalJumps,
      Value<double>? maxAirtimeMs,
      Value<double>? totalVerticalM,
      Value<DateTime?>? syncedAt,
      Value<int>? rowid}) {
    return SessionsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      resortName: resortName ?? this.resortName,
      totalJumps: totalJumps ?? this.totalJumps,
      maxAirtimeMs: maxAirtimeMs ?? this.maxAirtimeMs,
      totalVerticalM: totalVerticalM ?? this.totalVerticalM,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (resortName.present) {
      map['resort_name'] = Variable<String>(resortName.value);
    }
    if (totalJumps.present) {
      map['total_jumps'] = Variable<int>(totalJumps.value);
    }
    if (maxAirtimeMs.present) {
      map['max_airtime_ms'] = Variable<double>(maxAirtimeMs.value);
    }
    if (totalVerticalM.present) {
      map['total_vertical_m'] = Variable<double>(totalVerticalM.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('resortName: $resortName, ')
          ..write('totalJumps: $totalJumps, ')
          ..write('maxAirtimeMs: $maxAirtimeMs, ')
          ..write('totalVerticalM: $totalVerticalM, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JumpsTable extends Jumps with TableInfo<$JumpsTable, Jump> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JumpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
      'run_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _takeoffTimestampUsMeta =
      const VerificationMeta('takeoffTimestampUs');
  @override
  late final GeneratedColumn<int> takeoffTimestampUs = GeneratedColumn<int>(
      'takeoff_timestamp_us', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _landingTimestampUsMeta =
      const VerificationMeta('landingTimestampUs');
  @override
  late final GeneratedColumn<int> landingTimestampUs = GeneratedColumn<int>(
      'landing_timestamp_us', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _airtimeMsMeta =
      const VerificationMeta('airtimeMs');
  @override
  late final GeneratedColumn<int> airtimeMs = GeneratedColumn<int>(
      'airtime_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _distanceMMeta =
      const VerificationMeta('distanceM');
  @override
  late final GeneratedColumn<double> distanceM = GeneratedColumn<double>(
      'distance_m', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _heightMMeta =
      const VerificationMeta('heightM');
  @override
  late final GeneratedColumn<double> heightM = GeneratedColumn<double>(
      'height_m', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _speedKmhMeta =
      const VerificationMeta('speedKmh');
  @override
  late final GeneratedColumn<double> speedKmh = GeneratedColumn<double>(
      'speed_kmh', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _landingGForceMeta =
      const VerificationMeta('landingGForce');
  @override
  late final GeneratedColumn<double> landingGForce = GeneratedColumn<double>(
      'landing_g_force', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _latTakeoffMeta =
      const VerificationMeta('latTakeoff');
  @override
  late final GeneratedColumn<double> latTakeoff = GeneratedColumn<double>(
      'lat_takeoff', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _lonTakeoffMeta =
      const VerificationMeta('lonTakeoff');
  @override
  late final GeneratedColumn<double> lonTakeoff = GeneratedColumn<double>(
      'lon_takeoff', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _latLandingMeta =
      const VerificationMeta('latLanding');
  @override
  late final GeneratedColumn<double> latLanding = GeneratedColumn<double>(
      'lat_landing', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _lonLandingMeta =
      const VerificationMeta('lonLanding');
  @override
  late final GeneratedColumn<double> lonLanding = GeneratedColumn<double>(
      'lon_landing', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _altitudeTakeoffMeta =
      const VerificationMeta('altitudeTakeoff');
  @override
  late final GeneratedColumn<double> altitudeTakeoff = GeneratedColumn<double>(
      'altitude_takeoff', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _trickLabelMeta =
      const VerificationMeta('trickLabel');
  @override
  late final GeneratedColumn<String> trickLabel = GeneratedColumn<String>(
      'trick_label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionId,
        runId,
        takeoffTimestampUs,
        landingTimestampUs,
        airtimeMs,
        distanceM,
        heightM,
        speedKmh,
        landingGForce,
        latTakeoff,
        lonTakeoff,
        latLanding,
        lonLanding,
        altitudeTakeoff,
        trickLabel
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jumps';
  @override
  VerificationContext validateIntegrity(Insertable<Jump> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('run_id')) {
      context.handle(
          _runIdMeta, runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta));
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('takeoff_timestamp_us')) {
      context.handle(
          _takeoffTimestampUsMeta,
          takeoffTimestampUs.isAcceptableOrUnknown(
              data['takeoff_timestamp_us']!, _takeoffTimestampUsMeta));
    } else if (isInserting) {
      context.missing(_takeoffTimestampUsMeta);
    }
    if (data.containsKey('landing_timestamp_us')) {
      context.handle(
          _landingTimestampUsMeta,
          landingTimestampUs.isAcceptableOrUnknown(
              data['landing_timestamp_us']!, _landingTimestampUsMeta));
    } else if (isInserting) {
      context.missing(_landingTimestampUsMeta);
    }
    if (data.containsKey('airtime_ms')) {
      context.handle(_airtimeMsMeta,
          airtimeMs.isAcceptableOrUnknown(data['airtime_ms']!, _airtimeMsMeta));
    } else if (isInserting) {
      context.missing(_airtimeMsMeta);
    }
    if (data.containsKey('distance_m')) {
      context.handle(_distanceMMeta,
          distanceM.isAcceptableOrUnknown(data['distance_m']!, _distanceMMeta));
    } else if (isInserting) {
      context.missing(_distanceMMeta);
    }
    if (data.containsKey('height_m')) {
      context.handle(_heightMMeta,
          heightM.isAcceptableOrUnknown(data['height_m']!, _heightMMeta));
    } else if (isInserting) {
      context.missing(_heightMMeta);
    }
    if (data.containsKey('speed_kmh')) {
      context.handle(_speedKmhMeta,
          speedKmh.isAcceptableOrUnknown(data['speed_kmh']!, _speedKmhMeta));
    } else if (isInserting) {
      context.missing(_speedKmhMeta);
    }
    if (data.containsKey('landing_g_force')) {
      context.handle(
          _landingGForceMeta,
          landingGForce.isAcceptableOrUnknown(
              data['landing_g_force']!, _landingGForceMeta));
    } else if (isInserting) {
      context.missing(_landingGForceMeta);
    }
    if (data.containsKey('lat_takeoff')) {
      context.handle(
          _latTakeoffMeta,
          latTakeoff.isAcceptableOrUnknown(
              data['lat_takeoff']!, _latTakeoffMeta));
    }
    if (data.containsKey('lon_takeoff')) {
      context.handle(
          _lonTakeoffMeta,
          lonTakeoff.isAcceptableOrUnknown(
              data['lon_takeoff']!, _lonTakeoffMeta));
    }
    if (data.containsKey('lat_landing')) {
      context.handle(
          _latLandingMeta,
          latLanding.isAcceptableOrUnknown(
              data['lat_landing']!, _latLandingMeta));
    }
    if (data.containsKey('lon_landing')) {
      context.handle(
          _lonLandingMeta,
          lonLanding.isAcceptableOrUnknown(
              data['lon_landing']!, _lonLandingMeta));
    }
    if (data.containsKey('altitude_takeoff')) {
      context.handle(
          _altitudeTakeoffMeta,
          altitudeTakeoff.isAcceptableOrUnknown(
              data['altitude_takeoff']!, _altitudeTakeoffMeta));
    }
    if (data.containsKey('trick_label')) {
      context.handle(
          _trickLabelMeta,
          trickLabel.isAcceptableOrUnknown(
              data['trick_label']!, _trickLabelMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Jump map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Jump(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      runId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}run_id'])!,
      takeoffTimestampUs: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}takeoff_timestamp_us'])!,
      landingTimestampUs: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}landing_timestamp_us'])!,
      airtimeMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}airtime_ms'])!,
      distanceM: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}distance_m'])!,
      heightM: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}height_m'])!,
      speedKmh: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}speed_kmh'])!,
      landingGForce: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}landing_g_force'])!,
      latTakeoff: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat_takeoff']),
      lonTakeoff: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lon_takeoff']),
      latLanding: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat_landing']),
      lonLanding: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lon_landing']),
      altitudeTakeoff: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}altitude_takeoff']),
      trickLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trick_label']),
    );
  }

  @override
  $JumpsTable createAlias(String alias) {
    return $JumpsTable(attachedDatabase, alias);
  }
}

class Jump extends DataClass implements Insertable<Jump> {
  final String id;
  final String sessionId;
  final String runId;
  final int takeoffTimestampUs;
  final int landingTimestampUs;
  final int airtimeMs;
  final double distanceM;
  final double heightM;
  final double speedKmh;
  final double landingGForce;
  final double? latTakeoff;
  final double? lonTakeoff;
  final double? latLanding;
  final double? lonLanding;
  final double? altitudeTakeoff;
  final String? trickLabel;
  const Jump(
      {required this.id,
      required this.sessionId,
      required this.runId,
      required this.takeoffTimestampUs,
      required this.landingTimestampUs,
      required this.airtimeMs,
      required this.distanceM,
      required this.heightM,
      required this.speedKmh,
      required this.landingGForce,
      this.latTakeoff,
      this.lonTakeoff,
      this.latLanding,
      this.lonLanding,
      this.altitudeTakeoff,
      this.trickLabel});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['run_id'] = Variable<String>(runId);
    map['takeoff_timestamp_us'] = Variable<int>(takeoffTimestampUs);
    map['landing_timestamp_us'] = Variable<int>(landingTimestampUs);
    map['airtime_ms'] = Variable<int>(airtimeMs);
    map['distance_m'] = Variable<double>(distanceM);
    map['height_m'] = Variable<double>(heightM);
    map['speed_kmh'] = Variable<double>(speedKmh);
    map['landing_g_force'] = Variable<double>(landingGForce);
    if (!nullToAbsent || latTakeoff != null) {
      map['lat_takeoff'] = Variable<double>(latTakeoff);
    }
    if (!nullToAbsent || lonTakeoff != null) {
      map['lon_takeoff'] = Variable<double>(lonTakeoff);
    }
    if (!nullToAbsent || latLanding != null) {
      map['lat_landing'] = Variable<double>(latLanding);
    }
    if (!nullToAbsent || lonLanding != null) {
      map['lon_landing'] = Variable<double>(lonLanding);
    }
    if (!nullToAbsent || altitudeTakeoff != null) {
      map['altitude_takeoff'] = Variable<double>(altitudeTakeoff);
    }
    if (!nullToAbsent || trickLabel != null) {
      map['trick_label'] = Variable<String>(trickLabel);
    }
    return map;
  }

  JumpsCompanion toCompanion(bool nullToAbsent) {
    return JumpsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      runId: Value(runId),
      takeoffTimestampUs: Value(takeoffTimestampUs),
      landingTimestampUs: Value(landingTimestampUs),
      airtimeMs: Value(airtimeMs),
      distanceM: Value(distanceM),
      heightM: Value(heightM),
      speedKmh: Value(speedKmh),
      landingGForce: Value(landingGForce),
      latTakeoff: latTakeoff == null && nullToAbsent
          ? const Value.absent()
          : Value(latTakeoff),
      lonTakeoff: lonTakeoff == null && nullToAbsent
          ? const Value.absent()
          : Value(lonTakeoff),
      latLanding: latLanding == null && nullToAbsent
          ? const Value.absent()
          : Value(latLanding),
      lonLanding: lonLanding == null && nullToAbsent
          ? const Value.absent()
          : Value(lonLanding),
      altitudeTakeoff: altitudeTakeoff == null && nullToAbsent
          ? const Value.absent()
          : Value(altitudeTakeoff),
      trickLabel: trickLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(trickLabel),
    );
  }

  factory Jump.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Jump(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      runId: serializer.fromJson<String>(json['runId']),
      takeoffTimestampUs: serializer.fromJson<int>(json['takeoffTimestampUs']),
      landingTimestampUs: serializer.fromJson<int>(json['landingTimestampUs']),
      airtimeMs: serializer.fromJson<int>(json['airtimeMs']),
      distanceM: serializer.fromJson<double>(json['distanceM']),
      heightM: serializer.fromJson<double>(json['heightM']),
      speedKmh: serializer.fromJson<double>(json['speedKmh']),
      landingGForce: serializer.fromJson<double>(json['landingGForce']),
      latTakeoff: serializer.fromJson<double?>(json['latTakeoff']),
      lonTakeoff: serializer.fromJson<double?>(json['lonTakeoff']),
      latLanding: serializer.fromJson<double?>(json['latLanding']),
      lonLanding: serializer.fromJson<double?>(json['lonLanding']),
      altitudeTakeoff: serializer.fromJson<double?>(json['altitudeTakeoff']),
      trickLabel: serializer.fromJson<String?>(json['trickLabel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'runId': serializer.toJson<String>(runId),
      'takeoffTimestampUs': serializer.toJson<int>(takeoffTimestampUs),
      'landingTimestampUs': serializer.toJson<int>(landingTimestampUs),
      'airtimeMs': serializer.toJson<int>(airtimeMs),
      'distanceM': serializer.toJson<double>(distanceM),
      'heightM': serializer.toJson<double>(heightM),
      'speedKmh': serializer.toJson<double>(speedKmh),
      'landingGForce': serializer.toJson<double>(landingGForce),
      'latTakeoff': serializer.toJson<double?>(latTakeoff),
      'lonTakeoff': serializer.toJson<double?>(lonTakeoff),
      'latLanding': serializer.toJson<double?>(latLanding),
      'lonLanding': serializer.toJson<double?>(lonLanding),
      'altitudeTakeoff': serializer.toJson<double?>(altitudeTakeoff),
      'trickLabel': serializer.toJson<String?>(trickLabel),
    };
  }

  Jump copyWith(
          {String? id,
          String? sessionId,
          String? runId,
          int? takeoffTimestampUs,
          int? landingTimestampUs,
          int? airtimeMs,
          double? distanceM,
          double? heightM,
          double? speedKmh,
          double? landingGForce,
          Value<double?> latTakeoff = const Value.absent(),
          Value<double?> lonTakeoff = const Value.absent(),
          Value<double?> latLanding = const Value.absent(),
          Value<double?> lonLanding = const Value.absent(),
          Value<double?> altitudeTakeoff = const Value.absent(),
          Value<String?> trickLabel = const Value.absent()}) =>
      Jump(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        runId: runId ?? this.runId,
        takeoffTimestampUs: takeoffTimestampUs ?? this.takeoffTimestampUs,
        landingTimestampUs: landingTimestampUs ?? this.landingTimestampUs,
        airtimeMs: airtimeMs ?? this.airtimeMs,
        distanceM: distanceM ?? this.distanceM,
        heightM: heightM ?? this.heightM,
        speedKmh: speedKmh ?? this.speedKmh,
        landingGForce: landingGForce ?? this.landingGForce,
        latTakeoff: latTakeoff.present ? latTakeoff.value : this.latTakeoff,
        lonTakeoff: lonTakeoff.present ? lonTakeoff.value : this.lonTakeoff,
        latLanding: latLanding.present ? latLanding.value : this.latLanding,
        lonLanding: lonLanding.present ? lonLanding.value : this.lonLanding,
        altitudeTakeoff: altitudeTakeoff.present
            ? altitudeTakeoff.value
            : this.altitudeTakeoff,
        trickLabel: trickLabel.present ? trickLabel.value : this.trickLabel,
      );
  Jump copyWithCompanion(JumpsCompanion data) {
    return Jump(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      runId: data.runId.present ? data.runId.value : this.runId,
      takeoffTimestampUs: data.takeoffTimestampUs.present
          ? data.takeoffTimestampUs.value
          : this.takeoffTimestampUs,
      landingTimestampUs: data.landingTimestampUs.present
          ? data.landingTimestampUs.value
          : this.landingTimestampUs,
      airtimeMs: data.airtimeMs.present ? data.airtimeMs.value : this.airtimeMs,
      distanceM: data.distanceM.present ? data.distanceM.value : this.distanceM,
      heightM: data.heightM.present ? data.heightM.value : this.heightM,
      speedKmh: data.speedKmh.present ? data.speedKmh.value : this.speedKmh,
      landingGForce: data.landingGForce.present
          ? data.landingGForce.value
          : this.landingGForce,
      latTakeoff:
          data.latTakeoff.present ? data.latTakeoff.value : this.latTakeoff,
      lonTakeoff:
          data.lonTakeoff.present ? data.lonTakeoff.value : this.lonTakeoff,
      latLanding:
          data.latLanding.present ? data.latLanding.value : this.latLanding,
      lonLanding:
          data.lonLanding.present ? data.lonLanding.value : this.lonLanding,
      altitudeTakeoff: data.altitudeTakeoff.present
          ? data.altitudeTakeoff.value
          : this.altitudeTakeoff,
      trickLabel:
          data.trickLabel.present ? data.trickLabel.value : this.trickLabel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Jump(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('runId: $runId, ')
          ..write('takeoffTimestampUs: $takeoffTimestampUs, ')
          ..write('landingTimestampUs: $landingTimestampUs, ')
          ..write('airtimeMs: $airtimeMs, ')
          ..write('distanceM: $distanceM, ')
          ..write('heightM: $heightM, ')
          ..write('speedKmh: $speedKmh, ')
          ..write('landingGForce: $landingGForce, ')
          ..write('latTakeoff: $latTakeoff, ')
          ..write('lonTakeoff: $lonTakeoff, ')
          ..write('latLanding: $latLanding, ')
          ..write('lonLanding: $lonLanding, ')
          ..write('altitudeTakeoff: $altitudeTakeoff, ')
          ..write('trickLabel: $trickLabel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      sessionId,
      runId,
      takeoffTimestampUs,
      landingTimestampUs,
      airtimeMs,
      distanceM,
      heightM,
      speedKmh,
      landingGForce,
      latTakeoff,
      lonTakeoff,
      latLanding,
      lonLanding,
      altitudeTakeoff,
      trickLabel);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Jump &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.runId == this.runId &&
          other.takeoffTimestampUs == this.takeoffTimestampUs &&
          other.landingTimestampUs == this.landingTimestampUs &&
          other.airtimeMs == this.airtimeMs &&
          other.distanceM == this.distanceM &&
          other.heightM == this.heightM &&
          other.speedKmh == this.speedKmh &&
          other.landingGForce == this.landingGForce &&
          other.latTakeoff == this.latTakeoff &&
          other.lonTakeoff == this.lonTakeoff &&
          other.latLanding == this.latLanding &&
          other.lonLanding == this.lonLanding &&
          other.altitudeTakeoff == this.altitudeTakeoff &&
          other.trickLabel == this.trickLabel);
}

class JumpsCompanion extends UpdateCompanion<Jump> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> runId;
  final Value<int> takeoffTimestampUs;
  final Value<int> landingTimestampUs;
  final Value<int> airtimeMs;
  final Value<double> distanceM;
  final Value<double> heightM;
  final Value<double> speedKmh;
  final Value<double> landingGForce;
  final Value<double?> latTakeoff;
  final Value<double?> lonTakeoff;
  final Value<double?> latLanding;
  final Value<double?> lonLanding;
  final Value<double?> altitudeTakeoff;
  final Value<String?> trickLabel;
  final Value<int> rowid;
  const JumpsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.runId = const Value.absent(),
    this.takeoffTimestampUs = const Value.absent(),
    this.landingTimestampUs = const Value.absent(),
    this.airtimeMs = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.heightM = const Value.absent(),
    this.speedKmh = const Value.absent(),
    this.landingGForce = const Value.absent(),
    this.latTakeoff = const Value.absent(),
    this.lonTakeoff = const Value.absent(),
    this.latLanding = const Value.absent(),
    this.lonLanding = const Value.absent(),
    this.altitudeTakeoff = const Value.absent(),
    this.trickLabel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JumpsCompanion.insert({
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
    this.latTakeoff = const Value.absent(),
    this.lonTakeoff = const Value.absent(),
    this.latLanding = const Value.absent(),
    this.lonLanding = const Value.absent(),
    this.altitudeTakeoff = const Value.absent(),
    this.trickLabel = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sessionId = Value(sessionId),
        runId = Value(runId),
        takeoffTimestampUs = Value(takeoffTimestampUs),
        landingTimestampUs = Value(landingTimestampUs),
        airtimeMs = Value(airtimeMs),
        distanceM = Value(distanceM),
        heightM = Value(heightM),
        speedKmh = Value(speedKmh),
        landingGForce = Value(landingGForce);
  static Insertable<Jump> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? runId,
    Expression<int>? takeoffTimestampUs,
    Expression<int>? landingTimestampUs,
    Expression<int>? airtimeMs,
    Expression<double>? distanceM,
    Expression<double>? heightM,
    Expression<double>? speedKmh,
    Expression<double>? landingGForce,
    Expression<double>? latTakeoff,
    Expression<double>? lonTakeoff,
    Expression<double>? latLanding,
    Expression<double>? lonLanding,
    Expression<double>? altitudeTakeoff,
    Expression<String>? trickLabel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (runId != null) 'run_id': runId,
      if (takeoffTimestampUs != null)
        'takeoff_timestamp_us': takeoffTimestampUs,
      if (landingTimestampUs != null)
        'landing_timestamp_us': landingTimestampUs,
      if (airtimeMs != null) 'airtime_ms': airtimeMs,
      if (distanceM != null) 'distance_m': distanceM,
      if (heightM != null) 'height_m': heightM,
      if (speedKmh != null) 'speed_kmh': speedKmh,
      if (landingGForce != null) 'landing_g_force': landingGForce,
      if (latTakeoff != null) 'lat_takeoff': latTakeoff,
      if (lonTakeoff != null) 'lon_takeoff': lonTakeoff,
      if (latLanding != null) 'lat_landing': latLanding,
      if (lonLanding != null) 'lon_landing': lonLanding,
      if (altitudeTakeoff != null) 'altitude_takeoff': altitudeTakeoff,
      if (trickLabel != null) 'trick_label': trickLabel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JumpsCompanion copyWith(
      {Value<String>? id,
      Value<String>? sessionId,
      Value<String>? runId,
      Value<int>? takeoffTimestampUs,
      Value<int>? landingTimestampUs,
      Value<int>? airtimeMs,
      Value<double>? distanceM,
      Value<double>? heightM,
      Value<double>? speedKmh,
      Value<double>? landingGForce,
      Value<double?>? latTakeoff,
      Value<double?>? lonTakeoff,
      Value<double?>? latLanding,
      Value<double?>? lonLanding,
      Value<double?>? altitudeTakeoff,
      Value<String?>? trickLabel,
      Value<int>? rowid}) {
    return JumpsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      runId: runId ?? this.runId,
      takeoffTimestampUs: takeoffTimestampUs ?? this.takeoffTimestampUs,
      landingTimestampUs: landingTimestampUs ?? this.landingTimestampUs,
      airtimeMs: airtimeMs ?? this.airtimeMs,
      distanceM: distanceM ?? this.distanceM,
      heightM: heightM ?? this.heightM,
      speedKmh: speedKmh ?? this.speedKmh,
      landingGForce: landingGForce ?? this.landingGForce,
      latTakeoff: latTakeoff ?? this.latTakeoff,
      lonTakeoff: lonTakeoff ?? this.lonTakeoff,
      latLanding: latLanding ?? this.latLanding,
      lonLanding: lonLanding ?? this.lonLanding,
      altitudeTakeoff: altitudeTakeoff ?? this.altitudeTakeoff,
      trickLabel: trickLabel ?? this.trickLabel,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    if (takeoffTimestampUs.present) {
      map['takeoff_timestamp_us'] = Variable<int>(takeoffTimestampUs.value);
    }
    if (landingTimestampUs.present) {
      map['landing_timestamp_us'] = Variable<int>(landingTimestampUs.value);
    }
    if (airtimeMs.present) {
      map['airtime_ms'] = Variable<int>(airtimeMs.value);
    }
    if (distanceM.present) {
      map['distance_m'] = Variable<double>(distanceM.value);
    }
    if (heightM.present) {
      map['height_m'] = Variable<double>(heightM.value);
    }
    if (speedKmh.present) {
      map['speed_kmh'] = Variable<double>(speedKmh.value);
    }
    if (landingGForce.present) {
      map['landing_g_force'] = Variable<double>(landingGForce.value);
    }
    if (latTakeoff.present) {
      map['lat_takeoff'] = Variable<double>(latTakeoff.value);
    }
    if (lonTakeoff.present) {
      map['lon_takeoff'] = Variable<double>(lonTakeoff.value);
    }
    if (latLanding.present) {
      map['lat_landing'] = Variable<double>(latLanding.value);
    }
    if (lonLanding.present) {
      map['lon_landing'] = Variable<double>(lonLanding.value);
    }
    if (altitudeTakeoff.present) {
      map['altitude_takeoff'] = Variable<double>(altitudeTakeoff.value);
    }
    if (trickLabel.present) {
      map['trick_label'] = Variable<String>(trickLabel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JumpsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('runId: $runId, ')
          ..write('takeoffTimestampUs: $takeoffTimestampUs, ')
          ..write('landingTimestampUs: $landingTimestampUs, ')
          ..write('airtimeMs: $airtimeMs, ')
          ..write('distanceM: $distanceM, ')
          ..write('heightM: $heightM, ')
          ..write('speedKmh: $speedKmh, ')
          ..write('landingGForce: $landingGForce, ')
          ..write('latTakeoff: $latTakeoff, ')
          ..write('lonTakeoff: $lonTakeoff, ')
          ..write('latLanding: $latLanding, ')
          ..write('lonLanding: $lonLanding, ')
          ..write('altitudeTakeoff: $altitudeTakeoff, ')
          ..write('trickLabel: $trickLabel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RunsTable extends Runs with TableInfo<$RunsTable, Run> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startAltitudeMeta =
      const VerificationMeta('startAltitude');
  @override
  late final GeneratedColumn<double> startAltitude = GeneratedColumn<double>(
      'start_altitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _endAltitudeMeta =
      const VerificationMeta('endAltitude');
  @override
  late final GeneratedColumn<double> endAltitude = GeneratedColumn<double>(
      'end_altitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _verticalDropMMeta =
      const VerificationMeta('verticalDropM');
  @override
  late final GeneratedColumn<double> verticalDropM = GeneratedColumn<double>(
      'vertical_drop_m', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _maxSpeedKmhMeta =
      const VerificationMeta('maxSpeedKmh');
  @override
  late final GeneratedColumn<double> maxSpeedKmh = GeneratedColumn<double>(
      'max_speed_kmh', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _distanceMMeta =
      const VerificationMeta('distanceM');
  @override
  late final GeneratedColumn<double> distanceM = GeneratedColumn<double>(
      'distance_m', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _durationSMeta =
      const VerificationMeta('durationS');
  @override
  late final GeneratedColumn<double> durationS = GeneratedColumn<double>(
      'duration_s', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _isLiftMeta = const VerificationMeta('isLift');
  @override
  late final GeneratedColumn<bool> isLift = GeneratedColumn<bool>(
      'is_lift', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_lift" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionId,
        startAltitude,
        endAltitude,
        verticalDropM,
        maxSpeedKmh,
        distanceM,
        durationS,
        isLift
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'runs';
  @override
  VerificationContext validateIntegrity(Insertable<Run> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('start_altitude')) {
      context.handle(
          _startAltitudeMeta,
          startAltitude.isAcceptableOrUnknown(
              data['start_altitude']!, _startAltitudeMeta));
    } else if (isInserting) {
      context.missing(_startAltitudeMeta);
    }
    if (data.containsKey('end_altitude')) {
      context.handle(
          _endAltitudeMeta,
          endAltitude.isAcceptableOrUnknown(
              data['end_altitude']!, _endAltitudeMeta));
    } else if (isInserting) {
      context.missing(_endAltitudeMeta);
    }
    if (data.containsKey('vertical_drop_m')) {
      context.handle(
          _verticalDropMMeta,
          verticalDropM.isAcceptableOrUnknown(
              data['vertical_drop_m']!, _verticalDropMMeta));
    } else if (isInserting) {
      context.missing(_verticalDropMMeta);
    }
    if (data.containsKey('max_speed_kmh')) {
      context.handle(
          _maxSpeedKmhMeta,
          maxSpeedKmh.isAcceptableOrUnknown(
              data['max_speed_kmh']!, _maxSpeedKmhMeta));
    } else if (isInserting) {
      context.missing(_maxSpeedKmhMeta);
    }
    if (data.containsKey('distance_m')) {
      context.handle(_distanceMMeta,
          distanceM.isAcceptableOrUnknown(data['distance_m']!, _distanceMMeta));
    } else if (isInserting) {
      context.missing(_distanceMMeta);
    }
    if (data.containsKey('duration_s')) {
      context.handle(_durationSMeta,
          durationS.isAcceptableOrUnknown(data['duration_s']!, _durationSMeta));
    } else if (isInserting) {
      context.missing(_durationSMeta);
    }
    if (data.containsKey('is_lift')) {
      context.handle(_isLiftMeta,
          isLift.isAcceptableOrUnknown(data['is_lift']!, _isLiftMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Run map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Run(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      startAltitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}start_altitude'])!,
      endAltitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}end_altitude'])!,
      verticalDropM: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}vertical_drop_m'])!,
      maxSpeedKmh: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}max_speed_kmh'])!,
      distanceM: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}distance_m'])!,
      durationS: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}duration_s'])!,
      isLift: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_lift'])!,
    );
  }

  @override
  $RunsTable createAlias(String alias) {
    return $RunsTable(attachedDatabase, alias);
  }
}

class Run extends DataClass implements Insertable<Run> {
  final String id;
  final String sessionId;
  final double startAltitude;
  final double endAltitude;
  final double verticalDropM;
  final double maxSpeedKmh;
  final double distanceM;
  final double durationS;
  final bool isLift;
  const Run(
      {required this.id,
      required this.sessionId,
      required this.startAltitude,
      required this.endAltitude,
      required this.verticalDropM,
      required this.maxSpeedKmh,
      required this.distanceM,
      required this.durationS,
      required this.isLift});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['start_altitude'] = Variable<double>(startAltitude);
    map['end_altitude'] = Variable<double>(endAltitude);
    map['vertical_drop_m'] = Variable<double>(verticalDropM);
    map['max_speed_kmh'] = Variable<double>(maxSpeedKmh);
    map['distance_m'] = Variable<double>(distanceM);
    map['duration_s'] = Variable<double>(durationS);
    map['is_lift'] = Variable<bool>(isLift);
    return map;
  }

  RunsCompanion toCompanion(bool nullToAbsent) {
    return RunsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      startAltitude: Value(startAltitude),
      endAltitude: Value(endAltitude),
      verticalDropM: Value(verticalDropM),
      maxSpeedKmh: Value(maxSpeedKmh),
      distanceM: Value(distanceM),
      durationS: Value(durationS),
      isLift: Value(isLift),
    );
  }

  factory Run.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Run(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      startAltitude: serializer.fromJson<double>(json['startAltitude']),
      endAltitude: serializer.fromJson<double>(json['endAltitude']),
      verticalDropM: serializer.fromJson<double>(json['verticalDropM']),
      maxSpeedKmh: serializer.fromJson<double>(json['maxSpeedKmh']),
      distanceM: serializer.fromJson<double>(json['distanceM']),
      durationS: serializer.fromJson<double>(json['durationS']),
      isLift: serializer.fromJson<bool>(json['isLift']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'startAltitude': serializer.toJson<double>(startAltitude),
      'endAltitude': serializer.toJson<double>(endAltitude),
      'verticalDropM': serializer.toJson<double>(verticalDropM),
      'maxSpeedKmh': serializer.toJson<double>(maxSpeedKmh),
      'distanceM': serializer.toJson<double>(distanceM),
      'durationS': serializer.toJson<double>(durationS),
      'isLift': serializer.toJson<bool>(isLift),
    };
  }

  Run copyWith(
          {String? id,
          String? sessionId,
          double? startAltitude,
          double? endAltitude,
          double? verticalDropM,
          double? maxSpeedKmh,
          double? distanceM,
          double? durationS,
          bool? isLift}) =>
      Run(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        startAltitude: startAltitude ?? this.startAltitude,
        endAltitude: endAltitude ?? this.endAltitude,
        verticalDropM: verticalDropM ?? this.verticalDropM,
        maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
        distanceM: distanceM ?? this.distanceM,
        durationS: durationS ?? this.durationS,
        isLift: isLift ?? this.isLift,
      );
  Run copyWithCompanion(RunsCompanion data) {
    return Run(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      startAltitude: data.startAltitude.present
          ? data.startAltitude.value
          : this.startAltitude,
      endAltitude:
          data.endAltitude.present ? data.endAltitude.value : this.endAltitude,
      verticalDropM: data.verticalDropM.present
          ? data.verticalDropM.value
          : this.verticalDropM,
      maxSpeedKmh:
          data.maxSpeedKmh.present ? data.maxSpeedKmh.value : this.maxSpeedKmh,
      distanceM: data.distanceM.present ? data.distanceM.value : this.distanceM,
      durationS: data.durationS.present ? data.durationS.value : this.durationS,
      isLift: data.isLift.present ? data.isLift.value : this.isLift,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Run(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('startAltitude: $startAltitude, ')
          ..write('endAltitude: $endAltitude, ')
          ..write('verticalDropM: $verticalDropM, ')
          ..write('maxSpeedKmh: $maxSpeedKmh, ')
          ..write('distanceM: $distanceM, ')
          ..write('durationS: $durationS, ')
          ..write('isLift: $isLift')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, startAltitude, endAltitude,
      verticalDropM, maxSpeedKmh, distanceM, durationS, isLift);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Run &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.startAltitude == this.startAltitude &&
          other.endAltitude == this.endAltitude &&
          other.verticalDropM == this.verticalDropM &&
          other.maxSpeedKmh == this.maxSpeedKmh &&
          other.distanceM == this.distanceM &&
          other.durationS == this.durationS &&
          other.isLift == this.isLift);
}

class RunsCompanion extends UpdateCompanion<Run> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<double> startAltitude;
  final Value<double> endAltitude;
  final Value<double> verticalDropM;
  final Value<double> maxSpeedKmh;
  final Value<double> distanceM;
  final Value<double> durationS;
  final Value<bool> isLift;
  final Value<int> rowid;
  const RunsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.startAltitude = const Value.absent(),
    this.endAltitude = const Value.absent(),
    this.verticalDropM = const Value.absent(),
    this.maxSpeedKmh = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.durationS = const Value.absent(),
    this.isLift = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RunsCompanion.insert({
    required String id,
    required String sessionId,
    required double startAltitude,
    required double endAltitude,
    required double verticalDropM,
    required double maxSpeedKmh,
    required double distanceM,
    required double durationS,
    this.isLift = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sessionId = Value(sessionId),
        startAltitude = Value(startAltitude),
        endAltitude = Value(endAltitude),
        verticalDropM = Value(verticalDropM),
        maxSpeedKmh = Value(maxSpeedKmh),
        distanceM = Value(distanceM),
        durationS = Value(durationS);
  static Insertable<Run> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<double>? startAltitude,
    Expression<double>? endAltitude,
    Expression<double>? verticalDropM,
    Expression<double>? maxSpeedKmh,
    Expression<double>? distanceM,
    Expression<double>? durationS,
    Expression<bool>? isLift,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (startAltitude != null) 'start_altitude': startAltitude,
      if (endAltitude != null) 'end_altitude': endAltitude,
      if (verticalDropM != null) 'vertical_drop_m': verticalDropM,
      if (maxSpeedKmh != null) 'max_speed_kmh': maxSpeedKmh,
      if (distanceM != null) 'distance_m': distanceM,
      if (durationS != null) 'duration_s': durationS,
      if (isLift != null) 'is_lift': isLift,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RunsCompanion copyWith(
      {Value<String>? id,
      Value<String>? sessionId,
      Value<double>? startAltitude,
      Value<double>? endAltitude,
      Value<double>? verticalDropM,
      Value<double>? maxSpeedKmh,
      Value<double>? distanceM,
      Value<double>? durationS,
      Value<bool>? isLift,
      Value<int>? rowid}) {
    return RunsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      startAltitude: startAltitude ?? this.startAltitude,
      endAltitude: endAltitude ?? this.endAltitude,
      verticalDropM: verticalDropM ?? this.verticalDropM,
      maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
      distanceM: distanceM ?? this.distanceM,
      durationS: durationS ?? this.durationS,
      isLift: isLift ?? this.isLift,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (startAltitude.present) {
      map['start_altitude'] = Variable<double>(startAltitude.value);
    }
    if (endAltitude.present) {
      map['end_altitude'] = Variable<double>(endAltitude.value);
    }
    if (verticalDropM.present) {
      map['vertical_drop_m'] = Variable<double>(verticalDropM.value);
    }
    if (maxSpeedKmh.present) {
      map['max_speed_kmh'] = Variable<double>(maxSpeedKmh.value);
    }
    if (distanceM.present) {
      map['distance_m'] = Variable<double>(distanceM.value);
    }
    if (durationS.present) {
      map['duration_s'] = Variable<double>(durationS.value);
    }
    if (isLift.present) {
      map['is_lift'] = Variable<bool>(isLift.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('startAltitude: $startAltitude, ')
          ..write('endAltitude: $endAltitude, ')
          ..write('verticalDropM: $verticalDropM, ')
          ..write('maxSpeedKmh: $maxSpeedKmh, ')
          ..write('distanceM: $distanceM, ')
          ..write('durationS: $durationS, ')
          ..write('isLift: $isLift, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GpsPointsTable extends GpsPoints
    with TableInfo<$GpsPointsTable, GpsPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GpsPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampUsMeta =
      const VerificationMeta('timestampUs');
  @override
  late final GeneratedColumn<int> timestampUs = GeneratedColumn<int>(
      'timestamp_us', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _altitudeMeta =
      const VerificationMeta('altitude');
  @override
  late final GeneratedColumn<double> altitude = GeneratedColumn<double>(
      'altitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
      'speed', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _bearingMeta =
      const VerificationMeta('bearing');
  @override
  late final GeneratedColumn<double> bearing = GeneratedColumn<double>(
      'bearing', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _accuracyMeta =
      const VerificationMeta('accuracy');
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
      'accuracy', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
      'run_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionId,
        timestampUs,
        latitude,
        longitude,
        altitude,
        speed,
        bearing,
        accuracy,
        runId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gps_points';
  @override
  VerificationContext validateIntegrity(Insertable<GpsPoint> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('timestamp_us')) {
      context.handle(
          _timestampUsMeta,
          timestampUs.isAcceptableOrUnknown(
              data['timestamp_us']!, _timestampUsMeta));
    } else if (isInserting) {
      context.missing(_timestampUsMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('altitude')) {
      context.handle(_altitudeMeta,
          altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta));
    } else if (isInserting) {
      context.missing(_altitudeMeta);
    }
    if (data.containsKey('speed')) {
      context.handle(
          _speedMeta, speed.isAcceptableOrUnknown(data['speed']!, _speedMeta));
    } else if (isInserting) {
      context.missing(_speedMeta);
    }
    if (data.containsKey('bearing')) {
      context.handle(_bearingMeta,
          bearing.isAcceptableOrUnknown(data['bearing']!, _bearingMeta));
    } else if (isInserting) {
      context.missing(_bearingMeta);
    }
    if (data.containsKey('accuracy')) {
      context.handle(_accuracyMeta,
          accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta));
    } else if (isInserting) {
      context.missing(_accuracyMeta);
    }
    if (data.containsKey('run_id')) {
      context.handle(
          _runIdMeta, runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GpsPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GpsPoint(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      timestampUs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp_us'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      altitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}altitude'])!,
      speed: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}speed'])!,
      bearing: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bearing'])!,
      accuracy: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}accuracy'])!,
      runId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}run_id']),
    );
  }

  @override
  $GpsPointsTable createAlias(String alias) {
    return $GpsPointsTable(attachedDatabase, alias);
  }
}

class GpsPoint extends DataClass implements Insertable<GpsPoint> {
  final int id;
  final String sessionId;
  final int timestampUs;
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;
  final double bearing;
  final double accuracy;
  final String? runId;
  const GpsPoint(
      {required this.id,
      required this.sessionId,
      required this.timestampUs,
      required this.latitude,
      required this.longitude,
      required this.altitude,
      required this.speed,
      required this.bearing,
      required this.accuracy,
      this.runId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['timestamp_us'] = Variable<int>(timestampUs);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['altitude'] = Variable<double>(altitude);
    map['speed'] = Variable<double>(speed);
    map['bearing'] = Variable<double>(bearing);
    map['accuracy'] = Variable<double>(accuracy);
    if (!nullToAbsent || runId != null) {
      map['run_id'] = Variable<String>(runId);
    }
    return map;
  }

  GpsPointsCompanion toCompanion(bool nullToAbsent) {
    return GpsPointsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      timestampUs: Value(timestampUs),
      latitude: Value(latitude),
      longitude: Value(longitude),
      altitude: Value(altitude),
      speed: Value(speed),
      bearing: Value(bearing),
      accuracy: Value(accuracy),
      runId:
          runId == null && nullToAbsent ? const Value.absent() : Value(runId),
    );
  }

  factory GpsPoint.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GpsPoint(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      timestampUs: serializer.fromJson<int>(json['timestampUs']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      altitude: serializer.fromJson<double>(json['altitude']),
      speed: serializer.fromJson<double>(json['speed']),
      bearing: serializer.fromJson<double>(json['bearing']),
      accuracy: serializer.fromJson<double>(json['accuracy']),
      runId: serializer.fromJson<String?>(json['runId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'timestampUs': serializer.toJson<int>(timestampUs),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'altitude': serializer.toJson<double>(altitude),
      'speed': serializer.toJson<double>(speed),
      'bearing': serializer.toJson<double>(bearing),
      'accuracy': serializer.toJson<double>(accuracy),
      'runId': serializer.toJson<String?>(runId),
    };
  }

  GpsPoint copyWith(
          {int? id,
          String? sessionId,
          int? timestampUs,
          double? latitude,
          double? longitude,
          double? altitude,
          double? speed,
          double? bearing,
          double? accuracy,
          Value<String?> runId = const Value.absent()}) =>
      GpsPoint(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        timestampUs: timestampUs ?? this.timestampUs,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        altitude: altitude ?? this.altitude,
        speed: speed ?? this.speed,
        bearing: bearing ?? this.bearing,
        accuracy: accuracy ?? this.accuracy,
        runId: runId.present ? runId.value : this.runId,
      );
  GpsPoint copyWithCompanion(GpsPointsCompanion data) {
    return GpsPoint(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      timestampUs:
          data.timestampUs.present ? data.timestampUs.value : this.timestampUs,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      speed: data.speed.present ? data.speed.value : this.speed,
      bearing: data.bearing.present ? data.bearing.value : this.bearing,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      runId: data.runId.present ? data.runId.value : this.runId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GpsPoint(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('timestampUs: $timestampUs, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('speed: $speed, ')
          ..write('bearing: $bearing, ')
          ..write('accuracy: $accuracy, ')
          ..write('runId: $runId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, timestampUs, latitude,
      longitude, altitude, speed, bearing, accuracy, runId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GpsPoint &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.timestampUs == this.timestampUs &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.altitude == this.altitude &&
          other.speed == this.speed &&
          other.bearing == this.bearing &&
          other.accuracy == this.accuracy &&
          other.runId == this.runId);
}

class GpsPointsCompanion extends UpdateCompanion<GpsPoint> {
  final Value<int> id;
  final Value<String> sessionId;
  final Value<int> timestampUs;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> altitude;
  final Value<double> speed;
  final Value<double> bearing;
  final Value<double> accuracy;
  final Value<String?> runId;
  const GpsPointsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.timestampUs = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.altitude = const Value.absent(),
    this.speed = const Value.absent(),
    this.bearing = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.runId = const Value.absent(),
  });
  GpsPointsCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    required int timestampUs,
    required double latitude,
    required double longitude,
    required double altitude,
    required double speed,
    required double bearing,
    required double accuracy,
    this.runId = const Value.absent(),
  })  : sessionId = Value(sessionId),
        timestampUs = Value(timestampUs),
        latitude = Value(latitude),
        longitude = Value(longitude),
        altitude = Value(altitude),
        speed = Value(speed),
        bearing = Value(bearing),
        accuracy = Value(accuracy);
  static Insertable<GpsPoint> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<int>? timestampUs,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? altitude,
    Expression<double>? speed,
    Expression<double>? bearing,
    Expression<double>? accuracy,
    Expression<String>? runId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (timestampUs != null) 'timestamp_us': timestampUs,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (speed != null) 'speed': speed,
      if (bearing != null) 'bearing': bearing,
      if (accuracy != null) 'accuracy': accuracy,
      if (runId != null) 'run_id': runId,
    });
  }

  GpsPointsCompanion copyWith(
      {Value<int>? id,
      Value<String>? sessionId,
      Value<int>? timestampUs,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<double>? altitude,
      Value<double>? speed,
      Value<double>? bearing,
      Value<double>? accuracy,
      Value<String?>? runId}) {
    return GpsPointsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      timestampUs: timestampUs ?? this.timestampUs,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      bearing: bearing ?? this.bearing,
      accuracy: accuracy ?? this.accuracy,
      runId: runId ?? this.runId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (timestampUs.present) {
      map['timestamp_us'] = Variable<int>(timestampUs.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<double>(altitude.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (bearing.present) {
      map['bearing'] = Variable<double>(bearing.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GpsPointsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('timestampUs: $timestampUs, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('speed: $speed, ')
          ..write('bearing: $bearing, ')
          ..write('accuracy: $accuracy, ')
          ..write('runId: $runId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $JumpsTable jumps = $JumpsTable(this);
  late final $RunsTable runs = $RunsTable(this);
  late final $GpsPointsTable gpsPoints = $GpsPointsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [sessions, jumps, runs, gpsPoints];
}

typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  required String id,
  required DateTime startedAt,
  Value<DateTime?> endedAt,
  Value<String?> resortName,
  Value<int> totalJumps,
  Value<double> maxAirtimeMs,
  Value<double> totalVerticalM,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<String> id,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<String?> resortName,
  Value<int> totalJumps,
  Value<double> maxAirtimeMs,
  Value<double> totalVerticalM,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});

class $$SessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder> {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SessionsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SessionsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<String?> resortName = const Value.absent(),
            Value<int> totalJumps = const Value.absent(),
            Value<double> maxAirtimeMs = const Value.absent(),
            Value<double> totalVerticalM = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SessionsCompanion(
            id: id,
            startedAt: startedAt,
            endedAt: endedAt,
            resortName: resortName,
            totalJumps: totalJumps,
            maxAirtimeMs: maxAirtimeMs,
            totalVerticalM: totalVerticalM,
            syncedAt: syncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime startedAt,
            Value<DateTime?> endedAt = const Value.absent(),
            Value<String?> resortName = const Value.absent(),
            Value<int> totalJumps = const Value.absent(),
            Value<double> maxAirtimeMs = const Value.absent(),
            Value<double> totalVerticalM = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SessionsCompanion.insert(
            id: id,
            startedAt: startedAt,
            endedAt: endedAt,
            resortName: resortName,
            totalJumps: totalJumps,
            maxAirtimeMs: maxAirtimeMs,
            totalVerticalM: totalVerticalM,
            syncedAt: syncedAt,
            rowid: rowid,
          ),
        ));
}

class $$SessionsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get startedAt => $state.composableBuilder(
      column: $state.table.startedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get endedAt => $state.composableBuilder(
      column: $state.table.endedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get resortName => $state.composableBuilder(
      column: $state.table.resortName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get totalJumps => $state.composableBuilder(
      column: $state.table.totalJumps,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get maxAirtimeMs => $state.composableBuilder(
      column: $state.table.maxAirtimeMs,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get totalVerticalM => $state.composableBuilder(
      column: $state.table.totalVerticalM,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get syncedAt => $state.composableBuilder(
      column: $state.table.syncedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$SessionsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get startedAt => $state.composableBuilder(
      column: $state.table.startedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get endedAt => $state.composableBuilder(
      column: $state.table.endedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get resortName => $state.composableBuilder(
      column: $state.table.resortName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get totalJumps => $state.composableBuilder(
      column: $state.table.totalJumps,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get maxAirtimeMs => $state.composableBuilder(
      column: $state.table.maxAirtimeMs,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get totalVerticalM => $state.composableBuilder(
      column: $state.table.totalVerticalM,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get syncedAt => $state.composableBuilder(
      column: $state.table.syncedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$JumpsTableCreateCompanionBuilder = JumpsCompanion Function({
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
  Value<double?> latTakeoff,
  Value<double?> lonTakeoff,
  Value<double?> latLanding,
  Value<double?> lonLanding,
  Value<double?> altitudeTakeoff,
  Value<String?> trickLabel,
  Value<int> rowid,
});
typedef $$JumpsTableUpdateCompanionBuilder = JumpsCompanion Function({
  Value<String> id,
  Value<String> sessionId,
  Value<String> runId,
  Value<int> takeoffTimestampUs,
  Value<int> landingTimestampUs,
  Value<int> airtimeMs,
  Value<double> distanceM,
  Value<double> heightM,
  Value<double> speedKmh,
  Value<double> landingGForce,
  Value<double?> latTakeoff,
  Value<double?> lonTakeoff,
  Value<double?> latLanding,
  Value<double?> lonLanding,
  Value<double?> altitudeTakeoff,
  Value<String?> trickLabel,
  Value<int> rowid,
});

class $$JumpsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $JumpsTable,
    Jump,
    $$JumpsTableFilterComposer,
    $$JumpsTableOrderingComposer,
    $$JumpsTableCreateCompanionBuilder,
    $$JumpsTableUpdateCompanionBuilder> {
  $$JumpsTableTableManager(_$AppDatabase db, $JumpsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$JumpsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$JumpsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<String> runId = const Value.absent(),
            Value<int> takeoffTimestampUs = const Value.absent(),
            Value<int> landingTimestampUs = const Value.absent(),
            Value<int> airtimeMs = const Value.absent(),
            Value<double> distanceM = const Value.absent(),
            Value<double> heightM = const Value.absent(),
            Value<double> speedKmh = const Value.absent(),
            Value<double> landingGForce = const Value.absent(),
            Value<double?> latTakeoff = const Value.absent(),
            Value<double?> lonTakeoff = const Value.absent(),
            Value<double?> latLanding = const Value.absent(),
            Value<double?> lonLanding = const Value.absent(),
            Value<double?> altitudeTakeoff = const Value.absent(),
            Value<String?> trickLabel = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              JumpsCompanion(
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
            latTakeoff: latTakeoff,
            lonTakeoff: lonTakeoff,
            latLanding: latLanding,
            lonLanding: lonLanding,
            altitudeTakeoff: altitudeTakeoff,
            trickLabel: trickLabel,
            rowid: rowid,
          ),
          createCompanionCallback: ({
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
            Value<double?> latTakeoff = const Value.absent(),
            Value<double?> lonTakeoff = const Value.absent(),
            Value<double?> latLanding = const Value.absent(),
            Value<double?> lonLanding = const Value.absent(),
            Value<double?> altitudeTakeoff = const Value.absent(),
            Value<String?> trickLabel = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              JumpsCompanion.insert(
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
            latTakeoff: latTakeoff,
            lonTakeoff: lonTakeoff,
            latLanding: latLanding,
            lonLanding: lonLanding,
            altitudeTakeoff: altitudeTakeoff,
            trickLabel: trickLabel,
            rowid: rowid,
          ),
        ));
}

class $$JumpsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $JumpsTable> {
  $$JumpsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get sessionId => $state.composableBuilder(
      column: $state.table.sessionId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get runId => $state.composableBuilder(
      column: $state.table.runId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get takeoffTimestampUs => $state.composableBuilder(
      column: $state.table.takeoffTimestampUs,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get landingTimestampUs => $state.composableBuilder(
      column: $state.table.landingTimestampUs,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get airtimeMs => $state.composableBuilder(
      column: $state.table.airtimeMs,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get distanceM => $state.composableBuilder(
      column: $state.table.distanceM,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get heightM => $state.composableBuilder(
      column: $state.table.heightM,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get speedKmh => $state.composableBuilder(
      column: $state.table.speedKmh,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get landingGForce => $state.composableBuilder(
      column: $state.table.landingGForce,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get latTakeoff => $state.composableBuilder(
      column: $state.table.latTakeoff,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get lonTakeoff => $state.composableBuilder(
      column: $state.table.lonTakeoff,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get latLanding => $state.composableBuilder(
      column: $state.table.latLanding,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get lonLanding => $state.composableBuilder(
      column: $state.table.lonLanding,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get altitudeTakeoff => $state.composableBuilder(
      column: $state.table.altitudeTakeoff,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get trickLabel => $state.composableBuilder(
      column: $state.table.trickLabel,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$JumpsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $JumpsTable> {
  $$JumpsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get sessionId => $state.composableBuilder(
      column: $state.table.sessionId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get runId => $state.composableBuilder(
      column: $state.table.runId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get takeoffTimestampUs => $state.composableBuilder(
      column: $state.table.takeoffTimestampUs,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get landingTimestampUs => $state.composableBuilder(
      column: $state.table.landingTimestampUs,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get airtimeMs => $state.composableBuilder(
      column: $state.table.airtimeMs,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get distanceM => $state.composableBuilder(
      column: $state.table.distanceM,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get heightM => $state.composableBuilder(
      column: $state.table.heightM,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get speedKmh => $state.composableBuilder(
      column: $state.table.speedKmh,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get landingGForce => $state.composableBuilder(
      column: $state.table.landingGForce,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get latTakeoff => $state.composableBuilder(
      column: $state.table.latTakeoff,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get lonTakeoff => $state.composableBuilder(
      column: $state.table.lonTakeoff,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get latLanding => $state.composableBuilder(
      column: $state.table.latLanding,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get lonLanding => $state.composableBuilder(
      column: $state.table.lonLanding,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get altitudeTakeoff => $state.composableBuilder(
      column: $state.table.altitudeTakeoff,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get trickLabel => $state.composableBuilder(
      column: $state.table.trickLabel,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$RunsTableCreateCompanionBuilder = RunsCompanion Function({
  required String id,
  required String sessionId,
  required double startAltitude,
  required double endAltitude,
  required double verticalDropM,
  required double maxSpeedKmh,
  required double distanceM,
  required double durationS,
  Value<bool> isLift,
  Value<int> rowid,
});
typedef $$RunsTableUpdateCompanionBuilder = RunsCompanion Function({
  Value<String> id,
  Value<String> sessionId,
  Value<double> startAltitude,
  Value<double> endAltitude,
  Value<double> verticalDropM,
  Value<double> maxSpeedKmh,
  Value<double> distanceM,
  Value<double> durationS,
  Value<bool> isLift,
  Value<int> rowid,
});

class $$RunsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RunsTable,
    Run,
    $$RunsTableFilterComposer,
    $$RunsTableOrderingComposer,
    $$RunsTableCreateCompanionBuilder,
    $$RunsTableUpdateCompanionBuilder> {
  $$RunsTableTableManager(_$AppDatabase db, $RunsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$RunsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$RunsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<double> startAltitude = const Value.absent(),
            Value<double> endAltitude = const Value.absent(),
            Value<double> verticalDropM = const Value.absent(),
            Value<double> maxSpeedKmh = const Value.absent(),
            Value<double> distanceM = const Value.absent(),
            Value<double> durationS = const Value.absent(),
            Value<bool> isLift = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RunsCompanion(
            id: id,
            sessionId: sessionId,
            startAltitude: startAltitude,
            endAltitude: endAltitude,
            verticalDropM: verticalDropM,
            maxSpeedKmh: maxSpeedKmh,
            distanceM: distanceM,
            durationS: durationS,
            isLift: isLift,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sessionId,
            required double startAltitude,
            required double endAltitude,
            required double verticalDropM,
            required double maxSpeedKmh,
            required double distanceM,
            required double durationS,
            Value<bool> isLift = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RunsCompanion.insert(
            id: id,
            sessionId: sessionId,
            startAltitude: startAltitude,
            endAltitude: endAltitude,
            verticalDropM: verticalDropM,
            maxSpeedKmh: maxSpeedKmh,
            distanceM: distanceM,
            durationS: durationS,
            isLift: isLift,
            rowid: rowid,
          ),
        ));
}

class $$RunsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $RunsTable> {
  $$RunsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get sessionId => $state.composableBuilder(
      column: $state.table.sessionId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get startAltitude => $state.composableBuilder(
      column: $state.table.startAltitude,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get endAltitude => $state.composableBuilder(
      column: $state.table.endAltitude,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get verticalDropM => $state.composableBuilder(
      column: $state.table.verticalDropM,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get maxSpeedKmh => $state.composableBuilder(
      column: $state.table.maxSpeedKmh,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get distanceM => $state.composableBuilder(
      column: $state.table.distanceM,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get durationS => $state.composableBuilder(
      column: $state.table.durationS,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isLift => $state.composableBuilder(
      column: $state.table.isLift,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$RunsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $RunsTable> {
  $$RunsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get sessionId => $state.composableBuilder(
      column: $state.table.sessionId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get startAltitude => $state.composableBuilder(
      column: $state.table.startAltitude,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get endAltitude => $state.composableBuilder(
      column: $state.table.endAltitude,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get verticalDropM => $state.composableBuilder(
      column: $state.table.verticalDropM,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get maxSpeedKmh => $state.composableBuilder(
      column: $state.table.maxSpeedKmh,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get distanceM => $state.composableBuilder(
      column: $state.table.distanceM,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get durationS => $state.composableBuilder(
      column: $state.table.durationS,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isLift => $state.composableBuilder(
      column: $state.table.isLift,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$GpsPointsTableCreateCompanionBuilder = GpsPointsCompanion Function({
  Value<int> id,
  required String sessionId,
  required int timestampUs,
  required double latitude,
  required double longitude,
  required double altitude,
  required double speed,
  required double bearing,
  required double accuracy,
  Value<String?> runId,
});
typedef $$GpsPointsTableUpdateCompanionBuilder = GpsPointsCompanion Function({
  Value<int> id,
  Value<String> sessionId,
  Value<int> timestampUs,
  Value<double> latitude,
  Value<double> longitude,
  Value<double> altitude,
  Value<double> speed,
  Value<double> bearing,
  Value<double> accuracy,
  Value<String?> runId,
});

class $$GpsPointsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GpsPointsTable,
    GpsPoint,
    $$GpsPointsTableFilterComposer,
    $$GpsPointsTableOrderingComposer,
    $$GpsPointsTableCreateCompanionBuilder,
    $$GpsPointsTableUpdateCompanionBuilder> {
  $$GpsPointsTableTableManager(_$AppDatabase db, $GpsPointsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$GpsPointsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$GpsPointsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<int> timestampUs = const Value.absent(),
            Value<double> latitude = const Value.absent(),
            Value<double> longitude = const Value.absent(),
            Value<double> altitude = const Value.absent(),
            Value<double> speed = const Value.absent(),
            Value<double> bearing = const Value.absent(),
            Value<double> accuracy = const Value.absent(),
            Value<String?> runId = const Value.absent(),
          }) =>
              GpsPointsCompanion(
            id: id,
            sessionId: sessionId,
            timestampUs: timestampUs,
            latitude: latitude,
            longitude: longitude,
            altitude: altitude,
            speed: speed,
            bearing: bearing,
            accuracy: accuracy,
            runId: runId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String sessionId,
            required int timestampUs,
            required double latitude,
            required double longitude,
            required double altitude,
            required double speed,
            required double bearing,
            required double accuracy,
            Value<String?> runId = const Value.absent(),
          }) =>
              GpsPointsCompanion.insert(
            id: id,
            sessionId: sessionId,
            timestampUs: timestampUs,
            latitude: latitude,
            longitude: longitude,
            altitude: altitude,
            speed: speed,
            bearing: bearing,
            accuracy: accuracy,
            runId: runId,
          ),
        ));
}

class $$GpsPointsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $GpsPointsTable> {
  $$GpsPointsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get sessionId => $state.composableBuilder(
      column: $state.table.sessionId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get timestampUs => $state.composableBuilder(
      column: $state.table.timestampUs,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get latitude => $state.composableBuilder(
      column: $state.table.latitude,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get longitude => $state.composableBuilder(
      column: $state.table.longitude,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get altitude => $state.composableBuilder(
      column: $state.table.altitude,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get speed => $state.composableBuilder(
      column: $state.table.speed,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get bearing => $state.composableBuilder(
      column: $state.table.bearing,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get accuracy => $state.composableBuilder(
      column: $state.table.accuracy,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get runId => $state.composableBuilder(
      column: $state.table.runId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$GpsPointsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $GpsPointsTable> {
  $$GpsPointsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get sessionId => $state.composableBuilder(
      column: $state.table.sessionId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get timestampUs => $state.composableBuilder(
      column: $state.table.timestampUs,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get latitude => $state.composableBuilder(
      column: $state.table.latitude,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get longitude => $state.composableBuilder(
      column: $state.table.longitude,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get altitude => $state.composableBuilder(
      column: $state.table.altitude,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get speed => $state.composableBuilder(
      column: $state.table.speed,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get bearing => $state.composableBuilder(
      column: $state.table.bearing,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get accuracy => $state.composableBuilder(
      column: $state.table.accuracy,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get runId => $state.composableBuilder(
      column: $state.table.runId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$JumpsTableTableManager get jumps =>
      $$JumpsTableTableManager(_db, _db.jumps);
  $$RunsTableTableManager get runs => $$RunsTableTableManager(_db, _db.runs);
  $$GpsPointsTableTableManager get gpsPoints =>
      $$GpsPointsTableTableManager(_db, _db.gpsPoints);
}
