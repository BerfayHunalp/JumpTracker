/// A detected jump with all computed metrics.
class Jump {
  final String id;
  final String runId;

  /// When the skier left the ground
  final int takeoffTimestampUs;

  /// When the skier landed
  final int landingTimestampUs;

  /// Airtime in milliseconds
  final double airtimeMs;

  /// Horizontal distance covered during the jump (meters)
  final double distanceM;

  /// Vertical height of the jump (meters), from barometer
  final double heightM;

  /// Speed at takeoff (km/h)
  final double speedKmh;

  /// Peak G-force experienced on landing
  final double landingGForce;

  /// GPS coordinates at takeoff
  final double? latTakeoff;
  final double? lonTakeoff;

  /// GPS coordinates at landing
  final double? latLanding;
  final double? lonLanding;

  /// Altitude at takeoff (from barometer or GPS)
  final double? altitudeTakeoff;

  const Jump({
    required this.id,
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
  });

  /// Simple score: weighted combination of airtime, height, and distance.
  /// This gives users a single number to compare jumps.
  double get score {
    // Airtime (ms) contributes most, height and distance add bonus
    return (airtimeMs / 100) * 40 + heightM * 30 + distanceM * 10;
  }

  @override
  String toString() =>
      'Jump(airtime=${airtimeMs.toStringAsFixed(0)}ms, '
      'dist=${distanceM.toStringAsFixed(1)}m, '
      'height=${heightM.toStringAsFixed(1)}m, '
      'speed=${speedKmh.toStringAsFixed(1)}km/h, '
      'gForce=${landingGForce.toStringAsFixed(1)}G)';
}
