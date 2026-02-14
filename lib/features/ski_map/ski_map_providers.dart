import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../tricks/trick_providers.dart';
import 'ski_map_models.dart';

const _cacheKey = 'ski_map_isola2000';
const _cacheDurationHours = 168; // 7 days

/// Overpass QL query — `out geom` returns coordinates directly on ways (faster).
const _overpassQuery =
    '[out:json][timeout:60];'
    '(way["piste:type"="downhill"](44.15,7.10,44.22,7.20);'
    'way["aerialway"](44.15,7.10,44.22,7.20););'
    'out geom;';

/// Main provider: returns cached data or fetches fresh from Overpass API.
final resortMapDataProvider = FutureProvider<ResortMapData>((ref) async {
  final prefs = ref.watch(sharedPrefsProvider);

  // Try cache first
  final cached = prefs.getString(_cacheKey);
  if (cached != null) {
    try {
      final data = ResortMapData.fromJson(
          jsonDecode(cached) as Map<String, dynamic>);
      final age = DateTime.now().difference(data.fetchedAt).inHours;
      if (age < _cacheDurationHours) return data;
    } catch (_) {
      // Cache corrupted, will re-fetch
    }
  }

  // Fetch from Overpass API
  final url = Uri.parse('https://overpass-api.de/api/interpreter');
  final response = await http.post(
    url,
    body: {'data': _overpassQuery},
  ).timeout(const Duration(seconds: 60));

  if (response.statusCode != 200) {
    // Return stale cache if available
    if (cached != null) {
      try {
        return ResortMapData.fromJson(
            jsonDecode(cached) as Map<String, dynamic>);
      } catch (_) {}
    }
    throw Exception('Overpass API error: ${response.statusCode}');
  }

  final json = jsonDecode(response.body) as Map<String, dynamic>;
  final data = _parseOverpassResponse(json);

  // Save to cache
  await prefs.setString(_cacheKey, jsonEncode(data.toJson()));

  return data;
});

/// Parses Overpass JSON `out geom` response — geometry is inline on each way.
ResortMapData _parseOverpassResponse(Map<String, dynamic> json) {
  final elements = json['elements'] as List;

  final slopes = <SkiSlope>[];
  final lifts = <SkiLift>[];

  for (final el in elements) {
    final element = el as Map<String, dynamic>;
    if (element['type'] != 'way') continue;

    final tags = (element['tags'] as Map<String, dynamic>?) ?? {};
    final geometry = element['geometry'] as List?;
    if (geometry == null || geometry.length < 2) continue;

    final points = geometry
        .map((g) => LatLngPoint(
              (g['lat'] as num).toDouble(),
              (g['lon'] as num).toDouble(),
            ))
        .toList();

    if (tags.containsKey('piste:type')) {
      slopes.add(SkiSlope(
        osmId: element['id'] as int,
        name: (tags['name'] as String?) ?? '',
        difficulty: (tags['piste:difficulty'] as String?) ?? 'easy',
        points: points,
      ));
    } else if (tags.containsKey('aerialway')) {
      lifts.add(SkiLift(
        osmId: element['id'] as int,
        name: (tags['name'] as String?) ?? '',
        liftType: tags['aerialway'] as String? ?? 'chair_lift',
        points: points,
      ));
    }
  }

  return ResortMapData(
    slopes: slopes,
    lifts: lifts,
    fetchedAt: DateTime.now(),
  );
}
