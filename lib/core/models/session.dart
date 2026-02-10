/// A ski session spanning an entire day or outing.
class Session {
  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? resortName;
  final int totalJumps;
  final double maxAirtimeMs;
  final double totalVerticalM;

  const Session({
    required this.id,
    required this.startedAt,
    this.endedAt,
    this.resortName,
    this.totalJumps = 0,
    this.maxAirtimeMs = 0,
    this.totalVerticalM = 0,
  });

  Duration? get duration => endedAt?.difference(startedAt);

  bool get isActive => endedAt == null;
}
