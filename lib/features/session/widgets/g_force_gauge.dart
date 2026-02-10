import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/session_providers.dart';

class GForceGauge extends ConsumerWidget {
  const GForceGauge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gForce = ref.watch(currentGForceProvider);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 150,
            height: 90,
            child: CustomPaint(
              painter: _GaugePainter(gForce: gForce.clamp(0, 4)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${gForce.toStringAsFixed(2)} G',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _gForceColor(gForce),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'G-Force',
            style: TextStyle(fontSize: 12, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

Color _gForceColor(double g) {
  if (g < 0.2) return const Color(0xFFFF1744); // freefall - bright red
  if (g < 0.8) return const Color(0xFFFFEB3B); // low-G - yellow
  if (g < 1.3) return const Color(0xFF66BB6A); // normal - green
  if (g < 2.0) return const Color(0xFFFF9800); // moderate impact - orange
  return const Color(0xFFFF1744); // heavy impact - red
}

class _GaugePainter extends CustomPainter {
  final double gForce;
  _GaugePainter({required this.gForce});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 4);
    final radius = size.width / 2 - 10;

    // Draw arc background segments
    const startAngle = math.pi; // 180 degrees (left)
    const sweepTotal = math.pi; // 180 degrees sweep

    // Color zones on the arc
    final zones = [
      (0.0, 0.05, const Color(0xFFFF1744)), // 0-0.2G freefall
      (0.05, 0.2, const Color(0xFFFFEB3B)),  // 0.2-0.8G low-G
      (0.2, 0.325, const Color(0xFF66BB6A)), // 0.8-1.3G normal
      (0.325, 0.5, const Color(0xFFFF9800)), // 1.3-2.0G moderate
      (0.5, 1.0, const Color(0xFFFF1744)),   // 2.0-4.0G heavy
    ];

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    for (final (start, end, color) in zones) {
      arcPaint.color = color.withValues(alpha: 0.3);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + start * sweepTotal,
        (end - start) * sweepTotal,
        false,
        arcPaint,
      );
    }

    // Draw needle
    final normalizedG = (gForce / 4.0).clamp(0.0, 1.0);
    final needleAngle = startAngle + normalizedG * sweepTotal;
    final needleEnd = Offset(
      center.dx + (radius - 15) * math.cos(needleAngle),
      center.dy + (radius - 15) * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = _gForceColor(gForce)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);

    // Center dot
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.gForce != gForce;
}
