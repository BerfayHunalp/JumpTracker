import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../shared/widgets/stat_card.dart';
import '../jump_detail/jump_detail_screen.dart';
import 'profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(profileStatsProvider);
    final bestAsync = ref.watch(bestJumpsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: theme.colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Profile'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.2),
                      theme.colorScheme.surface,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Lifetime stats grid
          statsAsync.when(
            data: (stats) => SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                ),
                delegate: SliverChildListDelegate([
                  StatCard(
                    icon: Icons.flight_takeoff,
                    value: '${stats.totalJumps}',
                    label: 'Total Jumps',
                  ),
                  StatCard(
                    icon: Icons.calendar_today,
                    value: '${stats.totalSessions}',
                    label: 'Sessions',
                  ),
                  StatCard(
                    icon: Icons.terrain,
                    value: stats.totalVerticalM >= 1000
                        ? '${(stats.totalVerticalM / 1000).toStringAsFixed(1)}km'
                        : '${stats.totalVerticalM.toStringAsFixed(0)}m',
                    label: 'Total Vertical',
                  ),
                  StatCard(
                    icon: Icons.timer,
                    value: stats.maxAirtimeMs > 0
                        ? '${stats.maxAirtimeMs.toStringAsFixed(0)}ms'
                        : '-',
                    label: 'Max Airtime',
                  ),
                ]),
              ),
            ),
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $e')),
            ),
          ),

          // Personal Records header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'PERSONAL RECORDS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white54,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),

          // Best jumps
          bestAsync.when(
            data: (best) {
              if (best.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Record some jumps to see your records here',
                        style: TextStyle(color: Colors.white30, fontSize: 14),
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (best.bestAirtime != null)
                      _BestJumpCard(
                        title: 'Longest Airtime',
                        icon: Icons.timer,
                        jump: best.bestAirtime!,
                        highlightValue:
                            '${best.bestAirtime!.airtimeMs.toStringAsFixed(0)}ms',
                        onTap: () => _goToJump(context, best.bestAirtime!.id),
                      ),
                    if (best.bestHeight != null) ...[
                      const SizedBox(height: 8),
                      _BestJumpCard(
                        title: 'Highest Jump',
                        icon: Icons.height,
                        jump: best.bestHeight!,
                        highlightValue:
                            '${best.bestHeight!.heightM.toStringAsFixed(1)}m',
                        onTap: () => _goToJump(context, best.bestHeight!.id),
                      ),
                    ],
                    if (best.bestDistance != null) ...[
                      const SizedBox(height: 8),
                      _BestJumpCard(
                        title: 'Longest Distance',
                        icon: Icons.straighten,
                        jump: best.bestDistance!,
                        highlightValue:
                            '${best.bestDistance!.distanceM.toStringAsFixed(1)}m',
                        onTap: () => _goToJump(context, best.bestDistance!.id),
                      ),
                    ],
                    if (best.bestScore != null) ...[
                      const SizedBox(height: 8),
                      _BestJumpCard(
                        title: 'Best Score',
                        icon: Icons.emoji_events,
                        jump: best.bestScore!,
                        highlightValue: _jumpScore(best.bestScore!),
                        highlightColor: const Color(0xFFFF7043),
                        onTap: () => _goToJump(context, best.bestScore!.id),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ]),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
        ],
      ),
    );
  }

  void _goToJump(BuildContext context, String jumpId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JumpDetailScreen(jumpId: jumpId)),
    );
  }

  String _jumpScore(Jump j) {
    final score = (j.airtimeMs / 100) * 40 + j.heightM * 30 + j.distanceM * 10;
    return score.toStringAsFixed(0);
  }
}

class _BestJumpCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Jump jump;
  final String highlightValue;
  final Color? highlightColor;
  final VoidCallback onTap;

  const _BestJumpCard({
    required this.title,
    required this.icon,
    required this.jump,
    required this.highlightValue,
    this.highlightColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = highlightColor ?? theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    highlightValue,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }
}
