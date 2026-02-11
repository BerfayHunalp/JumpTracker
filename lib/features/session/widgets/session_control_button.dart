import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../label_jumps_screen.dart';
import '../providers/session_providers.dart';

class SessionControlButton extends ConsumerWidget {
  const SessionControlButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRecording = ref.watch(isRecordingProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: GestureDetector(
          onTap: () {
            final notifier = ref.read(sessionProvider.notifier);

            if (isRecording) {
              // Capture session info before stopping
              final sessionId = notifier.currentSessionId;
              final jumpCount = ref.read(sessionProvider).jumps.length;
              notifier.toggleRecording();

              // Navigate to label screen if jumps were detected
              if (sessionId != null && jumpCount > 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        LabelJumpsScreen(sessionId: sessionId),
                  ),
                );
              }
            } else {
              notifier.toggleRecording();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRecording
                  ? const Color(0xFFFF7043)
                  : const Color(0xFF4FC3F7),
              boxShadow: [
                BoxShadow(
                  color: (isRecording
                          ? const Color(0xFFFF7043)
                          : const Color(0xFF4FC3F7))
                      .withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              isRecording ? Icons.stop_rounded : Icons.play_arrow_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
