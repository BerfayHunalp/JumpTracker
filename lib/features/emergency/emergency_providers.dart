import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../tricks/trick_providers.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class EmergencyContact {
  final String id;
  final String name;
  final String phone;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'phone': phone};

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      EmergencyContact(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
      );

  /// Phone number stripped to digits only (with leading country code).
  String get whatsappPhone => phone.replaceAll(RegExp(r'[^0-9]'), '');
}

class EmergencyState {
  final List<EmergencyContact> contacts;

  const EmergencyState({this.contacts = const []});

  EmergencyState copyWith({List<EmergencyContact>? contacts}) {
    return EmergencyState(contacts: contacts ?? this.contacts);
  }
}

// ---------------------------------------------------------------------------
// Notifier — local-only, no backend
// ---------------------------------------------------------------------------

const _contactsKey = 'emergency_contacts';

class EmergencyNotifier extends StateNotifier<EmergencyState> {
  final SharedPreferences _prefs;

  EmergencyNotifier(this._prefs) : super(const EmergencyState()) {
    _loadContacts();
  }

  void _loadContacts() {
    final raw = _prefs.getString(_contactsKey);
    if (raw != null) {
      final List<dynamic> list = json.decode(raw);
      final contacts = list
          .map((e) =>
              EmergencyContact.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(contacts: contacts);
    }
  }

  Future<void> _saveContacts() async {
    final encoded = state.contacts.map((c) => c.toJson()).toList();
    await _prefs.setString(_contactsKey, json.encode(encoded));
  }

  Future<void> addContact(String name, String phone) async {
    if (state.contacts.length >= 2) return;

    final contact = EmergencyContact(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      phone: phone,
    );

    state = state.copyWith(contacts: [...state.contacts, contact]);
    await _saveContacts();
  }

  Future<void> removeContact(String id) async {
    state = state.copyWith(
      contacts: state.contacts.where((c) => c.id != id).toList(),
    );
    await _saveContacts();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final emergencyProvider =
    StateNotifierProvider<EmergencyNotifier, EmergencyState>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return EmergencyNotifier(prefs);
});
