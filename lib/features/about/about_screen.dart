import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('About', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SectionCard(
            title: 'How Jumps Are Measured',
            icon: Icons.precision_manufacturing,
            color: Color(0xFF4FC3F7),
            children: [
              _InfoRow(
                label: 'Airtime',
                text:
                    'Your phone\'s accelerometer runs at ~100 Hz. When it detects near-zero gravity (freefall), the clock starts. When a high-G landing spike is detected, the clock stops. That interval is your airtime in milliseconds.',
              ),
              SizedBox(height: 12),
              _InfoRow(
                label: 'Height',
                text:
                    'Calculated from airtime using physics: h = 0.5 \u00D7 g \u00D7 (t/2)\u00B2. Since you go up then come down, we use half the airtime as the rise duration and solve for peak altitude above takeoff.',
              ),
              SizedBox(height: 12),
              _InfoRow(
                label: 'Distance',
                text:
                    'Primary method: GPS takeoff speed \u00D7 airtime. GPS can\'t update mid-air (jumps are 0.3\u20133 s), so speed \u00D7 time is more accurate than two stale GPS fixes. If both GPS endpoints exist, they\'re cross-validated.',
              ),
              SizedBox(height: 12),
              _InfoRow(
                label: 'Speed',
                text:
                    'Taken from GPS at the moment of takeoff and converted from m/s to km/h. A Kalman filter smooths noisy GPS samples before the value is captured.',
              ),
              SizedBox(height: 12),
              _InfoRow(
                label: 'G-Force',
                text:
                    'Magnitude of the 3-axis accelerometer vector divided by gravity: G = \u221A(x\u00B2 + y\u00B2 + z\u00B2) / 9.81. The peak value during the 150 ms landing window is recorded.',
              ),
              SizedBox(height: 12),
              _InfoRow(
                label: 'Score',
                text:
                    'Base = (airtime/100)\u00D740 + height\u00D730 + distance\u00D710. The base is then multiplied by the trick multiplier (1.0\u00D7 for straight air up to 4.0\u00D7+ for complex tricks).',
              ),
            ],
          ),
          SizedBox(height: 16),
          _SectionCard(
            title: 'Why We Need Each Permission',
            icon: Icons.shield_outlined,
            color: Color(0xFF81C784),
            children: [
              _PermissionRow(
                permission: 'Precise Location (GPS)',
                reason:
                    'Measures your takeoff speed, jump distance, and maps your session route on the map. Without GPS the app can only measure airtime.',
              ),
              SizedBox(height: 12),
              _PermissionRow(
                permission: 'Background Location',
                reason:
                    'Keeps GPS running when your phone is locked in your pocket during a ski run. Without this, location stops the moment the screen turns off.',
              ),
              SizedBox(height: 12),
              _PermissionRow(
                permission: 'Motion & Activity',
                reason:
                    'Detects when you\'ve stopped moving so the app can pause GPS polling and save battery while you\'re on the chairlift or having lunch.',
              ),
              SizedBox(height: 12),
              _PermissionRow(
                permission: 'Notifications',
                reason:
                    'Alerts you when GPS signal is lost mid-session, when battery is critically low, and for friend activity updates.',
              ),
              SizedBox(height: 12),
              _PermissionRow(
                permission: 'Battery Optimization Exempt',
                reason:
                    'Prevents Android from killing the app in the background during a long ski day. Without this, your session can be silently stopped after ~15 minutes.',
              ),
            ],
          ),
          SizedBox(height: 16),
          _SectionCard(
            title: 'Sensors Used',
            icon: Icons.sensors,
            color: Color(0xFFFFCA28),
            children: [
              _InfoRow(
                label: 'Accelerometer',
                text:
                    '3-axis, sampled every 10 ms (~100 Hz). Detects freefall (low-G) for takeoff and high-G spikes for landing.',
              ),
              SizedBox(height: 12),
              _InfoRow(
                label: 'GPS',
                text:
                    'Position, altitude, speed, bearing, and accuracy. Updated every ~500 ms. Filtered with a Kalman filter to reduce noise.',
              ),
            ],
          ),
          SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section card
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info row (label + description)
// ---------------------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  final String label;
  final String text;

  const _InfoRow({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4FC3F7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.white54, height: 1.5),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Permission row
// ---------------------------------------------------------------------------

class _PermissionRow extends StatelessWidget {
  final String permission;
  final String reason;

  const _PermissionRow({required this.permission, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.check_circle, color: Color(0xFF81C784), size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                permission,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                reason,
                style: const TextStyle(
                    fontSize: 12, color: Colors.white54, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
