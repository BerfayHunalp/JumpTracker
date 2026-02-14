import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('Live Session'),
            centerTitle: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          const SliverToBoxAdapter(child: SessionControlButton()),
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
