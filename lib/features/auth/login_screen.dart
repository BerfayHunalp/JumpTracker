import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_providers.dart';
import '../../core/auth/auth_state.dart';
import 'widgets/social_sign_in_button.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo area
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.downhill_skiing,
                  size: 52,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Ski Tracker',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Track your jumps, compete with friends',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white54,
                ),
              ),

              const Spacer(flex: 2),

              // Sign in buttons
              if (isLoading)
                const CircularProgressIndicator()
              else ...[
                SocialSignInButton(
                  label: 'Continue with Google',
                  icon: Icons.g_mobiledata,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  onPressed: () {
                    ref.read(authStateProvider.notifier).signInWithGoogle();
                  },
                ),
                const SizedBox(height: 12),
                if (!kIsWeb && _isApplePlatform())
                  SocialSignInButton(
                    label: 'Continue with Apple',
                    icon: Icons.apple,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    onPressed: () {
                      ref.read(authStateProvider.notifier).signInWithApple();
                    },
                  ),
              ],

              // Error message
              if (authState is AuthError) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authState.message,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // Skip for now
              TextButton(
                onPressed: () {
                  // Allow usage without signing in (offline mode)
                  ref.read(authStateProvider.notifier).signOut();
                },
                child: const Text(
                  'Skip for now',
                  style: TextStyle(color: Colors.white38, fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  bool _isApplePlatform() {
    try {
      return Platform.isIOS || Platform.isMacOS;
    } catch (_) {
      return false;
    }
  }
}
