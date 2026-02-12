import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/jump.dart';
import '../../jump_detail/jump_detail_screen.dart';
import '../providers/session_providers.dart';

class JumpListSection extends ConsumerWidget {
  const JumpListSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jumps = ref.watch(jumpListProvider);
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                'ALL JUMPS (${jumps.length})',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white54,
                  letterSpacing: 1,
                ),
              ),
            ),
            if (jumps.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'Jumps will appear here',
                    style: TextStyle(color: Colors.white30, fontSize: 14),
                  ),
                ),
              )
            else
              // Show most recent first
              ...jumps.reversed.toList().asMap().entries.map((entry) {
                final index = jumps.length - entry.key;
                return _JumpTile(jump: entry.value, number: index);
              }),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _JumpTile extends StatelessWidget {
  final Jump jump;
  final int number;

  const _JumpTile({required this.jump, required this.number});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JumpDetailScreen(jumpId: jump.id),
          ),
        ),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4FC3F7).withValues(alpha: 0.2),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4FC3F7),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${jump.airtimeMs}ms',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '${jump.heightM.toStringAsFixed(1)}m',
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(width: 16),
              Text(
                '${jump.distanceM.toStringAsFixed(1)}m',
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(width: 16),
              Text(
                '${jump.score.toStringAsFixed(0)} pts',
                style: const TextStyle(
                  color: Color(0xFFFF7043),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
