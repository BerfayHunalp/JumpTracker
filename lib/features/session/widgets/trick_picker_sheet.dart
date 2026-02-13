import 'package:flutter/material.dart';
import '../../../core/models/trick.dart';

/// Modal bottom sheet for selecting tricks/spins for a jump.
/// Returns the updated comma-separated trick label string, or null if cancelled.
class TrickPickerSheet extends StatefulWidget {
  final String? initialLabel;

  const TrickPickerSheet({super.key, this.initialLabel});

  @override
  State<TrickPickerSheet> createState() => _TrickPickerSheetState();
}

class _TrickPickerSheetState extends State<TrickPickerSheet> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = parseTrickLabel(widget.initialLabel).toSet();
  }

  void _toggle(String name) {
    setState(() {
      if (_selected.contains(name)) {
        _selected.remove(name);
      } else {
        _selected.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header with selected count + apply button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selected.isEmpty
                            ? 'Select Tricks'
                            : '${_selected.length} selected',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _selected.clear()),
                      child: const Text('Clear'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        final label = _selected.isEmpty
                            ? null
                            : formatTrickLabel(_selected.toList());
                        Navigator.pop(context, label);
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ),

              // Selected chips preview
              if (_selected.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: _selected.map((name) {
                      return Chip(
                        label: Text(name, style: const TextStyle(fontSize: 12)),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => _toggle(name),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ),

              const Divider(height: 1, color: Colors.white12),

              // Category sections
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.only(bottom: 24),
                  children: TrickCatalog.allByLabelCategory.entries.map((entry) {
                    return _CategorySection(
                      title: entry.key,
                      tricks: entry.value,
                      selected: _selected,
                      onToggle: _toggle,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String title;
  final List<Trick> tricks;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _CategorySection({
    required this.title,
    required this.tricks,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white38,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tricks.map((trick) {
              final isSelected = selected.contains(trick.name);
              return FilterChip(
                label: Text(trick.name),
                selected: isSelected,
                onSelected: (_) => onToggle(trick.name),
                showCheckmark: false,
                selectedColor: Color(trick.category.colorValue).withValues(alpha: 0.3),
                backgroundColor: Colors.white.withValues(alpha: 0.06),
                side: BorderSide(
                  color: isSelected
                      ? Color(trick.category.colorValue)
                      : Colors.white12,
                ),
                labelStyle: TextStyle(
                  color: isSelected ? Color(trick.category.colorValue) : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Show the trick picker bottom sheet. Returns the new trick label or null.
Future<String?> showTrickPicker(BuildContext context, {String? currentLabel}) {
  return showModalBottomSheet<String?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TrickPickerSheet(initialLabel: currentLabel),
  );
}
