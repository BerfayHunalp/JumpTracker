import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/router.dart';
import 'app/splash_screen.dart';
import 'app/theme.dart';
import 'core/auth/auth_providers.dart';
import 'features/tricks/trick_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const SkiTrackerApp(),
    ),
  );
}

class SkiTrackerApp extends ConsumerStatefulWidget {
  const SkiTrackerApp({super.key});

  @override
  ConsumerState<SkiTrackerApp> createState() => _SkiTrackerAppState();
}

class _SkiTrackerAppState extends ConsumerState<SkiTrackerApp> {
  @override
  void initState() {
    super.initState();
    // Load stored auth token on startup
    Future.microtask(() {
      ref.read(authStateProvider.notifier).loadStoredAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ski Tracker',
      theme: SkiTrackerTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(child: AppRoot()),
    );
  }
}
