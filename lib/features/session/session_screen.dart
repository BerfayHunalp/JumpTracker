import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/equipment.dart';
import '../challenges/challenge_providers.dart';
import '../equipment/equipment_providers.dart';
import '../learn/learn_screen.dart';
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

          // Going Hors Piste button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _showHorsPisteFlow(context, ref),
                  icon: const Icon(Icons.terrain, size: 22),
                  label: const Text(
                    'Going Hors Piste',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7043),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ),

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

// ---------------------------------------------------------------------------
// Going Hors Piste safety flow
// ---------------------------------------------------------------------------

void _showHorsPisteFlow(BuildContext context, WidgetRef ref) {
  final equipState = ref.read(equipmentProvider);
  final learnProgress = ref.read(learnProgressProvider);

  final securityItems = EquipmentCatalog.all
      .where((e) => e.type == EquipmentType.securite)
      .toList();
  final missingGear = <Equipment>[];
  for (final item in securityItems) {
    final s = equipState[item.id];
    if (s == null || !s.owned) {
      missingGear.add(item);
    }
  }

  final allLessonsCompleted =
      learnProgress.length >= LearnCatalog.all.length;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1A1A2E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFFF7043), size: 28),
              SizedBox(width: 10),
              Text(
                'Going Off-Piste',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Education warning
          _HorsPisteWarning(
            icon: Icons.school,
            iconColor: allLessonsCompleted
                ? const Color(0xFF81C784)
                : const Color(0xFFFFB74D),
            title: allLessonsCompleted
                ? 'Education: Completed'
                : 'Education: Incomplete!',
            child: Text(
              allLessonsCompleted
                  ? 'You\'ve completed all lessons. Stay sharp out there.'
                  : 'You haven\'t finished the Learn section. As far as we know, you may not know how to ski safely off-piste.\n\nEither take the time to complete your education first, or go at your own peril.',
              style: TextStyle(
                fontSize: 13,
                color: allLessonsCompleted
                    ? Colors.white54
                    : const Color(0xFFFFB74D),
                height: 1.5,
                fontWeight: allLessonsCompleted
                    ? FontWeight.normal
                    : FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Security gear check
          _HorsPisteWarning(
            icon: Icons.shield,
            iconColor: missingGear.isEmpty
                ? const Color(0xFF81C784)
                : const Color(0xFFEF5350),
            title: missingGear.isEmpty
                ? 'Security gear: All checked'
                : 'Missing security gear!',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...securityItems.map((item) {
                  final owned = !missingGear.contains(item);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Icon(
                          owned ? Icons.check_circle : Icons.cancel,
                          size: 18,
                          color: owned
                              ? const Color(0xFF81C784)
                              : const Color(0xFFEF5350),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 13,
                            color: owned ? Colors.white70 : const Color(0xFFEF5350),
                            fontWeight:
                                owned ? FontWeight.normal : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (missingGear.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'You NEED all security equipment to reduce risk of death in an avalanche.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFEF5350),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Avalanche facts
          const _HorsPisteWarning(
            icon: Icons.ac_unit,
            iconColor: Color(0xFF4FC3F7),
            title: 'Avalanche Risk',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BulletPoint('Every year, ~100 people die from avalanches in the Alps.'),
                _BulletPoint('90% of the time, it\'s the victim or their group that triggered the avalanche.'),
                _BulletPoint('You have max 15 minutes of air if buried under snow. After that, survival drops drastically.'),
                _BulletPoint('There is NO mountain with zero risk. Every off-piste run is a gamble.'),
                SizedBox(height: 6),
                Text(
                  'If you don\'t know precisely what you\'re doing — you might die.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFFF7043),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // GPS limitation
          const _HorsPisteWarning(
            icon: Icons.gps_off,
            iconColor: Color(0xFFFFB74D),
            title: 'GPS is limited in mountains',
            child: Text(
              'Mountain terrain (valleys, cliffs, dense forest) causes GPS signal loss and inaccuracy. Your location may be off by 50-200m or stop updating entirely.',
              style: TextStyle(fontSize: 13, color: Colors.white54, height: 1.5),
            ),
          ),
          const SizedBox(height: 12),

          // Solo warning
          const _HorsPisteWarning(
            icon: Icons.person,
            iconColor: Color(0xFFEF5350),
            title: 'Going alone?',
            child: Text(
              'If you\'re alone and seeking thrills, stay close to marked slopes. Off-piste alone means nobody to dig you out in 15 minutes.',
              style: TextStyle(fontSize: 13, color: Colors.white54, height: 1.5),
            ),
          ),
          const SizedBox(height: 12),

          // WhatsApp reminder
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF25D366).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF25D366).withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.chat, color: Color(0xFF25D366), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Remember to share your WhatsApp live location with a friend before heading out.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF25D366),
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Close button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF7043),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'I understand',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Hors Piste warning section
// ---------------------------------------------------------------------------

class _HorsPisteWarning extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _HorsPisteWarning({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, size: 6, color: Colors.white30),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.white54, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ghost challenge banner
// ---------------------------------------------------------------------------

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
