import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/session_providers.dart';
import '../../../shared/widgets/stat_card.dart';

class LiveStatsBar extends ConsumerWidget {
  const LiveStatsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(liveStatsProvider);

    final minutes = stats.elapsed.inMinutes;
    final seconds = stats.elapsed.inSeconds % 60;
    final durationStr = stats.elapsed.inHours > 0
        ? '${stats.elapsed.inHours}:${minutes.remainder(60).toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              icon: Icons.speed,
              value: stats.speed.toStringAsFixed(1),
              label: 'km/h',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              icon: Icons.terrain,
              value: stats.altitude.toStringAsFixed(0),
              label: 'meters',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              icon: Icons.timer,
              value: durationStr,
              label: 'duration',
            ),
          ),
        ],
      ),
    );
  }
}
