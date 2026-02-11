import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';

final sessionListProvider = FutureProvider<List<Session>>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.getAllSessions();
});

final sessionDetailProvider =
    FutureProvider.family<Session?, String>((ref, sessionId) {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.getSessionById(sessionId);
});

final sessionJumpsProvider =
    FutureProvider.family<List<Jump>, String>((ref, sessionId) {
  final repo = ref.watch(jumpRepositoryProvider);
  return repo.getJumpsForSession(sessionId);
});

final sessionGpsProvider =
    FutureProvider.family<List<GpsPoint>, String>((ref, sessionId) {
  final repo = ref.watch(gpsRepositoryProvider);
  return repo.getPointsForSession(sessionId);
});
