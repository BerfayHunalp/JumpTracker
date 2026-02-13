import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_providers.dart';
import '../../core/auth/auth_state.dart';
import '../../core/database/database.dart';
import '../../core/models/trick.dart';
import '../../shared/widgets/stat_card.dart';
import '../achievements/achievements_providers.dart';
import '../achievements/achievements_screen.dart';
import '../auth/login_screen.dart';
import '../about/about_screen.dart';
import '../equipment/equipment_screen.dart';
import '../jump_detail/jump_detail_screen.dart';
import '../learn/learn_screen.dart';
import '../stats/stats_screen.dart';
import 'edit_profile_screen.dart';
import 'profile_providers.dart';
import 'widgets/avatar_widget.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(profileStatsProvider);
    final bestAsync = ref.watch(bestJumpsProvider);
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);

    final isAuthenticated = authState is AuthAuthenticated;
    final user = isAuthenticated ? authState.user : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: isAuthenticated ? 180 : 120,
            backgroundColor: theme.colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
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
                child: SafeArea(
                  child: isAuthenticated
                      ? _UserHeader(user: user!)
                      : const _GuestHeader(),
                ),
              ),
            ),
            actions: [
              if (isAuthenticated)
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditProfileScreen()),
                  ),
                ),
            ],
          ),

          // Sign-in prompt for guests
          if (!isAuthenticated)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.cloud_upload,
                            color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Sign in to sync',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                'Sync sessions and compete with friends',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white24),
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
                        ? '${stats.maxAirtimeMs.toInt()}ms'
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

          // Navigation cards: Achievements + Stats + Equipment
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _NavigationCard(
                          icon: Icons.military_tech,
                          label: 'Achievements',
                          sublabelWidget: ref.watch(unlockedCountProvider).when(
                                data: (count) => Text(
                                  '$count / 37 unlocked',
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 11),
                                ),
                                loading: () => const Text('...',
                                    style: TextStyle(
                                        color: Colors.white38, fontSize: 11)),
                                error: (_, __) => const SizedBox.shrink(),
                              ),
                          color: const Color(0xFFFFCA28),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AchievementsScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _NavigationCard(
                          icon: Icons.bar_chart,
                          label: 'Statistics',
                          sublabelWidget: const Text(
                            'View your progress',
                            style: TextStyle(color: Colors.white38, fontSize: 11),
                          ),
                          color: const Color(0xFF4FC3F7),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const StatsScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: _NavigationCard(
                      icon: Icons.backpack,
                      label: 'My Equipment',
                      sublabelWidget: const Text(
                        'Track your gear checklist',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                      color: const Color(0xFF81C784),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EquipmentScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _NavigationCard(
                          icon: Icons.school,
                          label: 'Learn',
                          sublabelWidget: Builder(builder: (_) {
                            final done = ref.watch(learnProgressProvider).length;
                            final total = LearnCatalog.all.length;
                            return Text(
                              '$done / $total lessons',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 11),
                            );
                          }),
                          color: const Color(0xFFFFCA28),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LearnScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _NavigationCard(
                          icon: Icons.info_outline,
                          label: 'About',
                          sublabelWidget: const Text(
                            'How it all works',
                            style: TextStyle(
                                color: Colors.white38, fontSize: 11),
                          ),
                          color: const Color(0xFF90A4AE),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AboutScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Personal Records header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                    const SizedBox(height: 16),
                  ]),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // Sign out button
          if (isAuthenticated)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton.icon(
                  onPressed: () {
                    ref.read(authStateProvider.notifier).signOut();
                  },
                  icon: const Icon(Icons.logout, color: Colors.white38),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
    final score = computeJumpScore(
      airtimeMs: j.airtimeMs,
      heightM: j.heightM,
      distanceM: j.distanceM,
      trickLabel: j.trickLabel,
    );
    return score.toStringAsFixed(0);
  }
}

class _UserHeader extends StatelessWidget {
  final dynamic user;
  const _UserHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AvatarWidget(avatarIndex: user.avatarIndex, size: 64),
          const SizedBox(height: 12),
          Text(
            user.nickname,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            user.email ?? '',
            style: const TextStyle(fontSize: 13, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}

class _GuestHeader extends StatelessWidget {
  const _GuestHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline, size: 40, color: Colors.white30),
          SizedBox(height: 4),
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
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

class _NavigationCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget sublabelWidget;
  final Color color;
  final VoidCallback onTap;

  const _NavigationCard({
    required this.icon,
    required this.label,
    required this.sublabelWidget,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            sublabelWidget,
          ],
        ),
      ),
    );
  }
}
