import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'app/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: SkiTrackerApp()));
}

class SkiTrackerApp extends StatelessWidget {
  const SkiTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ski Tracker',
      theme: SkiTrackerTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const AppShell(),
    );
  }
}
