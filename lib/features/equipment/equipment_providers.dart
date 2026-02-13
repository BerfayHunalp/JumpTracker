import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/equipment.dart';
import '../tricks/trick_providers.dart';

const _ownedKey = 'equipment_owned';
const _profileSetupKey = 'equipment_profile_setup_done';

/// Manages equipment ownership persisted in SharedPreferences.
class EquipmentNotifier extends StateNotifier<Map<String, bool>> {
  final SharedPreferences _prefs;

  EquipmentNotifier(this._prefs) : super({}) {
    _load();
  }

  bool get isProfileSetupDone => _prefs.getBool(_profileSetupKey) ?? false;

  void _load() {
    final raw = _prefs.getString(_ownedKey);
    if (raw != null) {
      final Map<String, dynamic> map = json.decode(raw);
      state = map.map((id, val) => MapEntry(id, val as bool));
    } else {
      // Empty until profile setup
      final defaults = <String, bool>{};
      for (final item in EquipmentCatalog.all) {
        defaults[item.id] = false;
      }
      state = defaults;
    }
  }

  Future<void> _save() async {
    await _prefs.setString(_ownedKey, json.encode(state));
  }

  /// Accept the backcountry skiing profile — marks all items as owned.
  Future<void> acceptBackcountryProfile() async {
    state = Map<String, bool>.from(EquipmentCatalog.backcountryDefaults);
    await _prefs.setBool(_profileSetupKey, true);
    await _save();
  }

  /// Decline the profile — start with everything unchecked.
  Future<void> declineProfile() async {
    final empty = <String, bool>{};
    for (final item in EquipmentCatalog.all) {
      empty[item.id] = false;
    }
    state = empty;
    await _prefs.setBool(_profileSetupKey, true);
    await _save();
  }

  bool isOwned(String itemId) {
    if (state.containsKey(itemId)) return state[itemId]!;
    return false;
  }

  Future<void> toggleOwned(String itemId) async {
    final current = isOwned(itemId);
    state = {...state, itemId: !current};
    await _save();
  }

  int get ownedCount => state.values.where((v) => v).length;
  int get totalCount => EquipmentCatalog.all.length;
}

final equipmentProvider =
    StateNotifierProvider<EquipmentNotifier, Map<String, bool>>(
  (ref) => EquipmentNotifier(ref.watch(sharedPrefsProvider)),
);
