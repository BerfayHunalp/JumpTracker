import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../core/database/database.dart';
import '../jump_detail/jump_detail_screen.dart';
import 'challenge_providers.dart';

class KingOfHillScreen extends ConsumerStatefulWidget {
  const KingOfHillScreen({super.key});

  @override
  ConsumerState<KingOfHillScreen> createState() => _KingOfHillScreenState();
}

class _KingOfHillScreenState extends ConsumerState<KingOfHillScreen> {
  bool _detecting = false;

  @override
  void initState() {
    super.initState();
    _autoDetect();
  }

  Future<void> _autoDetect() async {
    setState(() => _detecting = true);
    try {
      final jumpRepo = ref.read(jumpRepositoryProvider);
      final allJumps = await jumpRepo.getAllJumpsChronological();
      await ref.read(jumpZonesProvider.notifier).detectZones(allJumps);
    } finally {
      if (mounted) setState(() => _detecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final zones = ref.watch(jumpZonesProvider);
    final jumpsAsync = ref.watch(_allJumpsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            title: const Text('King of the Hill'),
            actions: [
              if (_detecting)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _autoDetect,
                  tooltip: 'Re-scan zones',
                ),
            ],
          ),

          // Map view with zone markers
          if (zones.isNotEmpty)
            SliverToBoxAdapter(
              child: _ZoneMap(zones: zones),
            ),

          // Zone list
          if (zones.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_off, color: Colors.white24, size: 48),
                      SizedBox(height: 12),
                      Text(
                        'No jump zones detected yet',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Jump at the same spot 3+ times with GPS enabled to auto-create a zone.',
                        style: TextStyle(color: Colors.white30, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            jumpsAsync.when(
              data: (allJumps) {
                final stats = zones
                    .map((z) => computeZoneStats(z, allJumps))
                    .toList()
                  ..sort((a, b) => b.jumpCount.compareTo(a.jumpCount));

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _ZoneTile(stats: stats[index], ref: ref),
                      childCount: stats.length,
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
        ],
      ),
    );
  }
}

final _allJumpsProvider = FutureProvider<List<Jump>>((ref) async {
  final repo = ref.read(jumpRepositoryProvider);
  return repo.getAllJumpsChronological();
});

class _ZoneMap extends StatelessWidget {
  final List<JumpZone> zones;
  const _ZoneMap({required this.zones});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final center = zones.isNotEmpty
        ? LatLng(
            zones.map((z) => z.latitude).reduce((a, b) => a + b) / zones.length,
            zones.map((z) => z.longitude).reduce((a, b) => a + b) /
                zones.length,
          )
        : const LatLng(44.19, 7.16);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surface,
        ),
        clipBehavior: Clip.antiAlias,
        child: FlutterMap(
          options: MapOptions(initialCenter: center, initialZoom: 15),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.ski_tracker',
              tileProvider: CancellableNetworkTileProvider(),
            ),
            MarkerLayer(
              markers: zones.map((zone) {
                return Marker(
                  point: LatLng(zone.latitude, zone.longitude),
                  width: 40,
                  height: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7043).withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.flag, color: Colors.white, size: 18),
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

class _ZoneTile extends StatelessWidget {
  final ZoneStats stats;
  final WidgetRef ref;

  const _ZoneTile({required this.stats, required this.ref});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final zone = stats.zone;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFF7043).withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Zone header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7043).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.flag, color: Color(0xFFFF7043), size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onLongPress: () => _renameZone(context, zone),
                        child: Text(
                          zone.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        '${stats.jumpCount} jumps',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (stats.todayBest != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4FC3F7).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'TODAY: ${jumpScore(stats.todayBest!).toStringAsFixed(0)} pts',
                      style: const TextStyle(
                        color: Color(0xFF4FC3F7),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            // Best jump
            if (stats.bestJump != null) ...[
              const SizedBox(height: 10),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        JumpDetailScreen(jumpId: stats.bestJump!.id),
                  ),
                ),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events,
                          color: Color(0xFFFFCA28), size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'All-Time Best:',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        '${stats.bestJump!.airtimeMs}ms',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${jumpScore(stats.bestJump!).toStringAsFixed(0)} pts',
                        style: const TextStyle(
                          color: Color(0xFFFF7043),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right,
                          color: Colors.white24, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _renameZone(BuildContext context, JumpZone zone) {
    final controller = TextEditingController(text: zone.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Rename Zone',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Zone name',
            hintStyle: TextStyle(color: Colors.white30),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(jumpZonesProvider.notifier).renameZone(
                    zone.id, controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
