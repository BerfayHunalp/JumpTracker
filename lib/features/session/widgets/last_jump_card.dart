import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/jump.dart';
import '../../jump_detail/jump_detail_screen.dart';
import '../providers/session_providers.dart';

class LastJumpCard extends ConsumerWidget {
  const LastJumpCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jump = ref.watch(lastJumpProvider);
    final jumpCount = ref.watch(jumpListProvider).length;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  const Text(
                    'LAST JUMP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white54,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  if (jumpCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '#$jumpCount',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: jump != null
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              JumpDetailScreen(jumpId: jump.id),
                        ),
                      )
                  : null,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: jump == null
                    ? const Padding(
                        key: ValueKey('empty'),
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'No jumps detected yet',
                            style:
                                TextStyle(color: Colors.white30, fontSize: 14),
                          ),
                        ),
                      )
                    : _JumpMetrics(key: ValueKey(jump.id), jump: jump),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JumpMetrics extends StatelessWidget {
  final Jump jump;
  const _JumpMetrics({super.key, required this.jump});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          _metric('${jump.airtimeMs.toStringAsFixed(0)}ms', 'Airtime'),
          _metric('${jump.heightM.toStringAsFixed(1)}m', 'Height'),
          _metric('${jump.distanceM.toStringAsFixed(1)}m', 'Distance'),
          _metric('${jump.landingGForce.toStringAsFixed(1)}G', 'Landing'),
          _score(jump.score),
        ],
      ),
    );
  }

  Widget _metric(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _score(double score) {
    return Expanded(
      child: Column(
        children: [
          Text(
            score.toStringAsFixed(0),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF7043),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Score',
            style: TextStyle(fontSize: 10, color: Color(0xFFFF7043)),
          ),
        ],
      ),
    );
  }
}
