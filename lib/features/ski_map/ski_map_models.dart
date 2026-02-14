/// Lightweight lat/lon tuple for slope/lift geometry.
class LatLngPoint {
  final double lat;
  final double lon;
  const LatLngPoint(this.lat, this.lon);
}

/// A ski slope polyline from OSM data.
class SkiSlope {
  final int osmId;
  final String name;
  final String difficulty; // novice, easy, intermediate, advanced, expert
  final List<LatLngPoint> points;

  const SkiSlope({
    required this.osmId,
    required this.name,
    required this.difficulty,
    required this.points,
  });

  Map<String, dynamic> toJson() => {
        'osmId': osmId,
        'name': name,
        'difficulty': difficulty,
        'points': points.map((p) => [p.lat, p.lon]).toList(),
      };

  factory SkiSlope.fromJson(Map<String, dynamic> json) => SkiSlope(
        osmId: json['osmId'] as int,
        name: json['name'] as String? ?? '',
        difficulty: json['difficulty'] as String? ?? 'easy',
        points: (json['points'] as List).map((p) {
          final coords = p as List;
          return LatLngPoint(
              (coords[0] as num).toDouble(), (coords[1] as num).toDouble());
        }).toList(),
      );
}

/// A ski lift polyline from OSM data.
class SkiLift {
  final int osmId;
  final String name;
  final String liftType; // gondola, chair_lift, platter, magic_carpet
  final List<LatLngPoint> points;

  const SkiLift({
    required this.osmId,
    required this.name,
    required this.liftType,
    required this.points,
  });

  Map<String, dynamic> toJson() => {
        'osmId': osmId,
        'name': name,
        'liftType': liftType,
        'points': points.map((p) => [p.lat, p.lon]).toList(),
      };

  factory SkiLift.fromJson(Map<String, dynamic> json) => SkiLift(
        osmId: json['osmId'] as int,
        name: json['name'] as String? ?? '',
        liftType: json['liftType'] as String? ?? 'chair_lift',
        points: (json['points'] as List).map((p) {
          final coords = p as List;
          return LatLngPoint(
              (coords[0] as num).toDouble(), (coords[1] as num).toDouble());
        }).toList(),
      );
}

/// Aggregated resort map data with cache timestamp.
class ResortMapData {
  final List<SkiSlope> slopes;
  final List<SkiLift> lifts;
  final DateTime fetchedAt;

  const ResortMapData({
    required this.slopes,
    required this.lifts,
    required this.fetchedAt,
  });

  Map<String, dynamic> toJson() => {
        'slopes': slopes.map((s) => s.toJson()).toList(),
        'lifts': lifts.map((l) => l.toJson()).toList(),
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  factory ResortMapData.fromJson(Map<String, dynamic> json) => ResortMapData(
        slopes: (json['slopes'] as List)
            .map((e) => SkiSlope.fromJson(e as Map<String, dynamic>))
            .toList(),
        lifts: (json['lifts'] as List)
            .map((e) => SkiLift.fromJson(e as Map<String, dynamic>))
            .toList(),
        fetchedAt: DateTime.parse(json['fetchedAt'] as String),
      );
}
