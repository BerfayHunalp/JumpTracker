import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/detection/jump_detector.dart';
import '../providers/session_providers.dart';

class JumpStateBadge extends ConsumerWidget {
  const JumpStateBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detectorState = ref.watch(detectorStateProvider);
    final isRecording = ref.watch(isRecordingProvider);
    final jumpCount = ref.watch(jumpListProvider).length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildBadge(detectorState, isRecording),
          ),
          const SizedBox(height: 12),
          Text(
            '$jumpCount',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            jumpCount == 1 ? 'jump' : 'jumps',
            style: const TextStyle(fontSize: 12, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(JumpState state, bool isRecording) {
    if (!isRecording) {
      return _badge('READY', Colors.grey, Icons.downhill_skiing_outlined, key: 'ready');
    }

    switch (state) {
      case JumpState.skiing:
        return _badge('SKIING', const Color(0xFF78909C), Icons.downhill_skiing_outlined, key: 'skiing');
      case JumpState.freefallPending:
        return _badge('DETECTING...', const Color(0xFFFFEB3B), Icons.arrow_upward, key: 'pending');
      case JumpState.airborne:
        return const _AirborneBadge(key: ValueKey('airborne'));
      case JumpState.cooldown:
        return _badge('LANDED', const Color(0xFF66BB6A), Icons.check_circle, key: 'landed');
    }
  }

  Widget _badge(String label, Color color, IconData icon, {required String key}) {
    return Container(
      key: ValueKey(key),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Special animated badge for the AIRBORNE state.
class _AirborneBadge extends StatefulWidget {
  const _AirborneBadge({super.key});

  @override
  State<_AirborneBadge> createState() => _AirborneBadgeState();
}

class _AirborneBadgeState extends State<_AirborneBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFFF7043);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + _controller.value * 0.08;
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3 + _controller.value * 0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.flight, size: 18, color: color),
                SizedBox(width: 6),
                Text(
                  'AIRBORNE!',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
