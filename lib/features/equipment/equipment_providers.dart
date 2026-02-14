import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/equipment.dart';
import '../../core/network/api_client.dart';
import '../../core/auth/auth_providers.dart';
import '../tricks/trick_providers.dart';

const _stateKey = 'equipment_state_v2';
const _profileSetupKey = 'equipment_profile_setup_done';
const _legacyOwnedKey = 'equipment_owned';

/// Per-item user state: ownership + optional shop URL + optional price.
class EquipmentUserState {
  final bool owned;
  final String? shopUrl;
  final double? price;

  const EquipmentUserState({this.owned = false, this.shopUrl, this.price});

  Map<String, dynamic> toJson() => {
        'owned': owned,
        if (shopUrl != null) 'shopUrl': shopUrl,
        if (price != null) 'price': price,
      };

  factory EquipmentUserState.fromJson(Map<String, dynamic> json) =>
      EquipmentUserState(
        owned: json['owned'] as bool? ?? false,
        shopUrl: json['shopUrl'] as String?,
        price: (json['price'] as num?)?.toDouble(),
      );
}

/// Manages equipment ownership + shop URLs.
/// Offline-first: persists to SharedPreferences, syncs to server when authenticated.
class EquipmentNotifier extends StateNotifier<Map<String, EquipmentUserState>> {
  final SharedPreferences _prefs;
  final ApiClient? _api;

  EquipmentNotifier(this._prefs, this._api) : super({}) {
    _load();
  }

  bool get isProfileSetupDone => _prefs.getBool(_profileSetupKey) ?? false;

  void _load() {
    // Try v2 key first
    final raw = _prefs.getString(_stateKey);
    if (raw != null) {
      final Map<String, dynamic> map = json.decode(raw);
      state = map.map((id, val) =>
          MapEntry(id, EquipmentUserState.fromJson(val as Map<String, dynamic>)));
      return;
    }

    // Migrate from legacy key (Map<String, bool>)
    final legacy = _prefs.getString(_legacyOwnedKey);
    if (legacy != null) {
      final Map<String, dynamic> map = json.decode(legacy);
      state = map.map((id, val) =>
          MapEntry(id, EquipmentUserState(owned: val as bool)));
      _save(); // persist migration
      return;
    }

    // Empty until profile setup
    final defaults = <String, EquipmentUserState>{};
    for (final item in EquipmentCatalog.all) {
      defaults[item.id] = const EquipmentUserState();
    }
    state = defaults;
  }

  Future<void> _save() async {
    final encoded =
        state.map((id, s) => MapEntry(id, s.toJson()));
    await _prefs.setString(_stateKey, json.encode(encoded));
  }

  /// Pull equipment state from server and merge.
  Future<void> syncFromServer() async {
    if (_api == null) return;
    try {
      final data = await _api.get('/equipment/');
      final items = data['items'] as Map<String, dynamic>? ?? {};
      final merged = Map<String, EquipmentUserState>.from(state);
      for (final entry in items.entries) {
        final remote = entry.value as Map<String, dynamic>;
        merged[entry.key] = EquipmentUserState(
          owned: remote['owned'] as bool? ?? false,
          shopUrl: remote['shopUrl'] as String?,
        );
      }
      state = merged;
      await _save();
    } catch (_) {
      // Silently fail — offline-first
    }
  }

  /// Push full state to server.
  Future<void> syncToServer() async {
    if (_api == null) return;
    try {
      final items = state.map((id, s) => MapEntry(id, s.toJson()));
      await _api.put('/equipment/', body: {'items': items});
    } catch (_) {
      // Silently fail — offline-first
    }
  }

  /// Fire-and-forget PATCH for a single item.
  void _patchRemote(String itemId) {
    if (_api == null) return;
    final s = state[itemId];
    if (s == null) return;
    _api.patch('/equipment/$itemId', body: {
      'owned': s.owned,
      'shopUrl': s.shopUrl,
    }).catchError((_) => <String, dynamic>{});
  }

  /// Accept the backcountry skiing profile — marks all items as owned.
  Future<void> acceptBackcountryProfile() async {
    final newState = <String, EquipmentUserState>{};
    for (final item in EquipmentCatalog.all) {
      final existing = state[item.id];
      newState[item.id] = EquipmentUserState(
        owned: EquipmentCatalog.backcountryDefaults[item.id] ?? false,
        shopUrl: existing?.shopUrl,
      );
    }
    state = newState;
    await _prefs.setBool(_profileSetupKey, true);
    await _save();
    syncToServer();
  }

  /// Decline the profile — start with everything unchecked.
  Future<void> declineProfile() async {
    final empty = <String, EquipmentUserState>{};
    for (final item in EquipmentCatalog.all) {
      empty[item.id] = const EquipmentUserState();
    }
    state = empty;
    await _prefs.setBool(_profileSetupKey, true);
    await _save();
    syncToServer();
  }

  bool isOwned(String itemId) => state[itemId]?.owned ?? false;

  String? shopUrl(String itemId) => state[itemId]?.shopUrl;

  Future<void> toggleOwned(String itemId) async {
    final current = state[itemId] ?? const EquipmentUserState();
    final updated = Map<String, EquipmentUserState>.from(state);
    updated[itemId] = EquipmentUserState(owned: !current.owned, shopUrl: current.shopUrl, price: current.price);
    state = updated;
    await _save();
    _patchRemote(itemId);
  }

  Future<void> setShopUrl(String itemId, String? url) async {
    final current = state[itemId] ?? const EquipmentUserState();
    final updated = Map<String, EquipmentUserState>.from(state);
    updated[itemId] = EquipmentUserState(owned: current.owned, shopUrl: url, price: current.price);
    state = updated;
    await _save();
    _patchRemote(itemId);
  }

  Future<void> setShopUrlAndPrice(String itemId, String? url, double? price) async {
    final current = state[itemId] ?? const EquipmentUserState();
    final updated = Map<String, EquipmentUserState>.from(state);
    updated[itemId] = EquipmentUserState(owned: current.owned, shopUrl: url, price: price);
    state = updated;
    await _save();
    _patchRemote(itemId);
  }

  double? price(String itemId) => state[itemId]?.price;

  /// Total price of unowned items that have a price set.
  double get remainingPrice => state.entries
      .where((e) => !e.value.owned && e.value.price != null)
      .fold(0.0, (sum, e) => sum + e.value.price!);

  int get ownedCount => state.values.where((v) => v.owned).length;
  int get totalCount => EquipmentCatalog.all.length;
}

final equipmentProvider =
    StateNotifierProvider<EquipmentNotifier, Map<String, EquipmentUserState>>(
  (ref) {
    final prefs = ref.watch(sharedPrefsProvider);
    final isAuth = ref.watch(isAuthenticatedProvider);
    final api = isAuth ? ref.watch(apiClientProvider) : null;
    final notifier = EquipmentNotifier(prefs, api);
    if (isAuth) {
      // Background sync from server on login
      Future.microtask(() => notifier.syncFromServer());
    }
    return notifier;
  },
);
