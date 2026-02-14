import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../tricks/trick_providers.dart';
import 'ski_map_models.dart';

const _cacheKey = 'ski_map_isola2000';
const _cacheDurationHours = 168; // 7 days

/// Isola 2000 bounding box.
const _south = 44.15;
const _west = 7.10;
const _north = 44.22;
const _east = 7.20;

/// Overpass QL query for pistes and lifts.
const _overpassQuery = '''
[out:json][timeout:25];
(
  way["piste:type"="downhill"]($_south,$_west,$_north,$_east);
  way["aerialway"]($_south,$_west,$_north,$_east);
);
out body;
>;
out skel qt;
''';

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
  final response = await http.post(url, body: {'data': _overpassQuery});

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

/// Parses Overpass JSON response into ResortMapData.
ResortMapData _parseOverpassResponse(Map<String, dynamic> json) {
  final elements = json['elements'] as List;

  // First pass: build node lookup
  final nodes = <int, LatLngPoint>{};
  for (final el in elements) {
    if ((el as Map<String, dynamic>)['type'] == 'node') {
      nodes[el['id'] as int] = LatLngPoint(
        (el['lat'] as num).toDouble(),
        (el['lon'] as num).toDouble(),
      );
    }
  }

  final slopes = <SkiSlope>[];
  final lifts = <SkiLift>[];

  // Second pass: resolve ways
  for (final el in elements) {
    if ((el as Map<String, dynamic>)['type'] != 'way') continue;
    final tags = (el['tags'] as Map<String, dynamic>?) ?? {};
    final nodeIds = (el['nodes'] as List).cast<int>();
    final points = nodeIds
        .where((id) => nodes.containsKey(id))
        .map((id) => nodes[id]!)
        .toList();

    if (points.length < 2) continue;

    if (tags.containsKey('piste:type')) {
      slopes.add(SkiSlope(
        osmId: el['id'] as int,
        name: (tags['name'] as String?) ?? '',
        difficulty: (tags['piste:difficulty'] as String?) ?? 'easy',
        points: points,
      ));
    } else if (tags.containsKey('aerialway')) {
      lifts.add(SkiLift(
        osmId: el['id'] as int,
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
