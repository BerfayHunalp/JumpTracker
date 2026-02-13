import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/equipment.dart';
import '../tricks/trick_providers.dart';

const _ownedKey = 'equipment_owned';

/// Manages equipment ownership persisted in SharedPreferences.
class EquipmentNotifier extends StateNotifier<Map<String, bool>> {
  final SharedPreferences _prefs;

  EquipmentNotifier(this._prefs) : super({}) {
    _load();
  }

  void _load() {
    final raw = _prefs.getString(_ownedKey);
    if (raw != null) {
      final Map<String, dynamic> map = json.decode(raw);
      state = map.map((id, val) => MapEntry(id, val as bool));
    } else {
      // Set defaults from catalog
      final defaults = <String, bool>{};
      for (final item in EquipmentCatalog.all) {
        defaults[item.id] = item.defaultOwned;
      }
      state = defaults;
    }
  }

  Future<void> _save() async {
    await _prefs.setString(_ownedKey, json.encode(state));
  }

  bool isOwned(String itemId) {
    if (state.containsKey(itemId)) return state[itemId]!;
    final item = EquipmentCatalog.all.where((e) => e.id == itemId).firstOrNull;
    return item?.defaultOwned ?? false;
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
