import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/database/database.dart';

/// Generates a shareable "Hero Image" card with jump stats overlaid on
/// a gradient background. User can share it via the native share sheet.
class HeroImageScreen extends StatefulWidget {
  final Jump jump;

  const HeroImageScreen({super.key, required this.jump});

  @override
  State<HeroImageScreen> createState() => _HeroImageScreenState();
}

class _HeroImageScreenState extends State<HeroImageScreen> {
  final _repaintKey = GlobalKey();
  bool _sharing = false;

  Future<void> _shareImage() async {
    setState(() => _sharing = true);
    try {
      final boundary = _repaintKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      await Share.shareXFiles(
        [XFile.fromData(bytes, mimeType: 'image/png', name: 'jump_hero.png')],
        text: 'Check out my jump! #JumpTracker',
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jump = widget.jump;
    final score = (jump.airtimeMs / 100) * 40 + jump.heightM * 30 + jump.distanceM * 10;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Hero Image'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: _sharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share),
            onPressed: _sharing ? null : _shareImage,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // The capturable card
            RepaintBoundary(
              key: _repaintKey,
              child: _HeroCard(jump: jump, score: score),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _sharing ? null : _shareImage,
                icon: const Icon(Icons.share),
                label: const Text('Share Hero Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FC3F7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Jump jump;
  final double score;

  const _HeroCard({
    required this.jump,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B2A4A),
            Color(0xFF4A1A6B),
            Color(0xFF1B2A4A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4FC3F7).withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Airtime hero number
          Text(
            '${jump.airtimeMs}ms',
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -2,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'AIRTIME',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white38,
              letterSpacing: 3,
            ),
          ),

          const SizedBox(height: 20),

          // Stats grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatColumn('Height', '${jump.heightM.toStringAsFixed(1)}m'),
              _StatColumn('Distance', '${jump.distanceM.toStringAsFixed(1)}m'),
              _StatColumn('Speed', '${jump.speedKmh.toStringAsFixed(0)} km/h'),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatColumn('G-Force', '${jump.landingGForce.toStringAsFixed(1)}G'),
              _StatColumn('Score', score.toStringAsFixed(0), highlight: true),
            ],
          ),

          // Trick label
          if (jump.trickLabel != null && jump.trickLabel!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3F7).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF4FC3F7).withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                jump.trickLabel!,
                style: const TextStyle(
                  color: Color(0xFF4FC3F7),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Branding
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flight_takeoff,
                  color: Colors.white.withValues(alpha: 0.3), size: 16),
              const SizedBox(width: 6),
              Text(
                'JumpTracker',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _StatColumn(this.label, this.value, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: highlight ? const Color(0xFFFF7043) : Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white38,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
