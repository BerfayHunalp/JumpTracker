import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/models/trick.dart';
import 'widgets/trick_picker_sheet.dart';

/// Screen shown after a session ends, letting the user label each jump with tricks.
class LabelJumpsScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const LabelJumpsScreen({super.key, required this.sessionId});

  @override
  ConsumerState<LabelJumpsScreen> createState() => _LabelJumpsScreenState();
}

class _LabelJumpsScreenState extends ConsumerState<LabelJumpsScreen> {
  List<Jump>? _jumps;
  // Track trick labels locally (jumpId -> label)
  final Map<String, String?> _labels = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadJumps();
  }

  Future<void> _loadJumps() async {
    final repo = ref.read(jumpRepositoryProvider);
    final jumps = await repo.getJumpsForSession(widget.sessionId);
    setState(() {
      _jumps = jumps;
      for (final j in jumps) {
        _labels[j.id] = j.trickLabel;
      }
      _loading = false;
    });
  }

  Future<void> _pickTricks(Jump jump) async {
    final result = await showTrickPicker(
      context,
      currentLabel: _labels[jump.id],
    );
    // result is null if user dismissed without applying
    if (result == null && _labels[jump.id] != null) return;

    setState(() => _labels[jump.id] = result);
    // Persist immediately
    await ref.read(jumpRepositoryProvider).updateJumpTricks(jump.id, result);
  }

  Future<void> _done() async {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Label Your Jumps'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _done,
            child: const Text(
              'Done',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _jumps == null || _jumps!.isEmpty
              ? const Center(
                  child: Text(
                    'No jumps recorded',
                    style: TextStyle(color: Colors.white30),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _jumps!.length,
                  itemBuilder: (context, index) {
                    final jump = _jumps![index];
                    return _JumpLabelTile(
                      jump: jump,
                      number: index + 1,
                      trickLabel: _labels[jump.id],
                      onTap: () => _pickTricks(jump),
                    );
                  },
                ),
    );
  }
}

class _JumpLabelTile extends StatelessWidget {
  final Jump jump;
  final int number;
  final String? trickLabel;
  final VoidCallback onTap;

  const _JumpLabelTile({
    required this.jump,
    required this.number,
    required this.trickLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tricks = parseTrickLabel(trickLabel);
    final score =
        (jump.airtimeMs / 100) * 40 + jump.heightM * 30 + jump.distanceM * 10;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: number + metrics
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF4FC3F7).withValues(alpha: 0.2),
                    ),
                    child: Center(
                      child: Text(
                        '$number',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4FC3F7),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${jump.airtimeMs}ms',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${jump.heightM.toStringAsFixed(1)}m',
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${score.toStringAsFixed(0)} pts',
                    style: const TextStyle(
                      color: Color(0xFFFF7043),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Trick chips area
              if (tricks.isEmpty)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline,
                          color: Colors.white30, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Tap to add tricks',
                        style: TextStyle(color: Colors.white30, fontSize: 13),
                      ),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: tricks.map((name) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4FC3F7).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              const Color(0xFF4FC3F7).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Color(0xFF4FC3F7),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
