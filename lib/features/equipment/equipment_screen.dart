import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/equipment.dart';
import 'equipment_providers.dart';

class EquipmentScreen extends ConsumerStatefulWidget {
  const EquipmentScreen({super.key});

  @override
  ConsumerState<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends ConsumerState<EquipmentScreen> {
  bool _profilePromptShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showProfilePromptIfNeeded();
    });
  }

  void _showProfilePromptIfNeeded() {
    final notifier = ref.read(equipmentProvider.notifier);
    if (!notifier.isProfileSetupDone && !_profilePromptShown) {
      _profilePromptShown = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Backcountry Skiing Profile',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'We have a preconfigured equipment set for backcountry skiing.\n\nDoes that suit your profile?',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                notifier.declineProfile();
                Navigator.of(ctx).pop();
              },
              child: const Text(
                'No, start empty',
                style: TextStyle(color: Colors.white38),
              ),
            ),
            FilledButton(
              onPressed: () {
                notifier.acceptBackcountryProfile();
                Navigator.of(ctx).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3F7),
              ),
              child: const Text(
                'Yes, load it',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(equipmentProvider);
    final notifier = ref.read(equipmentProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'My Equipment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          _SummaryCard(notifier: notifier),
          ...EquipmentZone.values.map((zone) {
            final items = EquipmentCatalog.byZone(zone);
            if (items.isEmpty) return const SizedBox.shrink();
            return _ZoneSection(zone: zone, items: items);
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary
// ---------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  final EquipmentNotifier notifier;

  const _SummaryCard({required this.notifier});

  @override
  Widget build(BuildContext context) {
    final owned = notifier.ownedCount;
    final total = notifier.totalCount;
    final pct = total > 0 ? owned / total : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Gear Checklist',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '$owned / $total items',
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Zone section
// ---------------------------------------------------------------------------

class _ZoneSection extends ConsumerStatefulWidget {
  final EquipmentZone zone;
  final List<Equipment> items;

  const _ZoneSection({required this.zone, required this.items});

  @override
  ConsumerState<_ZoneSection> createState() => _ZoneSectionState();
}

class _ZoneSectionState extends ConsumerState<_ZoneSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    ref.watch(equipmentProvider);

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text(
                  widget.zone.label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white54,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white38,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          ...widget.items.map((item) => _EquipmentTile(item: item)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Equipment tile — with why, detail, and shop URL
// ---------------------------------------------------------------------------

class _EquipmentTile extends ConsumerWidget {
  final Equipment item;

  const _EquipmentTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(equipmentProvider);
    final notifier = ref.read(equipmentProvider.notifier);
    final owned = notifier.isOwned(item.id);
    final typeColor = Color(item.type.colorValue);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: owned
              ? typeColor.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Text(item.icon, style: const TextStyle(fontSize: 22)),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: owned ? Colors.white : Colors.white54,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: typeColor.withValues(alpha: 0.15),
                ),
                child: Text(
                  item.type.label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: typeColor,
                  ),
                ),
              ),
            ],
          ),
          trailing: GestureDetector(
            onTap: () => notifier.toggleOwned(item.id),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: owned
                    ? const Color(0xFF81C784).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.06),
              ),
              child: Icon(
                owned ? Icons.check_circle : Icons.circle_outlined,
                color: owned
                    ? const Color(0xFF81C784)
                    : Colors.white30,
                size: 22,
              ),
            ),
          ),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 12),
          children: [
            if (item.why.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Why: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4FC3F7),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.why,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4FC3F7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (item.detail.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.detail,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ],
              ),
            if (!owned)
              _ShopUrlSection(itemId: item.id),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shop URL section — shown for unowned items
// ---------------------------------------------------------------------------

class _ShopUrlSection extends ConsumerWidget {
  final String itemId;

  const _ShopUrlSection({required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(equipmentProvider.notifier);
    final url = notifier.shopUrl(itemId);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          if (url != null && url.isNotEmpty) ...[
            Expanded(
              child: GestureDetector(
                onTap: () => _openUrl(url),
                child: Text(
                  url,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4FC3F7),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFF4FC3F7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showUrlDialog(context, notifier, itemId, url),
              child: const Icon(Icons.edit, size: 16, color: Colors.white38),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => notifier.setShopUrl(itemId, null),
              child: const Icon(Icons.close, size: 16, color: Colors.white38),
            ),
          ] else
            GestureDetector(
              onTap: () => _showUrlDialog(context, notifier, itemId, null),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_link, size: 14, color: Colors.white30),
                  SizedBox(width: 4),
                  Text(
                    'Add shop link',
                    style: TextStyle(fontSize: 11, color: Colors.white30),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showUrlDialog(
    BuildContext context,
    EquipmentNotifier notifier,
    String itemId,
    String? currentUrl,
  ) {
    final controller = TextEditingController(text: currentUrl ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Shop Link',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'https://...',
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              notifier.setShopUrl(itemId, value.isEmpty ? null : value);
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF4FC3F7)),
            child: const Text('Save', style: TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
