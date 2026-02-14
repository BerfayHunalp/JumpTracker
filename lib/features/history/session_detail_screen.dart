import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../../core/database/database.dart';
import '../../core/models/trick.dart';
import '../../shared/widgets/stat_card.dart';
import '../jump_detail/jump_detail_screen.dart';
import '../media/video_cut_screen.dart';
import '../weather/weather_widget.dart';
import 'history_providers.dart';

class SessionDetailScreen extends ConsumerWidget {
  final String sessionId;
  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionDetailProvider(sessionId));
    final jumpsAsync = ref.watch(sessionJumpsProvider(sessionId));
    final gpsAsync = ref.watch(sessionGpsProvider(sessionId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: sessionAsync.when(
              data: (s) => Text(
                s != null
                    ? DateFormat('MMM d, yyyy').format(s.startedAt)
                    : 'Session',
              ),
              loading: () => const Text('Loading...'),
              error: (_, __) => const Text('Session'),
            ),
          ),

          // Stats row
          sessionAsync.when(
            data: (s) {
              if (s == null) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              final duration = s.endedAt?.difference(s.startedAt);
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.flight_takeoff,
                          value: '${s.totalJumps}',
                          label: 'Jumps',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          icon: Icons.timer,
                          value: duration != null
                              ? _fmtDuration(duration)
                              : '-',
                          label: 'Duration',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          icon: Icons.trending_up,
                          value: s.maxAirtimeMs > 0
                              ? '${s.maxAirtimeMs.toInt()}ms'
                              : '-',
                          label: 'Max Air',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // Weather snapshot
          gpsAsync.when(
            data: (points) {
              if (points.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: WeatherWidget(),
                  ),
                );
              }
              // Use first GPS point for weather location
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: WeatherWidget(
                    latitude: points.first.latitude,
                    longitude: points.first.longitude,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // Auto-Cut Video button
          jumpsAsync.when(
            data: (jumps) {
              if (jumps.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: sessionAsync.when(
                    data: (s) => s == null
                        ? const SizedBox.shrink()
                        : OutlinedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VideoCutScreen(
                                  sessionStart: s.startedAt,
                                  jumps: jumps,
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.content_cut, size: 18),
                            label: Text('Auto-Cut Video (${jumps.length} jumps)'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4FC3F7),
                              side: const BorderSide(color: Color(0xFF4FC3F7)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // GPS map
          gpsAsync.when(
            data: (points) {
              if (points.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverToBoxAdapter(child: _GpsMap(points: points));
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // Jump list header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: jumpsAsync.when(
                data: (jumps) => Text(
                  'JUMPS (${jumps.length})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white54,
                    letterSpacing: 1,
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ),

          // Jump list
          jumpsAsync.when(
            data: (jumps) {
              if (jumps.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text('No jumps in this session',
                          style: TextStyle(color: Colors.white30)),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final jump = jumps[index];
                      return _JumpTile(
                        jump: jump,
                        number: index + 1,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                JumpDetailScreen(jumpId: jump.id),
                          ),
                        ),
                      );
                    },
                    childCount: jumps.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  static String _fmtDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }
}

class _GpsMap extends StatelessWidget {
  final List<GpsPoint> points;
  const _GpsMap({required this.points});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final latLngs =
        points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    final center = LatLng(
      latLngs.map((l) => l.latitude).reduce((a, b) => a + b) / latLngs.length,
      latLngs.map((l) => l.longitude).reduce((a, b) => a + b) /
          latLngs.length,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surface,
        ),
        clipBehavior: Clip.antiAlias,
        child: FlutterMap(
          options: MapOptions(initialCenter: center, initialZoom: 14),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.ski_tracker',
              tileProvider: CancellableNetworkTileProvider(),
            ),
            if (latLngs.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: latLngs,
                    strokeWidth: 3,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _JumpTile extends StatelessWidget {
  final Jump jump;
  final int number;
  final VoidCallback onTap;

  const _JumpTile({
    required this.jump,
    required this.number,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final score =
        (jump.airtimeMs / 100) * 40 + jump.heightM * 30 + jump.distanceM * 10;
    final tricks = parseTrickLabel(jump.trickLabel);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF4FC3F7).withValues(alpha: 0.2),
                    ),
                    child: Center(
                      child: Text(
                        '$number',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4FC3F7),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${jump.airtimeMs}ms',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  Text('${jump.heightM.toStringAsFixed(1)}m',
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 13)),
                  const SizedBox(width: 16),
                  Text('${jump.distanceM.toStringAsFixed(1)}m',
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 13)),
                  const SizedBox(width: 16),
                  Text(
                    '${score.toStringAsFixed(0)} pts',
                    style: const TextStyle(
                      color: Color(0xFFFF7043),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right,
                      color: Colors.white24, size: 18),
                ],
              ),
              if (tricks.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: tricks.map((name) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4FC3F7).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Color(0xFF4FC3F7),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
