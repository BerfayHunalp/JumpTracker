import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/equipment.dart';
import '../equipment/equipment_providers.dart';
import '../learn/learn_screen.dart';
import 'emergency_providers.dart';

class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(emergencyProvider);
    final notifier = ref.read(emergencyProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Emergency',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Contacts section ──────────────────────────────────────
          const Text(
            'EMERGENCY CONTACTS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white38,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),

          if (state.contacts.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'No emergency contacts yet.\nAdd up to 2 trusted contacts you\'ll share your WhatsApp live location with before going off-piste.',
                style: TextStyle(
                    color: Colors.white38, fontSize: 13, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),

          ...state.contacts.map((contact) => _ContactTile(contact: contact)),

          if (state.contacts.length < 2)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton.icon(
                onPressed: () => _showAddContactDialog(context, notifier),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Add contact'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4FC3F7),
                  side: const BorderSide(
                      color: Color(0xFF4FC3F7), width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

          const SizedBox(height: 32),

          // ── Going Hors Piste button ───────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _showHorsPisteFlow(context, ref),
              icon: const Icon(Icons.terrain, size: 22),
              label: const Text(
                'Going Hors Piste',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF7043),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── "Going Hors Piste" safety flow ──────────────────────────────────

  void _showHorsPisteFlow(BuildContext context, WidgetRef ref) {
    final equipState = ref.read(equipmentProvider);
    final emergState = ref.read(emergencyProvider);
    final learnProgress = ref.read(learnProgressProvider);

    // Check security gear
    final securityItems = EquipmentCatalog.all
        .where((e) => e.type == EquipmentType.securite)
        .toList();
    final missingGear = <Equipment>[];
    for (final item in securityItems) {
      final s = equipState[item.id];
      if (s == null || !s.owned) {
        missingGear.add(item);
      }
    }

    final hasContacts = emergState.contacts.isNotEmpty;
    final allLessonsCompleted =
        learnProgress.length >= LearnCatalog.all.length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFFF7043), size: 28),
                SizedBox(width: 10),
                Text(
                  'Going Off-Piste',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Education warning ────────────────────────────────
            _WarningSection(
              icon: Icons.school,
              iconColor: allLessonsCompleted
                  ? const Color(0xFF81C784)
                  : const Color(0xFFFFB74D),
              title: allLessonsCompleted
                  ? 'Education: Completed'
                  : 'Education: Incomplete!',
              child: Text(
                allLessonsCompleted
                    ? 'You\'ve completed all lessons. Stay sharp out there.'
                    : 'You haven\'t finished the Learn section. As far as we know, you may not know how to ski safely off-piste.\n\nEither take the time to complete your education first, or go at your own peril.',
                style: TextStyle(
                  fontSize: 13,
                  color: allLessonsCompleted
                      ? Colors.white54
                      : const Color(0xFFFFB74D),
                  height: 1.5,
                  fontWeight: allLessonsCompleted
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Security gear check ────────────────────────────────
            _WarningSection(
              icon: Icons.shield,
              iconColor: missingGear.isEmpty
                  ? const Color(0xFF81C784)
                  : const Color(0xFFEF5350),
              title: missingGear.isEmpty
                  ? 'Security gear: All checked'
                  : 'Missing security gear!',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...securityItems.map((item) {
                    final owned = !missingGear.contains(item);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Icon(
                            owned ? Icons.check_circle : Icons.cancel,
                            size: 18,
                            color: owned
                                ? const Color(0xFF81C784)
                                : const Color(0xFFEF5350),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 13,
                              color: owned ? Colors.white70 : const Color(0xFFEF5350),
                              fontWeight:
                                  owned ? FontWeight.normal : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (missingGear.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'You NEED all security equipment to reduce risk of death in an avalanche.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFEF5350),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Avalanche facts ────────────────────────────────────
            const _WarningSection(
              icon: Icons.ac_unit,
              iconColor: Color(0xFF4FC3F7),
              title: 'Avalanche Risk',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BulletPoint(
                    'Every year, ~100 people die from avalanches in the Alps.',
                  ),
                  _BulletPoint(
                    '90% of the time, it\'s the victim or their group that triggered the avalanche.',
                  ),
                  _BulletPoint(
                    'You have max 15 minutes of air if buried under snow. After that, survival drops drastically.',
                  ),
                  _BulletPoint(
                    'There is NO mountain with zero risk. Every off-piste run is a gamble.',
                  ),
                  SizedBox(height: 6),
                  Text(
                    'If you don\'t know precisely what you\'re doing — you might die.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFFF7043),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── GPS limitation ─────────────────────────────────────
            const _WarningSection(
              icon: Icons.gps_off,
              iconColor: Color(0xFFFFB74D),
              title: 'GPS is limited in mountains',
              child: Text(
                'Mountain terrain (valleys, cliffs, dense forest) causes GPS signal loss and inaccuracy. Your shared location may be off by 50-200m or stop updating entirely. Do NOT rely on GPS as your only safety measure.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white54,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Solo warning ───────────────────────────────────────
            const _WarningSection(
              icon: Icons.person,
              iconColor: Color(0xFFEF5350),
              title: 'Going alone?',
              child: Text(
                'If you\'re alone and seeking thrills, stay close to marked slopes. Off-piste alone means nobody to dig you out in 15 minutes. If you must go, at least share your location with someone who can call rescue.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white54,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Emergency contact check ────────────────────────────
            _WarningSection(
              icon: Icons.contact_phone,
              iconColor: hasContacts
                  ? const Color(0xFF81C784)
                  : const Color(0xFFEF5350),
              title: hasContacts
                  ? 'Emergency contacts ready'
                  : 'No emergency contacts!',
              child: Text(
                hasContacts
                    ? 'You\'ll be prompted to share your WhatsApp live location with your contacts.'
                    : 'Go back and add at least one emergency contact before going off-piste.',
                style: TextStyle(
                  fontSize: 13,
                  color: hasContacts ? Colors.white54 : const Color(0xFFEF5350),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Action button ──────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: !hasContacts
                    ? null
                    : () {
                        Navigator.of(ctx).pop();
                        _showWhatsAppSheet(context, emergState.contacts);
                      },
                icon: const Icon(Icons.send, size: 20),
                label: const Text(
                  'I understand — Share via WhatsApp',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white12,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (!hasContacts)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    'Add emergency contacts first',
                    style: TextStyle(fontSize: 11, color: Colors.white24),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── WhatsApp share sheet ─────────────────────────────────────────────

  void _showWhatsAppSheet(
      BuildContext context, List<EmergencyContact> contacts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Icon(Icons.location_on,
                size: 36, color: Color(0xFF25D366)),
            const SizedBox(height: 10),
            const Text(
              'Share your live location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Once WhatsApp opens, tap the + icon (or the attachment clip), then Location, then "Share live location".',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ...contacts.map((contact) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openWhatsApp(contact),
                      icon: const Icon(Icons.chat, size: 20),
                      label: Text(
                        'Open WhatsApp with ${contact.name}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Done',
                style: TextStyle(color: Colors.white38),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _openWhatsApp(EmergencyContact contact) async {
    final message = Uri.encodeComponent(
      "Hey ${contact.name}, I'm about to go off-piste skiing. "
      "I'm sharing my live location with you so you can keep an eye on me. "
      "If I don't check in within a reasonable time, please call mountain rescue.",
    );
    final uri = Uri.parse(
        'https://wa.me/${contact.whatsappPhone}?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Dialogs ──────────────────────────────────────────────────────────

  void _showAddContactDialog(BuildContext context, EmergencyNotifier notifier) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add Emergency Contact',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Use their full international phone number (e.g. +33612345678)',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Name',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: '+33 6 12 34 56 78',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.phone,
                    color: Colors.white24, size: 18),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();
              if (name.isNotEmpty && phone.isNotEmpty) {
                notifier.addContact(name, phone);
                Navigator.of(ctx).pop();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF4FC3F7),
            ),
            child:
                const Text('Add', style: TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Warning section widget
// ---------------------------------------------------------------------------

class _WarningSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _WarningSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bullet point
// ---------------------------------------------------------------------------

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, size: 6, color: Colors.white30),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white54,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Contact tile
// ---------------------------------------------------------------------------

class _ContactTile extends ConsumerWidget {
  final EmergencyContact contact;

  const _ContactTile({required this.contact});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(emergencyProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEF5350).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEF5350).withValues(alpha: 0.15),
            ),
            child: const Icon(Icons.person,
                color: Color(0xFFEF5350), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact.phone,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.white38),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => notifier.removeContact(contact.id),
            child: const Icon(Icons.close, size: 18, color: Colors.white30),
          ),
        ],
      ),
    );
  }
}
