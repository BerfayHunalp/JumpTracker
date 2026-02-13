import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/trick.dart';

const _statesKey = 'trick_mastery_states';

/// Provides SharedPreferences instance.
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden at app startup');
});

/// Manages trick mastery states persisted in SharedPreferences.
class TrickMasteryNotifier extends StateNotifier<Map<String, TrickMastery>> {
  final SharedPreferences _prefs;

  TrickMasteryNotifier(this._prefs) : super({}) {
    _load();
  }

  void _load() {
    final raw = _prefs.getString(_statesKey);
    if (raw == null) return;
    final Map<String, dynamic> map = json.decode(raw);
    state = map.map(
      (id, val) => MapEntry(id, TrickMastery.values[val as int]),
    );
  }

  Future<void> _save() async {
    final map = state.map((id, m) => MapEntry(id, m.index));
    await _prefs.setString(_statesKey, json.encode(map));
  }

  TrickMastery getMastery(String trickId) {
    return state[trickId] ?? TrickMastery.locked;
  }

  Future<void> cycleMastery(String trickId) async {
    final current = getMastery(trickId);
    final next = current.next();
    state = {...state, trickId: next};
    await _save();
  }

  Future<void> setMastery(String trickId, TrickMastery mastery) async {
    state = {...state, trickId: mastery};
    await _save();
  }

  int get totalXp {
    int xp = 0;
    for (final m in state.values) {
      xp += m.xp;
    }
    return xp;
  }

  int landedCount(TrickCategory category) {
    final tricks = TrickCatalog.allByCategory[category] ?? [];
    int count = 0;
    for (final t in tricks) {
      final m = getMastery(t.id);
      if (m == TrickMastery.landed || m == TrickMastery.mastered) {
        count++;
      }
    }
    return count;
  }
}

final trickMasteryProvider =
    StateNotifierProvider<TrickMasteryNotifier, Map<String, TrickMastery>>(
  (ref) => TrickMasteryNotifier(ref.watch(sharedPrefsProvider)),
);

/// Derived: total XP.
final trickXpProvider = Provider<int>((ref) {
  ref.watch(trickMasteryProvider); // trigger rebuild
  return ref.read(trickMasteryProvider.notifier).totalXp;
});

/// Derived: current level.
final trickLevelProvider = Provider<TrickLevel>((ref) {
  return levelForXp(ref.watch(trickXpProvider));
});

/// Derived: progress towards next level [0..1].
final trickLevelProgressProvider = Provider<double>((ref) {
  return levelProgress(ref.watch(trickXpProvider));
});
