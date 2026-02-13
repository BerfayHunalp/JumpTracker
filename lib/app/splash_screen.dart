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
    _player.onPlayerComplete.listen((_) {
      if (_phase == 0) {
        _logoFadeOut.forward();
      }
    });

    await _player.play(AssetSource('splash_riser.mp3'));
  }

  void _dismissWelcome() {
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
          backgroundColor: const Color(0xFF121212),
          body: SafeArea(
            child: GestureDetector(
              onTap: _dismissWelcome,
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/bh_logo_small.png',
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'No ads, no revenue,\njust a cool app to share\nwith your friends.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          height: 1.5,
                          color: Colors.white70,
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
                    ],
                  ),
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
            'assets/images/bh_splash.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
