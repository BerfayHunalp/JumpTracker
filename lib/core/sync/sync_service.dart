import '../database/database.dart';
import '../network/api_client.dart';

class SyncService {
  final ApiClient _api;
  final SessionRepository _sessionRepo;
  final JumpRepository _jumpRepo;

  SyncService(this._api, this._sessionRepo, this._jumpRepo);

  /// Upload all unsynced sessions to the backend.
  /// Fails silently if offline or not authenticated.
  Future<void> syncPendingSessions() async {
    try {
      final token = await _api.token;
      if (token == null) return; // Not authenticated

      final unsynced = await _sessionRepo.getUnsyncedSessions();
      if (unsynced.isEmpty) return;

      final sessionsPayload = <Map<String, dynamic>>[];

      for (final session in unsynced) {
        final jumps = await _jumpRepo.getJumpsForSession(session.id);

        sessionsPayload.add({
          'session': {
            'id': session.id,
            'startedAt': session.startedAt.toIso8601String(),
            'endedAt': session.endedAt?.toIso8601String(),
            'resortName': session.resortName,
            'totalJumps': session.totalJumps,
            'maxAirtimeMs': session.maxAirtimeMs,
            'totalVerticalM': session.totalVerticalM,
          },
          'jumps': jumps
              .map((j) => {
                    'id': j.id,
                    'runId': j.runId,
                    'takeoffTimestampUs': j.takeoffTimestampUs,
                    'landingTimestampUs': j.landingTimestampUs,
                    'airtimeMs': j.airtimeMs,
                    'distanceM': j.distanceM,
                    'heightM': j.heightM,
                    'speedKmh': j.speedKmh,
                    'landingGForce': j.landingGForce,
                    'latTakeoff': j.latTakeoff,
                    'lonTakeoff': j.lonTakeoff,
                    'latLanding': j.latLanding,
                    'lonLanding': j.lonLanding,
                    'altitudeTakeoff': j.altitudeTakeoff,
                  })
              .toList(),
        });
      }

      final result = await _api.post(
        '/sync/sessions',
        body: {'sessions': sessionsPayload},
      );

      // Mark synced sessions
      final synced = (result['synced'] as List?)?.cast<String>() ?? [];
      for (final id in synced) {
        await _sessionRepo.markSessionSynced(id);
      }
    } catch (_) {
      // Fail silently - will retry next time
    }
  }
}
