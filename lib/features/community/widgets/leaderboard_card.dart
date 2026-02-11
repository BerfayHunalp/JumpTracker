import 'package:flutter/material.dart';
import '../../profile/widgets/avatar_widget.dart';
import '../community_providers.dart';

class LeaderboardCard extends StatelessWidget {
  final LeaderboardEntry entry;

  const LeaderboardCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTopThree = entry.rank <= 3;

    Color rankColor;
    switch (entry.rank) {
      case 1:
        rankColor = const Color(0xFFFFD700); // gold
        break;
      case 2:
        rankColor = const Color(0xFFC0C0C0); // silver
        break;
      case 3:
        rankColor = const Color(0xFFCD7F32); // bronze
        break;
      default:
        rankColor = Colors.white38;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: entry.isMe
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: entry.isMe
            ? Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 28,
            child: isTopThree
                ? Icon(Icons.emoji_events, color: rankColor, size: 22)
                : Text(
                    '${entry.rank}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: rankColor,
                    ),
                  ),
          ),
          const SizedBox(width: 10),

          // Avatar
          AvatarWidget(avatarIndex: entry.avatarIndex, size: 36),
          const SizedBox(width: 10),

          // Name + jumps
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.nickname,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: entry.isMe
                        ? theme.colorScheme.primary
                        : Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${entry.totalJumps} jumps',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Score
          Text(
            entry.totalScore.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isTopThree ? rankColor : Colors.white70,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'pts',
            style: TextStyle(fontSize: 10, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}
