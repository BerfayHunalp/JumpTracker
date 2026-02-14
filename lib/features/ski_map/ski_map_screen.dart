import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import '../../core/database/database.dart';
import '../history/history_providers.dart';
import 'ski_map_models.dart';
import 'ski_map_providers.dart';

class SkiMapScreen extends ConsumerStatefulWidget {
  /// If non-null, overlay this session's GPS track and jumps.
  final String? sessionId;

  const SkiMapScreen({super.key, this.sessionId});

  @override
  ConsumerState<SkiMapScreen> createState() => _SkiMapScreenState();
}

class _SkiMapScreenState extends ConsumerState<SkiMapScreen> {
  bool _legendExpanded = false;

  static const _center = LatLng(44.187, 7.155);

  @override
  Widget build(BuildContext context) {
    final mapDataAsync = ref.watch(resortMapDataProvider);

    final gpsAsync = widget.sessionId != null
        ? ref.watch(sessionGpsProvider(widget.sessionId!))
        : null;
    final jumpsAsync = widget.sessionId != null
        ? ref.watch(sessionJumpsProvider(widget.sessionId!))
        : null;

    return Scaffold(
      body: Stack(
        children: [
          mapDataAsync.when(
            data: (mapData) => _buildMap(mapData, gpsAsync, jumpsAsync),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off,
                        size: 48, color: Colors.white24),
                    const SizedBox(height: 12),
                    Text('Failed to load map: $e',
                        style: const TextStyle(color: Colors.white38),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => ref.invalidate(resortMapDataProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: _CircleButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.pop(context),
            ),
          ),
          // Legend toggle
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: _CircleButton(
              icon: _legendExpanded ? Icons.close : Icons.layers,
              onTap: () => setState(() => _legendExpanded = !_legendExpanded),
            ),
          ),
          // Legend panel
          if (_legendExpanded)
            Positioned(
              top: MediaQuery.of(context).padding.top + 56,
              right: 8,
              child: _LegendPanel(hasSession: widget.sessionId != null),
            ),
          // Slope count badge
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 16,
            child: mapDataAsync.when(
              data: (d) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${d.slopes.length} slopes \u2022 ${d.lifts.length} lifts',
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(
    ResortMapData mapData,
    AsyncValue<List<GpsPoint>>? gpsAsync,
    AsyncValue<List<Jump>>? jumpsAsync,
  ) {
    // Slope polylines
    final slopePolylines = mapData.slopes.map((slope) {
      return Polyline(
        points: slope.points.map((p) => LatLng(p.lat, p.lon)).toList(),
        strokeWidth: 3.0,
        color: _difficultyColor(slope.difficulty),
      );
    }).toList();

    // Lift polylines (dashed gray)
    final liftPolylines = mapData.lifts.map((lift) {
      return Polyline(
        points: lift.points.map((p) => LatLng(p.lat, p.lon)).toList(),
        strokeWidth: 2.0,
        color: Colors.grey.shade400,
        isDotted: true,
      );
    }).toList();

    // Session GPS track
    final gpsPoints = gpsAsync?.valueOrNull ?? [];
    final gpsLatLngs =
        gpsPoints.map((p) => LatLng(p.latitude, p.longitude)).toList();

    // Jump markers
    final jumps = jumpsAsync?.valueOrNull ?? [];
    final jumpMarkers = jumps
        .where((j) => j.latTakeoff != null && j.lonTakeoff != null)
        .map((j) => Marker(
              point: LatLng(j.latTakeoff!, j.lonTakeoff!),
              width: 24,
              height: 24,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF7043),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(Icons.flight, size: 13, color: Colors.white),
              ),
            ))
        .toList();

    // Center on session track if available, otherwise resort center
    final mapCenter = gpsLatLngs.isNotEmpty
        ? LatLng(
            gpsLatLngs.map((l) => l.latitude).reduce((a, b) => a + b) /
                gpsLatLngs.length,
            gpsLatLngs.map((l) => l.longitude).reduce((a, b) => a + b) /
                gpsLatLngs.length,
          )
        : _center;

    return FlutterMap(
      options: MapOptions(
        initialCenter: mapCenter,
        initialZoom: 14,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.skitracker.app',
          tileProvider: CancellableNetworkTileProvider(),
        ),
        PolylineLayer(polylines: slopePolylines),
        PolylineLayer(polylines: liftPolylines),
        if (gpsLatLngs.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: gpsLatLngs,
                strokeWidth: 4,
                color: const Color(0xFF4FC3F7),
              ),
            ],
          ),
        if (jumpMarkers.isNotEmpty) MarkerLayer(markers: jumpMarkers),
      ],
    );
  }

  static Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'novice':
        return const Color(0xFF4CAF50);
      case 'easy':
        return const Color(0xFF2196F3);
      case 'intermediate':
        return const Color(0xFFF44336);
      case 'advanced':
      case 'expert':
        return const Color(0xFF424242);
      default:
        return const Color(0xFF2196F3);
    }
  }
}

// ---------------------------------------------------------------------------
// Circle button overlay
// ---------------------------------------------------------------------------

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Legend panel
// ---------------------------------------------------------------------------

class _LegendPanel extends StatelessWidget {
  final bool hasSession;
  const _LegendPanel({required this.hasSession});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'LEGEND',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          _legendLine(const Color(0xFF4CAF50), 'Green (Novice)'),
          _legendLine(const Color(0xFF2196F3), 'Blue (Easy)'),
          _legendLine(const Color(0xFFF44336), 'Red (Intermediate)'),
          _legendLine(const Color(0xFF424242), 'Black (Advanced)',
              border: true),
          const SizedBox(height: 6),
          _legendLine(Colors.grey, 'Ski Lift', dashed: true),
          if (hasSession) ...[
            _legendLine(const Color(0xFF4FC3F7), 'Your Track'),
            _legendDot(const Color(0xFFFF7043), 'Jump'),
          ],
        ],
      ),
    );
  }

  Widget _legendLine(Color color, String label,
      {bool dashed = false, bool border = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              border: border ? Border.all(color: Colors.white38) : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
          const SizedBox(width: 2),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
