import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'achievements_providers.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() =>
      _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  AchievementCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(achievementStateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: stateAsync.when(
        data: (state) => _buildContent(state, theme),
        loading: () => Scaffold(
          appBar: AppBar(
            backgroundColor: theme.colorScheme.surface,
            title: const Text('Achievements'),
          ),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(
            backgroundColor: theme.colorScheme.surface,
            title: const Text('Achievements'),
          ),
          body: Center(
            child:
                Text('Error: $e', style: const TextStyle(color: Colors.white30)),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AchievementState state, ThemeData theme) {
    final unlocked = state.unlockedCount;
    final total = achievements.length;
    final progress = total > 0 ? unlocked / total : 0.0;

    // Filter achievements
    final filtered = _selectedCategory == null
        ? achievements
        : achievements.where((a) => a.category == _selectedCategory).toList();

    // Sort: unlocked first, then locked
    final sorted = [...filtered]
      ..sort((a, b) {
        final aUnlocked = state.isUnlocked(a.id);
        final bUnlocked = state.isUnlocked(b.id);
        if (aUnlocked && !bUnlocked) return -1;
        if (!aUnlocked && bUnlocked) return 1;
        return 0;
      });

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: theme.colorScheme.surface,
          title: const Text('Achievements'),
        ),

        // Progress header
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFCA28).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '$unlocked / $total',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFFCA28),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'achievements unlocked',
                  style: TextStyle(fontSize: 14, color: Colors.white54),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFFCA28)),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Category filter chips
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _CategoryChip(
                    label: 'All',
                    isSelected: _selectedCategory == null,
                    onTap: () =>
                        setState(() => _selectedCategory = null),
                  ),
                  ..._categoryEntries.map((entry) => _CategoryChip(
                        label: entry.label,
                        isSelected: _selectedCategory == entry.category,
                        onTap: () => setState(() => _selectedCategory =
                            _selectedCategory == entry.category
                                ? null
                                : entry.category),
                      )),
                ],
              ),
            ),
          ),
        ),

        // Achievement grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final a = sorted[index];
                final isUnlocked = state.isUnlocked(a.id);
                return _AchievementCard(
                    achievement: a, isUnlocked: isUnlocked);
              },
              childCount: sorted.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Category filter
// ---------------------------------------------------------------------------

class _CategoryEntry {
  final String label;
  final AchievementCategory category;
  const _CategoryEntry(this.label, this.category);
}

const _categoryEntries = [
  _CategoryEntry('Jumps', AchievementCategory.jumps),
  _CategoryEntry('Sessions', AchievementCategory.sessions),
  _CategoryEntry('Performance', AchievementCategory.performance),
  _CategoryEntry('Tricks', AchievementCategory.tricks),
  _CategoryEntry('Gear', AchievementCategory.gear),
  _CategoryEntry('Learn', AchievementCategory.learn),
];

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFFCA28).withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFFCA28).withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              color: isSelected ? const Color(0xFFFFCA28) : Colors.white54,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Achievement card
// ---------------------------------------------------------------------------

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;

  const _AchievementCard({
    required this.achievement,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked
            ? const Color(0xFFFFCA28).withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked
              ? const Color(0xFFFFCA28).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isUnlocked ? achievement.icon : '\u{1F512}',
                style: TextStyle(
                  fontSize: 24,
                  color: isUnlocked ? null : Colors.white24,
                ),
              ),
              const Spacer(),
              if (isUnlocked)
                const Icon(Icons.check_circle,
                    color: Color(0xFFFFCA28), size: 18),
            ],
          ),
          const Spacer(),
          Text(
            achievement.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isUnlocked ? Colors.white : Colors.white38,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            achievement.description,
            style: TextStyle(
              fontSize: 11,
              color: isUnlocked ? Colors.white54 : Colors.white24,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
