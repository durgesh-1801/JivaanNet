import 'package:jivaan_net_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod(
    'Given Incident Concurrency',
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      final dispatcher1Session = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          'dispatcher-1',
          {const Scope('dispatcher')},
        ),
      );

      final dispatcher2Session = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          'dispatcher-2',
          {const Scope('dispatcher')},
        ),
      );

      test(
        'when two workers submit the same SOS UUID concurrently then exactly one creates and one returns existing without error',
        () async {
          final incidentId = 'cc11cc11-2222-4333-8444-555555555555';
          final payload = SosSubmissionPayload(
            incidentId: incidentId,
            latitude: 25.0,
            longitude: 75.0,
            createdAt: DateTime.utc(2026, 10, 11, 8, 0, 0),
            description: 'Trapped victim reporting via mesh',
            relayCount: 2,
          );

          // Run both submissions concurrently
          final results = await Future.wait([
            endpoints.incident.submitSos(sessionBuilder, payload),
            endpoints.incident.submitSos(sessionBuilder, payload),
          ]);

          final res1 = results[0];
          final res2 = results[1];

          // Exactly one must be isNew, the other must be duplicate (isNew == false)
          final newCount = (res1.isNew ? 1 : 0) + (res2.isNew ? 1 : 0);
          expect(newCount, equals(1));

          // Both must refer to the exact same incident record
          expect(res1.incident.id, equals(res2.incident.id));
          expect(res1.incident.incidentId, equals(incidentId));
          expect(res1.incident.severity, equals('critical'));

          // Verify row count in database is exactly 1
          final count = await SosIncident.db.count(
            sessionBuilder.build(),
            where: (t) => t.incidentId.equals(incidentId),
          );
          expect(count, equals(1));
        },
      );

      test(
        'when two responders claim the same incident concurrently then exactly one succeeds and one receives conflict',
        () async {
          final incidentId = 'cc22cc22-3333-4444-8555-666666666666';
          await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: incidentId,
              latitude: 26.0,
              longitude: 76.0,
              createdAt: DateTime.utc(2026, 10, 11, 8, 0, 0),
              description: 'Urgent medical assistance required',
              relayCount: 0,
            ),
          );

          var claimSuccess = 0;
          var claimConflict = 0;
          String? winningClaimant;

          Future<void> attemptClaim(
            TestSessionBuilder session,
            String responderId,
          ) async {
            try {
              final claimed = await endpoints.incident.claimIncident(
                session,
                incidentId,
              );
              claimSuccess++;
              winningClaimant = claimed.claimedBy;
            } on SosClaimConflictException {
              claimConflict++;
            }
          }

          // Execute both claims concurrently
          await Future.wait([
            attemptClaim(dispatcher1Session, 'dispatcher-1'),
            attemptClaim(dispatcher2Session, 'dispatcher-2'),
          ]);

          expect(claimSuccess, equals(1));
          expect(claimConflict, equals(1));
          expect(winningClaimant, isNotNull);

          // Verify database record has the winner
          final record = await endpoints.incident.getIncident(
            sessionBuilder,
            incidentId,
          );
          expect(record!.claimedBy, equals(winningClaimant));
        },
      );
    },
  );
}
