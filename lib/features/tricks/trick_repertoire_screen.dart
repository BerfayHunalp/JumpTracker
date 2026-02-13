import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/trick.dart';
import 'trick_providers.dart';

class TrickRepertoireScreen extends ConsumerWidget {
  const TrickRepertoireScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xp = ref.watch(trickXpProvider);
    final level = ref.watch(trickLevelProvider);
    final progress = ref.watch(trickLevelProgressProvider);
    // Watch states so the whole screen rebuilds on change
    ref.watch(trickMasteryProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: const Text(
              'Trick Repertoire',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // XP level bar
          SliverToBoxAdapter(
            child: _XpBar(xp: xp, level: level, progress: progress),
          ),

          // Category progress overview
          SliverToBoxAdapter(
            child: _CategoryProgress(ref: ref),
          ),

          // Trick catalog
          SliverList(
            delegate: SliverChildListDelegate(
              TrickCatalog.allByCategory.entries.map((entry) {
                return _TrickCategorySection(
                  category: entry.key,
                  tricks: entry.value,
                );
              }).toList(),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// XP Bar
// ---------------------------------------------------------------------------

class _XpBar extends StatelessWidget {
  final int xp;
  final TrickLevel level;
  final double progress;

  const _XpBar({
    required this.xp,
    required this.level,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final idx = trickLevels.indexOf(level);
    final nextLevel =
        idx < trickLevels.length - 1 ? trickLevels[idx + 1] : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                level.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD54F),
                ),
              ),
              const Spacer(),
              Text(
                nextLevel != null
                    ? '$xp / ${nextLevel.xpRequired} XP'
                    : '$xp XP (MAX)',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFFFD54F)),
            ),
          ),
          if (nextLevel != null) ...[
            const SizedBox(height: 6),
            Text(
              'Next: ${nextLevel.name}',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category progress bars
// ---------------------------------------------------------------------------

class _CategoryProgress extends StatelessWidget {
  final WidgetRef ref;

  const _CategoryProgress({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROGRESS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white38,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          ...TrickCatalog.allByCategory.entries.map((entry) {
            final cat = entry.key;
            final tricks = entry.value;
            final notifier = ref.read(trickMasteryProvider.notifier);
            final landed = notifier.landedCount(cat);
            final total = tricks.length;
            final pct = total > 0 ? landed / total : 0.0;
            final color = Color(cat.colorValue);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      cat.label,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '$landed/$total',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Collapsible category section
// ---------------------------------------------------------------------------

class _TrickCategorySection extends ConsumerStatefulWidget {
  final TrickCategory category;
  final List<Trick> tricks;

  const _TrickCategorySection({
    required this.category,
    required this.tricks,
  });

  @override
  ConsumerState<_TrickCategorySection> createState() =>
      _TrickCategorySectionState();
}

class _TrickCategorySectionState
    extends ConsumerState<_TrickCategorySection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.category.colorValue);
    ref.watch(trickMasteryProvider);

    return Column(
      children: [
        // Category header
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${widget.category.label.toUpperCase()} (${widget.tricks.length})',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white38,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // Trick cards
        if (_expanded)
          ...widget.tricks.map((trick) => _TrickCard(trick: trick)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Individual trick card
// ---------------------------------------------------------------------------

class _TrickCard extends ConsumerWidget {
  final Trick trick;

  const _TrickCard({required this.trick});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mastery = ref.watch(trickMasteryProvider.notifier).getMastery(trick.id);
    final color = Color(trick.category.colorValue);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: mastery == TrickMastery.mastered
              ? const Color(0xFFFFD54F).withValues(alpha: 0.4)
              : mastery == TrickMastery.landed
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          // Trick info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name row with stars and risk
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        trick.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Difficulty stars
                    Text(
                      List.filled(trick.difficulty.stars, '\u2605').join(),
                      style: TextStyle(
                        fontSize: 12,
                        color: color.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Risk badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _riskColor(trick.risk).withValues(alpha: 0.2),
                      ),
                      child: Text(
                        trick.risk.label,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: _riskColor(trick.risk),
                        ),
                      ),
                    ),
                  ],
                ),

                if (trick.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    trick.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 10),

          // State button
          GestureDetector(
            onTap: () {
              ref.read(trickMasteryProvider.notifier).cycleMastery(trick.id);
              final next = ref
                  .read(trickMasteryProvider.notifier)
                  .getMastery(trick.id);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${trick.name}: ${next.label}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _masteryBgColor(mastery),
              ),
              child: Center(
                child: Text(
                  mastery.icon,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _riskColor(TrickRisk risk) {
    switch (risk) {
      case TrickRisk.low:
        return const Color(0xFF81C784);
      case TrickRisk.medium:
        return const Color(0xFFFFD54F);
      case TrickRisk.high:
        return const Color(0xFFFF7043);
    }
  }

  Color _masteryBgColor(TrickMastery mastery) {
    switch (mastery) {
      case TrickMastery.locked:
        return Colors.white.withValues(alpha: 0.06);
      case TrickMastery.attempted:
        return const Color(0xFF4FC3F7).withValues(alpha: 0.15);
      case TrickMastery.working:
        return const Color(0xFFFFD54F).withValues(alpha: 0.15);
      case TrickMastery.landed:
        return const Color(0xFF81C784).withValues(alpha: 0.2);
      case TrickMastery.mastered:
        return const Color(0xFFFFD54F).withValues(alpha: 0.3);
    }
  }
}
