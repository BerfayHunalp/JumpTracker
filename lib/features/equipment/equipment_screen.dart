import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/equipment.dart';
import 'equipment_providers.dart';

// ---------------------------------------------------------------------------
// Filter enums
// ---------------------------------------------------------------------------

enum StatutFilter { tout, manque, jai, avecUrl, avecPrix }

enum PrixFilter { tout, p0_50, p50_150, p150_400, p400plus }

class EquipmentScreen extends ConsumerStatefulWidget {
  const EquipmentScreen({super.key});

  @override
  ConsumerState<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends ConsumerState<EquipmentScreen> {
  bool _profilePromptShown = false;

  // Filter state
  EquipmentType? _selectedType; // null = Tout
  EquipmentZone? _selectedZone; // null = Tout
  StatutFilter _selectedStatut = StatutFilter.tout;
  PrixFilter _selectedPrix = PrixFilter.tout;

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

  List<Equipment> _filteredItems(EquipmentNotifier notifier) {
    var items = EquipmentCatalog.all.toList();

    // Type filter
    if (_selectedType != null) {
      items = items.where((e) => e.type == _selectedType).toList();
    }

    // Zone filter
    if (_selectedZone != null) {
      items = items.where((e) => e.zone == _selectedZone).toList();
    }

    // Statut filter
    switch (_selectedStatut) {
      case StatutFilter.tout:
        break;
      case StatutFilter.manque:
        items = items.where((e) => !notifier.isOwned(e.id)).toList();
      case StatutFilter.jai:
        items = items.where((e) => notifier.isOwned(e.id)).toList();
      case StatutFilter.avecUrl:
        items = items.where((e) {
          final url = notifier.shopUrl(e.id);
          return url != null && url.isNotEmpty;
        }).toList();
      case StatutFilter.avecPrix:
        items = items.where((e) => notifier.price(e.id) != null).toList();
    }

    // Prix filter
    switch (_selectedPrix) {
      case PrixFilter.tout:
        break;
      case PrixFilter.p0_50:
        items = items.where((e) {
          final p = notifier.price(e.id);
          return p != null && p >= 0 && p <= 50;
        }).toList();
      case PrixFilter.p50_150:
        items = items.where((e) {
          final p = notifier.price(e.id);
          return p != null && p > 50 && p <= 150;
        }).toList();
      case PrixFilter.p150_400:
        items = items.where((e) {
          final p = notifier.price(e.id);
          return p != null && p > 150 && p <= 400;
        }).toList();
      case PrixFilter.p400plus:
        items = items.where((e) {
          final p = notifier.price(e.id);
          return p != null && p > 400;
        }).toList();
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(equipmentProvider);
    final notifier = ref.read(equipmentProvider.notifier);
    final filtered = _filteredItems(notifier);

    // Group filtered items by zone for display
    final groupedByZone = <EquipmentZone, List<Equipment>>{};
    for (final item in filtered) {
      groupedByZone.putIfAbsent(item.zone, () => []).add(item);
    }

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
          _FilterBar(
            selectedType: _selectedType,
            selectedZone: _selectedZone,
            selectedStatut: _selectedStatut,
            selectedPrix: _selectedPrix,
            onTypeChanged: (v) => setState(() => _selectedType = v),
            onZoneChanged: (v) => setState(() => _selectedZone = v),
            onStatutChanged: (v) => setState(() => _selectedStatut = v),
            onPrixChanged: (v) => setState(() => _selectedPrix = v),
          ),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No items match filters',
                  style: TextStyle(color: Colors.white38, fontSize: 14),
                ),
              ),
            )
          else
            ...EquipmentZone.values
                .where((zone) => groupedByZone.containsKey(zone))
                .map((zone) => _ZoneSection(
                      zone: zone,
                      items: groupedByZone[zone]!,
                    )),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter bar
// ---------------------------------------------------------------------------

class _FilterBar extends StatelessWidget {
  final EquipmentType? selectedType;
  final EquipmentZone? selectedZone;
  final StatutFilter selectedStatut;
  final PrixFilter selectedPrix;
  final ValueChanged<EquipmentType?> onTypeChanged;
  final ValueChanged<EquipmentZone?> onZoneChanged;
  final ValueChanged<StatutFilter> onStatutChanged;
  final ValueChanged<PrixFilter> onPrixChanged;

  const _FilterBar({
    required this.selectedType,
    required this.selectedZone,
    required this.selectedStatut,
    required this.selectedPrix,
    required this.onTypeChanged,
    required this.onZoneChanged,
    required this.onStatutChanged,
    required this.onPrixChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // TYPE row
          _FilterRow(
            label: 'TYPE',
            children: [
              _Chip(
                text: 'Tout',
                selected: selectedType == null,
                color: Colors.white60,
                onTap: () => onTypeChanged(null),
              ),
              _Chip(
                text: 'Materiel',
                selected: selectedType == EquipmentType.materiel,
                color: const Color(0xFF4FC3F7),
                onTap: () => onTypeChanged(
                    selectedType == EquipmentType.materiel ? null : EquipmentType.materiel),
              ),
              _Chip(
                text: 'Protection',
                selected: selectedType == EquipmentType.protection,
                color: const Color(0xFFFF7043),
                onTap: () => onTypeChanged(
                    selectedType == EquipmentType.protection ? null : EquipmentType.protection),
              ),
              _Chip(
                text: 'Securite',
                selected: selectedType == EquipmentType.securite,
                color: const Color(0xFF81C784),
                onTap: () => onTypeChanged(
                    selectedType == EquipmentType.securite ? null : EquipmentType.securite),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ZONE row
          _FilterRow(
            label: 'ZONE',
            children: [
              _Chip(
                text: 'Tout',
                selected: selectedZone == null,
                color: const Color(0xFFEF5350),
                onTap: () => onZoneChanged(null),
              ),
              ...EquipmentZone.values.map((z) => _Chip(
                    text: _zoneLabel(z),
                    selected: selectedZone == z,
                    color: const Color(0xFFEF5350),
                    onTap: () =>
                        onZoneChanged(selectedZone == z ? null : z),
                  )),
            ],
          ),
          const SizedBox(height: 8),

          // STATUT row
          _FilterRow(
            label: 'STATUT',
            children: [
              _Chip(
                text: 'Tout',
                selected: selectedStatut == StatutFilter.tout,
                color: Colors.white60,
                onTap: () => onStatutChanged(StatutFilter.tout),
              ),
              _Chip(
                text: 'Manque',
                selected: selectedStatut == StatutFilter.manque,
                color: const Color(0xFFEF5350),
                onTap: () => onStatutChanged(
                    selectedStatut == StatutFilter.manque ? StatutFilter.tout : StatutFilter.manque),
              ),
              _Chip(
                text: "J'ai",
                selected: selectedStatut == StatutFilter.jai,
                color: const Color(0xFF81C784),
                onTap: () => onStatutChanged(
                    selectedStatut == StatutFilter.jai ? StatutFilter.tout : StatutFilter.jai),
              ),
              _Chip(
                text: 'Avec URL',
                selected: selectedStatut == StatutFilter.avecUrl,
                color: const Color(0xFF4FC3F7),
                onTap: () => onStatutChanged(
                    selectedStatut == StatutFilter.avecUrl ? StatutFilter.tout : StatutFilter.avecUrl),
              ),
              _Chip(
                text: 'Avec Prix',
                selected: selectedStatut == StatutFilter.avecPrix,
                color: const Color(0xFFFFB74D),
                onTap: () => onStatutChanged(
                    selectedStatut == StatutFilter.avecPrix ? StatutFilter.tout : StatutFilter.avecPrix),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // PRIX row
          _FilterRow(
            label: 'PRIX',
            children: [
              _Chip(
                text: 'Tout',
                selected: selectedPrix == PrixFilter.tout,
                color: const Color(0xFF4FC3F7),
                onTap: () => onPrixChanged(PrixFilter.tout),
              ),
              _Chip(
                text: '0-50\u20AC',
                selected: selectedPrix == PrixFilter.p0_50,
                color: const Color(0xFF4FC3F7),
                onTap: () => onPrixChanged(
                    selectedPrix == PrixFilter.p0_50 ? PrixFilter.tout : PrixFilter.p0_50),
              ),
              _Chip(
                text: '50-150\u20AC',
                selected: selectedPrix == PrixFilter.p50_150,
                color: const Color(0xFF4FC3F7),
                onTap: () => onPrixChanged(
                    selectedPrix == PrixFilter.p50_150 ? PrixFilter.tout : PrixFilter.p50_150),
              ),
              _Chip(
                text: '150-400\u20AC',
                selected: selectedPrix == PrixFilter.p150_400,
                color: const Color(0xFF4FC3F7),
                onTap: () => onPrixChanged(
                    selectedPrix == PrixFilter.p150_400 ? PrixFilter.tout : PrixFilter.p150_400),
              ),
              _Chip(
                text: '400\u20AC+',
                selected: selectedPrix == PrixFilter.p400plus,
                color: const Color(0xFF4FC3F7),
                onTap: () => onPrixChanged(
                    selectedPrix == PrixFilter.p400plus ? PrixFilter.tout : PrixFilter.p400plus),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _zoneLabel(EquipmentZone z) {
    switch (z) {
      case EquipmentZone.tete:
        return 'Tete';
      case EquipmentZone.torse:
        return 'Torse';
      case EquipmentZone.dos:
        return 'Dos';
      case EquipmentZone.mains:
        return 'Mains';
      case EquipmentZone.jambes:
        return 'Jambes';
      case EquipmentZone.pieds:
        return 'Pieds';
    }
  }
}

class _FilterRow extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const _FilterRow({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white38,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: children
                  .map((c) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: c,
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _Chip({
    required this.text,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: selected ? color : Colors.white.withValues(alpha: 0.12),
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? color : Colors.white38,
          ),
        ),
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
    final remaining = notifier.remainingPrice;

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
          if (remaining > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Remaining budget',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white54,
                  ),
                ),
                const Spacer(),
                Text(
                  '\u20AC${remaining.toStringAsFixed(remaining.truncateToDouble() == remaining ? 0 : 2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFB74D),
                  ),
                ),
              ],
            ),
          ],
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
    ref.watch(equipmentProvider);
    final notifier = ref.read(equipmentProvider.notifier);
    final url = notifier.shopUrl(itemId);
    final itemPrice = notifier.price(itemId);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  onTap: () {
                    notifier.setShopUrlAndPrice(itemId, null, null);
                  },
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
          if (itemPrice != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '\u20AC${itemPrice.toStringAsFixed(itemPrice.truncateToDouble() == itemPrice ? 0 : 2)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFB74D),
                ),
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
    final urlController = TextEditingController(text: currentUrl ?? '');
    final currentPrice = notifier.price(itemId);
    final priceController = TextEditingController(
      text: currentPrice != null ? currentPrice.toStringAsFixed(currentPrice.truncateToDouble() == currentPrice ? 0 : 2) : '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Shop Link',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
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
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Price (e.g. 149.99)',
                prefixText: '\u20AC ',
                prefixStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          FilledButton(
            onPressed: () {
              final url = urlController.text.trim();
              final price = double.tryParse(priceController.text.trim());
              notifier.setShopUrlAndPrice(
                itemId,
                url.isEmpty ? null : url,
                price,
              );
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
