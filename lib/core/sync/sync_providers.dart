import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_providers.dart';
import '../database/database.dart';
import 'sync_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    ref.watch(apiClientProvider),
    ref.watch(sessionRepositoryProvider),
    ref.watch(jumpRepositoryProvider),
  );
});

enum SyncStatus { idle, syncing, error }

final syncStatusProvider = StateProvider<SyncStatus>((ref) => SyncStatus.idle);
