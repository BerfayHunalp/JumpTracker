import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../permissions/permission_screen.dart';
import '../label_jumps_screen.dart';
import '../providers/session_providers.dart';

/// Whether the permission onboarding has been completed.
final _permsDoneProvider = StateProvider<bool>((ref) => false);

class SessionControlButton extends ConsumerWidget {
  const SessionControlButton({super.key});

  Future<void> _startRecording(BuildContext context, WidgetRef ref) async {
    // Check if permission onboarding was done
    final permsDone = ref.read(_permsDoneProvider);
    if (!permsDone) {
      final prefs = await SharedPreferences.getInstance();
      final done = prefs.getBool('permissions_onboarded') ?? false;
      if (!done) {
        if (!context.mounted) return;
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const PermissionScreen()),
        );
        if (result == true) {
          await prefs.setBool('permissions_onboarded', true);
        }
      }
      ref.read(_permsDoneProvider.notifier).state = true;
    }

    ref.read(sessionProvider.notifier).toggleRecording();
  }

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
              _startRecording(context, ref);
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
