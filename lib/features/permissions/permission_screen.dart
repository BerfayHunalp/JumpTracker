import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart'
    as ph;

/// Shown before the first session recording.
/// Walks the user through all required permissions with explanations.
class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  int _step = 0;
  bool _locationGranted = false;
  bool _backgroundGranted = false;
  bool _notificationGranted = false;
  bool _batteryExempt = false;
  bool _activityGranted = false;

  final _steps = const [
    _PermStep(
      icon: Icons.location_on,
      color: Color(0xFF4FC3F7),
      title: 'Precise Location',
      subtitle: 'Required',
      description:
          'GPS tracks your speed, altitude, and maps your runs. '
          'We need precise location to tell if you\'re on a slope or in the lodge.',
    ),
    _PermStep(
      icon: Icons.location_on_outlined,
      color: Color(0xFF66BB6A),
      title: 'Background Location',
      subtitle: '"Always Allow"',
      description:
          'Keep tracking while your phone is in your pocket with the screen off. '
          'Without this, recording stops when you lock your phone.',
    ),
    _PermStep(
      icon: Icons.notifications_active,
      color: Color(0xFFFF7043),
      title: 'Notifications',
      subtitle: 'Recommended',
      description:
          'Get alerts when GPS signal is lost, battery is low, '
          'or a friend starts recording at your resort.',
    ),
    _PermStep(
      icon: Icons.battery_charging_full,
      color: Color(0xFFFFCA28),
      title: 'Battery Unrestricted',
      subtitle: 'Recommended',
      description:
          'GPS drains battery, especially in the cold. '
          'Disabling battery optimization prevents Android from killing the app mid-run.',
    ),
    _PermStep(
      icon: Icons.directions_run,
      color: Color(0xFFAB47BC),
      title: 'Motion & Activity',
      subtitle: 'Recommended',
      description:
          'Detects when you\'ve stopped moving so the app can sleep the GPS '
          'and save battery between runs.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkCurrentPermissions();
  }

  Future<void> _checkCurrentPermissions() async {
    if (kIsWeb) return;

    final locPerm = await Geolocator.checkPermission();
    final notifStatus = await ph.Permission.notification.status;
    final activityStatus = await ph.Permission.activityRecognition.status;
    final batteryExempt =
        await ph.Permission.ignoreBatteryOptimizations.isGranted;

    setState(() {
      _locationGranted = locPerm == LocationPermission.whileInUse ||
          locPerm == LocationPermission.always;
      _backgroundGranted = locPerm == LocationPermission.always;
      _notificationGranted = notifStatus.isGranted;
      _batteryExempt = batteryExempt;
      _activityGranted = activityStatus.isGranted;
    });
  }

  Future<void> _handleGrant() async {
    switch (_step) {
      case 0: // Location
        final perm = await Geolocator.requestPermission();
        setState(() {
          _locationGranted = perm == LocationPermission.whileInUse ||
              perm == LocationPermission.always;
          _backgroundGranted = perm == LocationPermission.always;
        });
        break;

      case 1: // Background location
        if (_backgroundGranted) break;
        // On Android 11+, must open app settings for "Always Allow"
        if (!kIsWeb && Platform.isAndroid) {
          await Geolocator.openAppSettings();
          // Re-check after user returns
          await Future.delayed(const Duration(seconds: 1));
          final perm = await Geolocator.checkPermission();
          setState(() {
            _backgroundGranted = perm == LocationPermission.always;
          });
        } else {
          final perm = await Geolocator.requestPermission();
          setState(() {
            _backgroundGranted = perm == LocationPermission.always;
          });
        }
        break;

      case 2: // Notifications
        final status = await ph.Permission.notification.request();
        setState(() => _notificationGranted = status.isGranted);
        break;

      case 3: // Battery
        final status = await ph.Permission.ignoreBatteryOptimizations.request();
        setState(() => _batteryExempt = status.isGranted);
        break;

      case 4: // Activity recognition
        final status = await ph.Permission.activityRecognition.request();
        setState(() => _activityGranted = status.isGranted);
        break;
    }

    _nextStep();
  }

  void _nextStep() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      Navigator.pop(context, true);
    }
  }

  bool _isCurrentStepGranted() {
    switch (_step) {
      case 0:
        return _locationGranted;
      case 1:
        return _backgroundGranted;
      case 2:
        return _notificationGranted;
      case 3:
        return _batteryExempt;
      case 4:
        return _activityGranted;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final step = _steps[_step];
    final granted = _isCurrentStepGranted();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Progress dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (i) {
                  return Container(
                    width: i == _step ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i <= _step
                          ? step.color
                          : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),

              const Spacer(flex: 2),

              // Icon
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step.color.withValues(alpha: 0.15),
                ),
                child: Icon(step.icon, size: 56, color: step.color),
              ),
              const SizedBox(height: 28),

              // Title
              Text(
                step.title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: step.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  step.subtitle,
                  style: TextStyle(
                    color: step.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Description
              Text(
                step.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              // Status
              if (granted) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: step.color, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Already granted',
                      style: TextStyle(color: step.color, fontSize: 14),
                    ),
                  ],
                ),
              ],

              const Spacer(flex: 3),

              // Grant button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: granted ? _nextStep : _handleGrant,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: step.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    granted ? 'Continue' : 'Grant Permission',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Skip
              TextButton(
                onPressed: _nextStep,
                child: Text(
                  _step < _steps.length - 1 ? 'Skip' : 'Done',
                  style: const TextStyle(color: Colors.white30, fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermStep {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String description;

  const _PermStep({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}
