/// A single run down the mountain (lift-to-lift or top-to-bottom).
class Run {
  final String id;
  final String sessionId;
  final double startAltitude;
  final double endAltitude;
  final double verticalDropM;
  final double maxSpeedKmh;
  final double distanceM;
  final double durationS;
  final bool isLift;

  const Run({
    required this.id,
    required this.sessionId,
    required this.startAltitude,
    required this.endAltitude,
    required this.verticalDropM,
    required this.maxSpeedKmh,
    required this.distanceM,
    required this.durationS,
    this.isLift = false,
  });
}
