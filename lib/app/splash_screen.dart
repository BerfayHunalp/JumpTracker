import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SplashScreen extends StatefulWidget {
  final Widget child;
  const SplashScreen({super.key, required this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  late final AnimationController _logoFadeOut;
  late final AnimationController _welcomeFade;

  /// 0 = logo, 1 = welcome, 2 = main app
  int _phase = 0;

  @override
  void initState() {
    super.initState();

    _logoFadeOut = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _logoFadeOut.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _phase = 1);
        _welcomeFade.forward();
      }
    });

    _welcomeFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _startSplash();
  }

  Future<void> _startSplash() async {
    await _player.play(AssetSource('wind.mp3'));

    // Stay on logo for 4 seconds, then fade to welcome page
    await Future.delayed(const Duration(seconds: 4));
    if (_phase == 0) {
      _logoFadeOut.forward();
    }
  }

  void _dismissWelcome() {
    _player.stop();
    setState(() => _phase = 2);
  }

  @override
  void dispose() {
    _player.dispose();
    _logoFadeOut.dispose();
    _welcomeFade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == 2) return widget.child;

    if (_phase == 1) {
      return AnimatedBuilder(
        animation: _welcomeFade,
        builder: (context, child) {
          return Opacity(opacity: _welcomeFade.value, child: child);
        },
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 23, 42, 75),
          body: GestureDetector(
            onTap: _dismissWelcome,
            behavior: HitTestBehavior.opaque,
            child: SizedBox.expand(
              child: SafeArea(
                child: Column(
                  children: [
                    const Spacer(),
                    Image.asset(
                      'assets/big icon.png',
                      width: 120,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Become the wind.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        height: 1.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 48),
                    TextButton(
                      onPressed: _dismissWelcome,
                      child: const Text(
                        "Let's go",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4FC3F7),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Text(
                        '\u00A9 2026, All rights reserved.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Phase 0: Logo + audio
    return AnimatedBuilder(
      animation: _logoFadeOut,
      builder: (context, child) {
        return Opacity(
          opacity: 1.0 - _logoFadeOut.value,
          child: child,
        );
      },
      child: Scaffold(
        body: SizedBox.expand(
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
