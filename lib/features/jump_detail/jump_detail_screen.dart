import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../core/database/database.dart';
import '../../core/models/trick.dart';
import '../media/hero_image_screen.dart';
import '../session/widgets/trick_picker_sheet.dart';
import 'jump_detail_providers.dart';

class JumpDetailScreen extends ConsumerWidget {
  final String jumpId;
  const JumpDetailScreen({super.key, required this.jumpId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jumpAsync = ref.watch(jumpDetailProvider(jumpId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: jumpAsync.when(
        data: (jump) {
          if (jump == null) {
            return const Center(
                child: Text('Jump not found',
                    style: TextStyle(color: Colors.white30)));
          }
          final score = (jump.airtimeMs / 100) * 40 +
              jump.heightM * 30 +
              jump.distanceM * 10;

          return CustomScrollView(
            slivers: [
              // Hero header
              SliverAppBar(
                pinned: true,
                expandedHeight: 200,
                backgroundColor: theme.colorScheme.surface,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share, size: 22),
                    tooltip: 'Share Hero Image',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HeroImageScreen(jump: jump),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.25),
                          theme.colorScheme.surface,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 24),
                          Text(
                            '${jump.airtimeMs}ms',
                            style: const TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star_rounded,
                                  color: theme.colorScheme.secondary, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                'Score: ${score.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Metrics grid
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.4,
                  ),
                  delegate: SliverChildListDelegate([
                    _MetricTile(
                        'Airtime', '${jump.airtimeMs}ms',
                        icon: Icons.timer),
                    _MetricTile(
                        'Height', '${jump.heightM.toStringAsFixed(1)}m',
                        icon: Icons.height),
                    _MetricTile(
                        'Distance', '${jump.distanceM.toStringAsFixed(1)}m',
                        icon: Icons.straighten),
                    _MetricTile(
                        'Speed', '${jump.speedKmh.toStringAsFixed(1)} km/h',
                        icon: Icons.speed),
                    _MetricTile('Landing G',
                        '${jump.landingGForce.toStringAsFixed(1)}G',
                        icon: Icons.downloading),
                    _MetricTile('Score', score.toStringAsFixed(0),
                        icon: Icons.emoji_events,
                        valueColor: theme.colorScheme.secondary),
                  ]),
                ),
              ),

              // Tricks section
              SliverToBoxAdapter(
                child: _TricksSection(jump: jump, jumpId: jumpId, ref: ref),
              ),

              // Trajectory chart
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _TrajectoryChart(jump: jump),
                ),
              ),

              // Map with takeoff/landing
              if (jump.latTakeoff != null && jump.latLanding != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _JumpMap(jump: jump),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _MetricTile(this.label, this.value,
      {required this.icon, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.white38),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Colors.white38)),
        ],
      ),
    );
  }
}

class _TrajectoryChart extends StatelessWidget {
  final Jump jump;
  const _TrajectoryChart({required this.jump});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final airtimeS = jump.airtimeMs / 1000;
    final peakHeight = jump.heightM;

    // Generate parabolic trajectory: h(t) = 4*H/T^2 * t * (T - t)
    final points = <FlSpot>[];
    const n = 30;
    for (var i = 0; i <= n; i++) {
      final t = (airtimeS / n) * i;
      final h = 4 * peakHeight / (airtimeS * airtimeS) * t * (airtimeS - t);
      points.add(FlSpot(t, math.max(0, h)));
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRAJECTORY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white54,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval:
                      peakHeight > 0 ? peakHeight / 3 : 1,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.white.withValues(alpha: 0.08),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toStringAsFixed(1)}m',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toStringAsFixed(1)}s',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 10),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                lineBarsData: [
                  LineChartBarData(
                    spots: points,
                    isCurved: true,
                    color: theme.colorScheme.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots
                        .map((spot) => LineTooltipItem(
                              '${spot.y.toStringAsFixed(1)}m',
                              TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TricksSection extends StatelessWidget {
  final Jump jump;
  final String jumpId;
  final WidgetRef ref;

  const _TricksSection({
    required this.jump,
    required this.jumpId,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tricks = parseTrickLabel(jump.trickLabel);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'TRICKS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white54,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    final result = await showTrickPicker(
                      context,
                      currentLabel: jump.trickLabel,
                    );
                    if (result == null && jump.trickLabel != null) return;
                    await ref
                        .read(jumpRepositoryProvider)
                        .updateJumpTricks(jumpId, result);
                    // Invalidate to refresh the screen
                    ref.invalidate(jumpDetailProvider(jumpId));
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, color: Color(0xFF4FC3F7), size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: Color(0xFF4FC3F7),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (tricks.isEmpty)
              const Text(
                'No tricks labeled',
                style: TextStyle(color: Colors.white30, fontSize: 13),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: tricks.map((name) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4FC3F7).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF4FC3F7).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Color(0xFF4FC3F7),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _JumpMap extends StatelessWidget {
  final Jump jump;
  const _JumpMap({required this.jump});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final takeoff = LatLng(jump.latTakeoff!, jump.lonTakeoff!);
    final landing = LatLng(jump.latLanding!, jump.lonLanding!);
    final center = LatLng(
      (takeoff.latitude + landing.latitude) / 2,
      (takeoff.longitude + landing.longitude) / 2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'MAP',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white54,
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surface,
          ),
          clipBehavior: Clip.antiAlias,
          child: FlutterMap(
            options: MapOptions(initialCenter: center, initialZoom: 17),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.ski_tracker',
                tileProvider: CancellableNetworkTileProvider(),
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [takeoff, landing],
                    strokeWidth: 3,
                    color: theme.colorScheme.primary,
                    isDotted: true,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: takeoff,
                    width: 32,
                    height: 32,
                    child: Icon(Icons.flight_takeoff,
                        color: theme.colorScheme.primary, size: 24),
                  ),
                  Marker(
                    point: landing,
                    width: 32,
                    height: 32,
                    child: Icon(Icons.flight_land,
                        color: theme.colorScheme.secondary, size: 24),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
