import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final int avatarIndex;
  final double size;

  const AvatarWidget({
    super.key,
    required this.avatarIndex,
    this.size = 56,
  });

  static const _icons = [
    Icons.downhill_skiing,
    Icons.snowboarding,
    Icons.ac_unit,
    Icons.terrain,
    Icons.landscape,
    Icons.flight_takeoff,
    Icons.emoji_events,
    Icons.star,
    Icons.flash_on,
    Icons.rocket_launch,
    Icons.pets,
    Icons.forest,
    Icons.waves,
    Icons.sports,
    Icons.sports_score,
    Icons.military_tech,
  ];

  static const _colors = [
    Color(0xFF4FC3F7), // light blue
    Color(0xFFFF7043), // deep orange
    Color(0xFF66BB6A), // green
    Color(0xFFAB47BC), // purple
    Color(0xFFFFCA28), // amber
    Color(0xFFEF5350), // red
  ];

  @override
  Widget build(BuildContext context) {
    final iconIndex = avatarIndex % _icons.length;
    final colorIndex = (avatarIndex ~/ _icons.length) % _colors.length;
    final color = _colors[colorIndex];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
      ),
      child: Icon(
        _icons[iconIndex],
        size: size * 0.5,
        color: color,
      ),
    );
  }

  /// Total number of avatar combinations (icons * colors).
  static int get totalAvatars => _icons.length * _colors.length;
}
