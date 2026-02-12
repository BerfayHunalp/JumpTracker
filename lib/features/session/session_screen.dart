import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/sensors/sensors.dart';
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
    final useMock = ref.watch(useMockSensorsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('Live Session'),
            centerTitle: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            actions: [
              IconButton(
                icon: Icon(
                  useMock ? Icons.science : Icons.sensors,
                  color: useMock ? const Color(0xFF4FC3F7) : Colors.white38,
                  size: 22,
                ),
                tooltip: useMock ? 'Simulator ON' : 'Use simulator',
                onPressed: () {
                  ref.read(useMockSensorsProvider.notifier).state = !useMock;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        !useMock
                            ? 'Simulator mode — fake jumps will be generated'
                            : 'Real sensors mode',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          // Simulator toggle banner
          SliverToBoxAdapter(
            child: _SimulatorBanner(
              useMock: useMock,
              onToggle: () {
                ref.read(useMockSensorsProvider.notifier).state = !useMock;
              },
            ),
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

class _SimulatorBanner extends StatelessWidget {
  final bool useMock;
  final VoidCallback onToggle;

  const _SimulatorBanner({required this.useMock, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: useMock
                ? const Color(0xFF4FC3F7).withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: useMock
                  ? const Color(0xFF4FC3F7).withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.science,
                color: useMock ? const Color(0xFF4FC3F7) : Colors.white30,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  useMock
                      ? 'Simulator ON — fake jumps will be generated'
                      : 'Tap to enable simulator (no real sensors)',
                  style: TextStyle(
                    color: useMock ? const Color(0xFF4FC3F7) : Colors.white38,
                    fontSize: 13,
                  ),
                ),
              ),
              Switch(
                value: useMock,
                onChanged: (_) => onToggle(),
                activeColor: const Color(0xFF4FC3F7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
