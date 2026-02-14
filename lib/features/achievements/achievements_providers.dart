import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../equipment/equipment_providers.dart';
import '../learn/learn_screen.dart';
import '../tricks/trick_providers.dart';

// ---------------------------------------------------------------------------
// Achievement definition
// ---------------------------------------------------------------------------

enum AchievementCategory { jumps, sessions, performance, tricks, gear, learn }

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon; // emoji
  final AchievementCategory category;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
  });
}

// ---------------------------------------------------------------------------
// All achievements (37 total)
// ---------------------------------------------------------------------------

const achievements = [
  // ── Jumps (8) ──────────────────────────────────────────
  Achievement(
    id: 'first_jump',
    title: 'First Flight',
    description: 'Land your first jump',
    icon: '\u{1F423}',
    category: AchievementCategory.jumps,
  ),
  Achievement(
    id: 'jumps_10',
    title: 'Getting Air',
    description: 'Land 10 jumps',
    icon: '\u{1F4A8}',
    category: AchievementCategory.jumps,
  ),
  Achievement(
    id: 'jumps_50',
    title: 'Frequent Flyer',
    description: 'Land 50 jumps',
    icon: '\u{2708}',
    category: AchievementCategory.jumps,
  ),
  Achievement(
    id: 'jumps_100',
    title: 'Centurion',
    description: 'Land 100 jumps',
    icon: '\u{1F4AF}',
    category: AchievementCategory.jumps,
  ),
  Achievement(
    id: 'jumps_250',
    title: 'Jump Addict',
    description: 'Land 250 jumps',
    icon: '\u{1F525}',
    category: AchievementCategory.jumps,
  ),
  Achievement(
    id: 'jumps_500',
    title: 'Half a Thousand',
    description: 'Land 500 jumps',
    icon: '\u{1F3C6}',
    category: AchievementCategory.jumps,
  ),
  Achievement(
    id: 'jumps_1000',
    title: 'Jump Legend',
    description: 'Land 1000 jumps',
    icon: '\u{1F451}',
    category: AchievementCategory.jumps,
  ),
  Achievement(
    id: 'jumps_10_session',
    title: 'Send It',
    description: 'Land 10+ jumps in a single session',
    icon: '\u{26A1}',
    category: AchievementCategory.jumps,
  ),

  // ── Sessions (5) ───────────────────────────────────────
  Achievement(
    id: 'first_session',
    title: 'Day One',
    description: 'Complete your first session',
    icon: '\u{1F3BF}',
    category: AchievementCategory.sessions,
  ),
  Achievement(
    id: 'sessions_5',
    title: 'Regular',
    description: 'Complete 5 sessions',
    icon: '\u{1F4C5}',
    category: AchievementCategory.sessions,
  ),
  Achievement(
    id: 'sessions_10',
    title: 'Dedicated',
    description: 'Complete 10 sessions',
    icon: '\u{1F3D4}',
    category: AchievementCategory.sessions,
  ),
  Achievement(
    id: 'sessions_25',
    title: 'Mountain Regular',
    description: 'Complete 25 sessions',
    icon: '\u{26F0}',
    category: AchievementCategory.sessions,
  ),
  Achievement(
    id: 'sessions_50',
    title: 'Season Warrior',
    description: 'Complete 50 sessions',
    icon: '\u{2744}',
    category: AchievementCategory.sessions,
  ),

  // ── Performance (10) ───────────────────────────────────
  Achievement(
    id: 'airtime_500',
    title: 'Hang Time',
    description: 'Reach 500ms airtime on a single jump',
    icon: '\u{23F1}',
    category: AchievementCategory.performance,
  ),
  Achievement(
    id: 'airtime_1000',
    title: 'One Second Club',
    description: 'Reach 1000ms airtime on a single jump',
    icon: '\u{1F680}',
    category: AchievementCategory.performance,
  ),
  Achievement(
    id: 'airtime_2000',
    title: 'Orbit',
    description: 'Reach 2000ms airtime on a single jump',
    icon: '\u{1F6F8}',
    category: AchievementCategory.performance,
  ),
  Achievement(
    id: 'height_2m',
    title: 'Above the Crowd',
    description: 'Reach 2m height on a single jump',
    icon: '\u{2B06}',
    category: AchievementCategory.performance,
  ),
  Achievement(
    id: 'height_5m',
    title: 'Sky High',
    description: 'Reach 5m height on a single jump',
    icon: '\u{1F30C}',
    category: AchievementCategory.performance,
  ),
  Achievement(
    id: 'distance_5m',
    title: 'Long Jump',
    description: 'Reach 5m distance on a single jump',
    icon: '\u{1F3C3}',
    category: AchievementCategory.performance,
  ),
  Achievement(
    id: 'distance_15m',
    title: 'Gap Sender',
    description: 'Reach 15m distance on a single jump',
    icon: '\u{1F3AF}',
    category: AchievementCategory.performance,
  ),
  Achievement(
    id: 'speed_50',
    title: 'Speed Demon',
    description: 'Hit 50 km/h on a jump',
    icon: '\u{1F3CE}',
    category: AchievementCategory.performance,
  ),
  Achievement(
    id: 'speed_80',
    title: 'Terminal Velocity',
    description: 'Hit 80 km/h on a jump',
    icon: '\u{1F4A5}',
    category: AchievementCategory.performance,
  ),
  Achievement(
    id: 'score_500',
    title: 'High Scorer',
    description: 'Score 500+ points on a single jump',
    icon: '\u{2B50}',
    category: AchievementCategory.performance,
  ),

  // ── Tricks (7) ─────────────────────────────────────────
  Achievement(
    id: 'first_trick',
    title: 'Trickster',
    description: 'Land your first trick',
    icon: '\u{1F938}',
    category: AchievementCategory.tricks,
  ),
  Achievement(
    id: 'tricks_5',
    title: 'Styler',
    description: 'Land 5 different tricks',
    icon: '\u{1F3A8}',
    category: AchievementCategory.tricks,
  ),
  Achievement(
    id: 'tricks_10',
    title: 'Trick Machine',
    description: 'Land 10 different tricks',
    icon: '\u{1F916}',
    category: AchievementCategory.tricks,
  ),
  Achievement(
    id: 'tricks_25',
    title: 'Freestyle King',
    description: 'Land 25 different tricks',
    icon: '\u{1F48E}',
    category: AchievementCategory.tricks,
  ),
  Achievement(
    id: 'xp_500',
    title: 'XP Hunter',
    description: 'Earn 500 trick XP',
    icon: '\u{1F396}',
    category: AchievementCategory.tricks,
  ),
  Achievement(
    id: 'xp_1500',
    title: 'XP Master',
    description: 'Earn 1500 trick XP',
    icon: '\u{1F31F}',
    category: AchievementCategory.tricks,
  ),
  Achievement(
    id: 'level_apex',
    title: 'Apex Predator',
    description: 'Reach Apex Predator trick level (2700 XP)',
    icon: '\u{1F985}',
    category: AchievementCategory.tricks,
  ),

  // ── Gear (4) ───────────────────────────────────────────
  Achievement(
    id: 'gear_5',
    title: 'Gearing Up',
    description: 'Own 5 pieces of equipment',
    icon: '\u{1F392}',
    category: AchievementCategory.gear,
  ),
  Achievement(
    id: 'gear_10',
    title: 'Well Equipped',
    description: 'Own 10 pieces of equipment',
    icon: '\u{1F6E1}',
    category: AchievementCategory.gear,
  ),
  Achievement(
    id: 'gear_all',
    title: 'Fully Loaded',
    description: 'Own all 16 pieces of equipment',
    icon: '\u{1F48E}',
    category: AchievementCategory.gear,
  ),
  Achievement(
    id: 'security_all',
    title: 'Safety First',
    description: 'Own all security equipment (DVA, airbag, back protector)',
    icon: '\u{1F6E1}',
    category: AchievementCategory.gear,
  ),

  // ── Learn (3) ──────────────────────────────────────────
  Achievement(
    id: 'learn_first',
    title: 'Student',
    description: 'Complete your first lesson',
    icon: '\u{1F4D6}',
    category: AchievementCategory.learn,
  ),
  Achievement(
    id: 'learn_half',
    title: 'Eager Learner',
    description: 'Complete half of all lessons',
    icon: '\u{1F393}',
    category: AchievementCategory.learn,
  ),
  Achievement(
    id: 'learn_all',
    title: 'Scholar',
    description: 'Complete all lessons',
    icon: '\u{1F9E0}',
    category: AchievementCategory.learn,
  ),
];

// ---------------------------------------------------------------------------
// Achievement state — computed from all data sources
// ---------------------------------------------------------------------------

class AchievementState {
  final int totalJumps;
  final int totalSessions;
  final double maxAirtimeMs;
  final double maxHeight;
  final double maxDistance;
  final double maxSpeed;
  final double maxScore;
  final int maxJumpsInSession;
  final int trickedJumpCount;
  final int trickXp;
  final int gearOwned;
  final int securityOwned;
  final int lessonsCompleted;
  final int totalLessons;

  const AchievementState({
    required this.totalJumps,
    required this.totalSessions,
    required this.maxAirtimeMs,
    required this.maxHeight,
    required this.maxDistance,
    required this.maxSpeed,
    required this.maxScore,
    required this.maxJumpsInSession,
    required this.trickedJumpCount,
    required this.trickXp,
    required this.gearOwned,
    required this.securityOwned,
    required this.lessonsCompleted,
    required this.totalLessons,
  });

  bool isUnlocked(String id) {
    switch (id) {
      // Jumps
      case 'first_jump':
        return totalJumps >= 1;
      case 'jumps_10':
        return totalJumps >= 10;
      case 'jumps_50':
        return totalJumps >= 50;
      case 'jumps_100':
        return totalJumps >= 100;
      case 'jumps_250':
        return totalJumps >= 250;
      case 'jumps_500':
        return totalJumps >= 500;
      case 'jumps_1000':
        return totalJumps >= 1000;
      case 'jumps_10_session':
        return maxJumpsInSession >= 10;

      // Sessions
      case 'first_session':
        return totalSessions >= 1;
      case 'sessions_5':
        return totalSessions >= 5;
      case 'sessions_10':
        return totalSessions >= 10;
      case 'sessions_25':
        return totalSessions >= 25;
      case 'sessions_50':
        return totalSessions >= 50;

      // Performance
      case 'airtime_500':
        return maxAirtimeMs >= 500;
      case 'airtime_1000':
        return maxAirtimeMs >= 1000;
      case 'airtime_2000':
        return maxAirtimeMs >= 2000;
      case 'height_2m':
        return maxHeight >= 2.0;
      case 'height_5m':
        return maxHeight >= 5.0;
      case 'distance_5m':
        return maxDistance >= 5.0;
      case 'distance_15m':
        return maxDistance >= 15.0;
      case 'speed_50':
        return maxSpeed >= 50.0;
      case 'speed_80':
        return maxSpeed >= 80.0;
      case 'score_500':
        return maxScore >= 500.0;

      // Tricks
      case 'first_trick':
        return trickedJumpCount >= 1;
      case 'tricks_5':
        return trickedJumpCount >= 5;
      case 'tricks_10':
        return trickedJumpCount >= 10;
      case 'tricks_25':
        return trickedJumpCount >= 25;
      case 'xp_500':
        return trickXp >= 500;
      case 'xp_1500':
        return trickXp >= 1500;
      case 'level_apex':
        return trickXp >= 2700;

      // Gear
      case 'gear_5':
        return gearOwned >= 5;
      case 'gear_10':
        return gearOwned >= 10;
      case 'gear_all':
        return gearOwned >= 16;
      case 'security_all':
        return securityOwned >= 3;

      // Learn
      case 'learn_first':
        return lessonsCompleted >= 1;
      case 'learn_half':
        return lessonsCompleted >= (totalLessons / 2).ceil();
      case 'learn_all':
        return lessonsCompleted >= totalLessons;

      default:
        return false;
    }
  }

  int get unlockedCount =>
      achievements.where((a) => isUnlocked(a.id)).length;
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final achievementStateProvider = FutureProvider<AchievementState>((ref) async {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  final jumpRepo = ref.watch(jumpRepositoryProvider);
  final trickXp = ref.watch(trickXpProvider);
  final equipNotifier = ref.read(equipmentProvider.notifier);
  final learnProgress = ref.watch(learnProgressProvider);

  // Get max jumps in a single session
  final sessions = await sessionRepo.getAllSessions();
  int maxJumpsInSession = 0;
  for (final s in sessions) {
    if (s.totalJumps > maxJumpsInSession) {
      maxJumpsInSession = s.totalJumps;
    }
  }

  // Count security gear owned (DVA, airbag backpack, back protector)
  const securityIds = ['dva', 'sac_airbag', 'dorsale'];
  int securityOwned = 0;
  for (final id in securityIds) {
    if (equipNotifier.isOwned(id)) securityOwned++;
  }

  return AchievementState(
    totalJumps: await sessionRepo.getTotalJumpCount(),
    totalSessions: await sessionRepo.getTotalSessionCount(),
    maxAirtimeMs: await sessionRepo.getMaxAirtimeAllTime(),
    maxHeight: await jumpRepo.getMaxHeightAllTime(),
    maxDistance: await jumpRepo.getMaxDistanceAllTime(),
    maxSpeed: await jumpRepo.getMaxSpeedAllTime(),
    maxScore: await jumpRepo.getMaxScoreAllTime(),
    maxJumpsInSession: maxJumpsInSession,
    trickedJumpCount: await jumpRepo.getTrickedJumpCount(),
    trickXp: trickXp,
    gearOwned: equipNotifier.ownedCount,
    securityOwned: securityOwned,
    lessonsCompleted: learnProgress.length,
    totalLessons: LearnCatalog.all.length,
  );
});

final unlockedCountProvider = FutureProvider<int>((ref) async {
  final state = await ref.watch(achievementStateProvider.future);
  return state.unlockedCount;
});
