import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../challenges/challenge_providers.dart';
import 'providers/session_providers.dart';
import 'widgets/session_control_button.dart';
import 'widgets/live_stats_bar.dart';
import 'widgets/g_force_gauge.dart';
import 'widgets/jump_state_badge.dart';
import 'widgets/last_jump_card.dart';
import 'widgets/jump_list_section.dart';
import 'widgets/mini_map.dart';

class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('Live Session'),
            centerTitle: true,
            backgroundColor: theme.colorScheme.surface,
          ),
          const SliverToBoxAdapter(child: SessionControlButton()),

          // Ghost challenge overlay
          if (session.isRecording && session.gpsTrack.isNotEmpty)
            SliverToBoxAdapter(
              child: _GhostBanner(
                lat: session.gpsTrack.last.latitude,
                lon: session.gpsTrack.last.longitude,
              ),
            ),

          const SliverToBoxAdapter(child: LiveStatsBar()),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: GForceGauge()),
                  SizedBox(width: 8),
                  Expanded(child: JumpStateBadge()),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: LastJumpCard()),
          const SliverToBoxAdapter(child: MiniMap()),
          const SliverToBoxAdapter(child: JumpListSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _GhostBanner extends ConsumerWidget {
  final double lat;
  final double lon;

  const _GhostBanner({required this.lat, required this.lon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ghostAsync = ref.watch(
      ghostChallengeProvider((lat: lat, lon: lon)),
    );

    return ghostAsync.when(
      data: (ghost) {
        if (ghost == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7043).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF7043).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events,
                    color: Color(0xFFFFCA28), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ghost Challenge!',
                        style: TextStyle(
                          color: Color(0xFFFF7043),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Beat your best: ${ghost.previousBest.airtimeMs}ms airtime, '
                        '${jumpScore(ghost.previousBest).toStringAsFixed(0)} pts',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${ghost.distanceM.toStringAsFixed(0)}m away',
                  style: const TextStyle(
                      color: Colors.white30, fontSize: 10),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
