import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_providers.dart';
import '../../core/auth/auth_state.dart';
import '../auth/login_screen.dart';
import 'community_providers.dart';
import 'friend_list_screen.dart';
import 'add_friend_screen.dart';
import '../challenges/king_of_hill_screen.dart';
import 'widgets/period_selector.dart';
import 'widgets/leaderboard_card.dart';
import 'widgets/invite_share_card.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  String? _inviteCode;
  String? _inviteLink;
  bool _generatingInvite = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final isAuthenticated = authState is AuthAuthenticated;

    if (!isAuthenticated) {
      return _UnauthenticatedView(theme: theme);
    }

    final period = ref.watch(leaderboardPeriodProvider);
    final leaderboardAsync = ref.watch(friendLeaderboardProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            title: const Text('Community'),
            actions: [
              IconButton(
                icon: const Icon(Icons.people, size: 22),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FriendListScreen()),
                ),
                tooltip: 'Friends',
              ),
              IconButton(
                icon: const Icon(Icons.person_add, size: 22),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddFriendScreen()),
                ),
                tooltip: 'Add Friend',
              ),
            ],
          ),

          // Period selector
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: PeriodSelector(
                selected: period,
                onChanged: (p) =>
                    ref.read(leaderboardPeriodProvider.notifier).state = p,
              ),
            ),
          ),

          // King of the Hill
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const KingOfHillScreen()),
                ),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFF7043).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.flag, color: Color(0xFFFF7043), size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'King of the Hill',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Compete at your favorite jump spots',
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.white24, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Invite card (if generated)
          if (_inviteCode != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    InviteShareCard(
                      code: _inviteCode!,
                      link: _inviteLink ?? '',
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

          // Leaderboard
          leaderboardAsync.when(
            data: (entries) {
              if (entries.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyLeaderboard(
                    onInvite: _generateInviteCode,
                    isLoading: _generatingInvite,
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        LeaderboardCard(entry: entries[index]),
                    childCount: entries.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Text('Error: $e',
                    style: const TextStyle(color: Colors.white30)),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: isAuthenticated
          ? FloatingActionButton.extended(
              onPressed: _generatingInvite ? null : _generateInviteCode,
              icon: _generatingInvite
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.person_add),
              label: const Text('Invite Friend'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Future<void> _generateInviteCode() async {
    setState(() => _generatingInvite = true);
    try {
      final api = ref.read(apiClientProvider);
      final data = await api.post('/friends/invite');
      setState(() {
        _inviteCode = data['code'] as String?;
        _inviteLink = data['link'] as String?;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate invite: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _generatingInvite = false);
    }
  }
}

class _UnauthenticatedView extends StatelessWidget {
  final ThemeData theme;
  const _UnauthenticatedView({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline,
                  size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              const Text(
                'Sign in to compete',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to see leaderboards, add friends, and compare your ski jumps!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Sign In', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyLeaderboard extends StatelessWidget {
  final VoidCallback onInvite;
  final bool isLoading;

  const _EmptyLeaderboard({required this.onInvite, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_outlined,
                size: 48, color: Colors.white24),
            const SizedBox(height: 16),
            const Text(
              'No scores yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Invite friends and record sessions to see the leaderboard!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white30, fontSize: 14),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: isLoading ? null : onInvite,
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Invite a Friend'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
