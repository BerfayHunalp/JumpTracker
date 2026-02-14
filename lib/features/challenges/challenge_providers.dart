import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/database.dart';
import '../tricks/trick_providers.dart';

// ── Score helper (same formula as core/models/jump.dart) ────────────────────

double jumpScore(Jump j) =>
    (j.airtimeMs / 100) * 40 + j.heightM * 30 + j.distanceM * 10;

// ── Models ──────────────────────────────────────────────────────────────────

class JumpZone {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusM;

  const JumpZone({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.radiusM = 30,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'radiusM': radiusM,
      };

  factory JumpZone.fromJson(Map<String, dynamic> json) => JumpZone(
        id: json['id'] as String,
        name: json['name'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        radiusM: (json['radiusM'] as num?)?.toDouble() ?? 30,
      );
}

class GhostChallenge {
  final Jump previousBest;
  final double distanceM;

  const GhostChallenge({
    required this.previousBest,
    required this.distanceM,
  });
}

class GhostResult {
  final Jump newJump;
  final Jump previousBest;
  final bool isNewRecord;

  const GhostResult({
    required this.newJump,
    required this.previousBest,
    required this.isNewRecord,
  });
}

class ZoneStats {
  final JumpZone zone;
  final int jumpCount;
  final Jump? bestJump;
  final Jump? todayBest;

  const ZoneStats({
    required this.zone,
    required this.jumpCount,
    this.bestJump,
    this.todayBest,
  });
}

// ── Haversine helper ────────────────────────────────────────────────────────

double haversineDistance(
    double lat1, double lon1, double lat2, double lon2) {
  const earthRadius = 6371000.0; // meters
  final dLat = _toRad(lat2 - lat1);
  final dLon = _toRad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

double _toRad(double deg) => deg * pi / 180;

// ── Ghost Provider ──────────────────────────────────────────────────────────

/// Checks if current GPS position is near a previous jump.
/// Returns the best jump at that spot if within 50m.
final ghostChallengeProvider =
    FutureProvider.family<GhostChallenge?, ({double lat, double lon})>(
  (ref, coords) async {
    final jumpRepo = ref.read(jumpRepositoryProvider);
    final allJumps = await jumpRepo.getAllJumpsChronological();

    // Filter jumps with GPS
    final gpsJumps = allJumps
        .where((j) => j.latTakeoff != null && j.lonTakeoff != null)
        .toList();

    if (gpsJumps.isEmpty) return null;

    // Find closest jump within 50m
    Jump? closestJump;
    double closestDist = double.infinity;

    for (final jump in gpsJumps) {
      final dist = haversineDistance(
        coords.lat, coords.lon,
        jump.latTakeoff!, jump.lonTakeoff!,
      );
      if (dist < 50 && dist < closestDist) {
        closestDist = dist;
        closestJump = jump;
      }
    }

    if (closestJump == null) return null;

    // Find the BEST jump at this spot (within 50m)
    final anchor = closestJump;
    Jump bestAtSpot = anchor;
    for (final jump in gpsJumps) {
      final dist = haversineDistance(
        anchor.latTakeoff!, anchor.lonTakeoff!,
        jump.latTakeoff!, jump.lonTakeoff!,
      );
      if (dist < 50 && jumpScore(jump) > jumpScore(bestAtSpot)) {
        bestAtSpot = jump;
      }
    }

    return GhostChallenge(previousBest: bestAtSpot, distanceM: closestDist);
  },
);

// ── Zone Detection & Storage ────────────────────────────────────────────────

const _zonesKey = 'jump_zones';

final jumpZonesProvider = StateNotifierProvider<JumpZonesNotifier, List<JumpZone>>(
  (ref) {
    final prefs = ref.watch(sharedPrefsProvider);
    return JumpZonesNotifier(prefs);
  },
);

class JumpZonesNotifier extends StateNotifier<List<JumpZone>> {
  final SharedPreferences _prefs;

  JumpZonesNotifier(this._prefs) : super([]) {
    _load();
  }

  void _load() {
    final raw = _prefs.getString(_zonesKey);
    if (raw != null) {
      final list = (jsonDecode(raw) as List)
          .map((e) => JumpZone.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    }
  }

  Future<void> _save() async {
    await _prefs.setString(
      _zonesKey,
      jsonEncode(state.map((z) => z.toJson()).toList()),
    );
  }

  /// Auto-detect zones from all jumps with GPS.
  /// Groups jumps within 30m and creates zones where >= 3 jumps cluster.
  Future<void> detectZones(List<Jump> allJumps) async {
    final gpsJumps = allJumps
        .where((j) => j.latTakeoff != null && j.lonTakeoff != null)
        .toList();

    if (gpsJumps.isEmpty) return;

    final visited = <int>{};
    final newZones = <JumpZone>[];
    var zoneIndex = 1;

    for (var i = 0; i < gpsJumps.length; i++) {
      if (visited.contains(i)) continue;

      final cluster = <Jump>[gpsJumps[i]];
      visited.add(i);

      for (var j = i + 1; j < gpsJumps.length; j++) {
        if (visited.contains(j)) continue;
        final dist = haversineDistance(
          gpsJumps[i].latTakeoff!, gpsJumps[i].lonTakeoff!,
          gpsJumps[j].latTakeoff!, gpsJumps[j].lonTakeoff!,
        );
        if (dist < 30) {
          cluster.add(gpsJumps[j]);
          visited.add(j);
        }
      }

      if (cluster.length >= 3) {
        // Compute centroid
        final avgLat = cluster.map((j) => j.latTakeoff!).reduce((a, b) => a + b) /
            cluster.length;
        final avgLon = cluster.map((j) => j.lonTakeoff!).reduce((a, b) => a + b) /
            cluster.length;

        // Check if this zone already exists
        final existing = state.any(
          (z) => haversineDistance(z.latitude, z.longitude, avgLat, avgLon) < 30,
        );

        if (!existing) {
          newZones.add(JumpZone(
            id: 'zone_$zoneIndex',
            name: 'Jump Spot #$zoneIndex',
            latitude: avgLat,
            longitude: avgLon,
          ));
          zoneIndex++;
        }
      }
    }

    if (newZones.isNotEmpty) {
      // Re-number based on existing count
      final offset = state.length;
      final numbered = newZones.asMap().entries.map((e) {
        return JumpZone(
          id: 'zone_${offset + e.key + 1}',
          name: 'Jump Spot #${offset + e.key + 1}',
          latitude: e.value.latitude,
          longitude: e.value.longitude,
        );
      }).toList();

      state = [...state, ...numbered];
      await _save();
    }
  }

  /// Rename a zone.
  Future<void> renameZone(String id, String newName) async {
    state = state.map((z) {
      if (z.id == id) {
        return JumpZone(
          id: z.id,
          name: newName,
          latitude: z.latitude,
          longitude: z.longitude,
          radiusM: z.radiusM,
        );
      }
      return z;
    }).toList();
    await _save();
  }
}

/// Computes stats for a single zone given all jumps.
ZoneStats computeZoneStats(JumpZone zone, List<Jump> allJumps) {
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);

  final nearbyJumps = allJumps.where((j) {
    if (j.latTakeoff == null || j.lonTakeoff == null) return false;
    return haversineDistance(
            zone.latitude, zone.longitude, j.latTakeoff!, j.lonTakeoff!) <
        zone.radiusM;
  }).toList();

  if (nearbyJumps.isEmpty) {
    return ZoneStats(zone: zone, jumpCount: 0);
  }

  nearbyJumps.sort((a, b) => jumpScore(b).compareTo(jumpScore(a)));
  final best = nearbyJumps.first;

  // Today's best
  final todayJumps = nearbyJumps.where((j) {
    final jumpTime = DateTime.fromMicrosecondsSinceEpoch(j.takeoffTimestampUs);
    return jumpTime.isAfter(todayStart);
  }).toList();

  return ZoneStats(
    zone: zone,
    jumpCount: nearbyJumps.length,
    bestJump: best,
    todayBest: todayJumps.isNotEmpty ? todayJumps.first : null,
  );
}
