import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_providers.dart';
import '../../core/auth/auth_state.dart';
import 'widgets/social_sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isRegister = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _submitEmail() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;

    if (_isRegister) {
      final nickname = _nicknameController.text.trim().isEmpty
          ? email.split('@').first
          : _nicknameController.text.trim();
      ref.read(authStateProvider.notifier).registerWithEmail(email, password, nickname);
    } else {
      ref.read(authStateProvider.notifier).signInWithEmail(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pop this screen when auth succeeds or user skips
    ref.listen<AuthState>(authStateProvider, (prev, next) {
      if (prev is AuthLoading && (next is AuthAuthenticated || next is AuthUnauthenticated)) {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    });

    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              children: [
                const SizedBox(height: 48),

                // Logo
                Container(
                  width: 90,
                  height: 90,
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
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Ski Tracker',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Track your jumps, compete with friends',
                  style: TextStyle(fontSize: 15, color: Colors.white54),
                ),

                const SizedBox(height: 32),

                // Email/password form
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  )
                else ...[
                  // Toggle sign in / register
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isRegister = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _isRegister
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              'Create Account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _isRegister
                                    ? theme.colorScheme.primary
                                    : Colors.white38,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isRegister = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: !_isRegister
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              'Sign In',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: !_isRegister
                                    ? theme.colorScheme.primary
                                    : Colors.white38,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (_isRegister) ...[
                    _InputField(
                      controller: _nicknameController,
                      hint: 'Nickname',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _InputField(
                    controller: _emailController,
                    hint: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _InputField(
                    controller: _passwordController,
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    obscure: true,
                    onSubmitted: (_) => _submitEmail(),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _isRegister ? 'Create Account' : 'Sign In',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Divider
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white12)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or', style: TextStyle(color: Colors.white30)),
                      ),
                      Expanded(child: Divider(color: Colors.white12)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Google sign in
                  SocialSignInButton(
                    label: 'Continue with Google',
                    icon: Icons.g_mobiledata,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    onPressed: () {
                      ref.read(authStateProvider.notifier).signInWithGoogle();
                    },
                  ),
                  if (!kIsWeb && _isApplePlatform()) ...[
                    const SizedBox(height: 12),
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

                const SizedBox(height: 24),

                // Skip
                TextButton(
                  onPressed: () {
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

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      onSubmitted: onSubmitted,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
