import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/database/database.dart';
import 'history_providers.dart';
import 'session_detail_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionListProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('Sessions'),
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          sessionsAsync.when(
            data: (sessions) => sessions.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.downhill_skiing,
                              size: 48, color: Colors.white24),
                          SizedBox(height: 12),
                          Text(
                            'No sessions yet',
                            style:
                                TextStyle(color: Colors.white30, fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Start recording to track your jumps',
                            style:
                                TextStyle(color: Colors.white24, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _SessionCard(session: sessions[index]),
                        childCount: sessions.length,
                      ),
                    ),
                  ),
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

class _SessionCard extends StatelessWidget {
  final Session session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = session.endedAt?.difference(session.startedAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SessionDetailScreen(sessionId: session.id),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
                  Icon(Icons.calendar_today,
                      size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM d, yyyy – HH:mm')
                        .format(session.startedAt),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right,
                      color: Colors.white30, size: 20),
                ],
              ),
              if (session.resortName != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    session.resortName!,
                    style: TextStyle(
                        fontSize: 12, color: theme.colorScheme.primary),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _stat(Icons.flight_takeoff, '${session.totalJumps}', 'Jumps'),
                  const SizedBox(width: 20),
                  _stat(
                    Icons.timer,
                    duration != null ? _fmtDuration(duration) : '-',
                    'Duration',
                  ),
                  const SizedBox(width: 20),
                  _stat(
                    Icons.trending_up,
                    session.maxAirtimeMs > 0
                        ? '${session.maxAirtimeMs.toStringAsFixed(0)}ms'
                        : '-',
                    'Max Air',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white54),
        const SizedBox(width: 4),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 13)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.white38)),
      ],
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
