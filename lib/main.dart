import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/auth/auth_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: SkiTrackerApp()));
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
      home: const AppRoot(),
    );
  }
}
