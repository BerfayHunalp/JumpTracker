import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';

class ProfileStats {
  final int totalJumps;
  final int totalSessions;
  final double totalVerticalM;
  final double maxAirtimeMs;

  const ProfileStats({
    required this.totalJumps,
    required this.totalSessions,
    required this.totalVerticalM,
    required this.maxAirtimeMs,
  });
}

class BestJumps {
  final Jump? bestAirtime;
  final Jump? bestDistance;
  final Jump? bestHeight;
  final Jump? bestScore;

  const BestJumps({
    this.bestAirtime,
    this.bestDistance,
    this.bestHeight,
    this.bestScore,
  });

  bool get isEmpty =>
      bestAirtime == null &&
      bestDistance == null &&
      bestHeight == null &&
      bestScore == null;
}

final profileStatsProvider = FutureProvider<ProfileStats>((ref) async {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  return ProfileStats(
    totalJumps: await sessionRepo.getTotalJumpCount(),
    totalSessions: await sessionRepo.getTotalSessionCount(),
    totalVerticalM: await sessionRepo.getTotalVerticalAllTime(),
    maxAirtimeMs: await sessionRepo.getMaxAirtimeAllTime(),
  );
});

final bestJumpsProvider = FutureProvider<BestJumps>((ref) async {
  final jumpRepo = ref.watch(jumpRepositoryProvider);
  return BestJumps(
    bestAirtime: await jumpRepo.getBestJumpByAirtime(),
    bestDistance: await jumpRepo.getBestJumpByDistance(),
    bestHeight: await jumpRepo.getBestJumpByHeight(),
    bestScore: await jumpRepo.getBestJumpByScore(),
  );
});
