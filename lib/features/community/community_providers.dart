import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_providers.dart';

final leaderboardPeriodProvider = StateProvider<String>((ref) => 'week');

class LeaderboardEntry {
  final int rank;
  final String userId;
  final String nickname;
  final int avatarIndex;
  final double totalScore;
  final int totalJumps;
  final double bestJumpScore;
  final int sessionCount;
  final bool isMe;
  final bool isFriend;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.nickname,
    required this.avatarIndex,
    required this.totalScore,
    required this.totalJumps,
    required this.bestJumpScore,
    required this.sessionCount,
    required this.isMe,
    required this.isFriend,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int? ?? 0,
      userId: json['userId'] as String? ?? '',
      nickname: json['nickname'] as String? ?? 'Skier',
      avatarIndex: json['avatarIndex'] as int? ?? 0,
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0,
      totalJumps: json['totalJumps'] as int? ?? 0,
      bestJumpScore: (json['bestJumpScore'] as num?)?.toDouble() ?? 0,
      sessionCount: json['sessionCount'] as int? ?? 0,
      isMe: json['isMe'] as bool? ?? false,
      isFriend: json['isFriend'] as bool? ?? false,
    );
  }
}

class FriendEntry {
  final String userId;
  final String nickname;
  final int avatarIndex;
  final String status;

  FriendEntry({
    required this.userId,
    required this.nickname,
    required this.avatarIndex,
    required this.status,
  });

  factory FriendEntry.fromJson(Map<String, dynamic> json) {
    return FriendEntry(
      userId: json['userId'] as String? ?? '',
      nickname: json['nickname'] as String? ?? 'Skier',
      avatarIndex: json['avatarIndex'] as int? ?? 0,
      status: json['status'] as String? ?? 'accepted',
    );
  }
}

final friendLeaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final period = ref.watch(leaderboardPeriodProvider);

  final token = await api.token;
  if (token == null) return [];

  try {
    final data = await api.get('/leaderboard/friends?period=$period');
    final entries = (data['entries'] as List?)
            ?.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return entries;
  } catch (_) {
    return [];
  }
});

final friendsListProvider = FutureProvider<List<FriendEntry>>((ref) async {
  final api = ref.watch(apiClientProvider);

  final token = await api.token;
  if (token == null) return [];

  try {
    final data = await api.get('/friends');
    return (data['friends'] as List?)
            ?.map((e) => FriendEntry.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  } catch (_) {
    return [];
  }
});
