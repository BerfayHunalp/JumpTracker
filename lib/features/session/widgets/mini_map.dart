import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/session_providers.dart';

class MiniMap extends ConsumerStatefulWidget {
  const MiniMap({super.key});

  @override
  ConsumerState<MiniMap> createState() => _MiniMapState();
}

class _MiniMapState extends ConsumerState<MiniMap> {
  final _mapController = MapController();

  // Default center: Val Thorens
  static const _defaultCenter = LatLng(45.298, 6.580);

  @override
  Widget build(BuildContext context) {
    final track = ref.watch(gpsTrackProvider);
    final jumps = ref.watch(jumpListProvider);
    final theme = Theme.of(context);

    // Pan to latest position when track updates
    if (track.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _mapController.move(track.last, _mapController.camera.zoom);
        } catch (_) {
          // MapController not ready yet
        }
      });
    }

    // Jump markers (takeoff positions)
    final jumpMarkers = jumps
        .where((j) => j.latTakeoff != null && j.lonTakeoff != null)
        .map((j) => Marker(
              point: LatLng(j.latTakeoff!, j.lonTakeoff!),
              width: 24,
              height: 24,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFF7043),
                ),
                child: const Icon(Icons.flight, size: 14, color: Colors.white),
              ),
            ))
        .toList();

    // Current position marker
    if (track.isNotEmpty) {
      jumpMarkers.add(Marker(
        point: track.last,
        width: 16,
        height: 16,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF4FC3F7),
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 200,
          color: theme.colorScheme.surface,
          child: track.isEmpty
              ? const Center(
                  child: Text(
                    'GPS track will appear here',
                    style: TextStyle(color: Colors.white30),
                  ),
                )
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: track.isNotEmpty ? track.last : _defaultCenter,
                    initialZoom: 15,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.skitracker.app',
                    ),
                    if (track.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: track,
                            color: const Color(0xFF4FC3F7),
                            strokeWidth: 3,
                          ),
                        ],
                      ),
                    MarkerLayer(markers: jumpMarkers),
                  ],
                ),
        ),
      ),
    );
  }
}
