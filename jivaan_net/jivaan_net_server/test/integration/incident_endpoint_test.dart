import 'package:jivaan_net_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given Incident endpoint', (sessionBuilder, endpoints) {
    // Dispatcher authenticated session for protected actions
    final dispatcherSession = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        'dispatcher-1',
        {const Scope('dispatcher')},
      ),
    );

    // Civilian/unauthorized authenticated session
    final civilianSession = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        'civilian-1',
        {},
      ),
    );

    group('SOS Ingestion', () {
      test(
        'when submitting valid SOS then creates new pending incident',
        () async {
          final incidentId = 'a1b2c3d4-e5f6-4a1b-8c2d-3e4f5a6b7c8d';
          final offlineTime = DateTime.utc(2026, 10, 11, 12, 0, 0);

          final payload = SosSubmissionPayload(
            incidentId: incidentId,
            latitude: 28.6139,
            longitude: 77.2090,
            createdAt: offlineTime,
            description: 'Building collapse rescue needed',
            sourceDeviceId: 'node-mesh-42',
            relayCount: 3,
          );

          final response = await endpoints.incident.submitSos(
            sessionBuilder,
            payload,
          );

          expect(response.isNew, isTrue);
          expect(response.incident.incidentId, equals(incidentId));
          expect(response.incident.status, equals('pending'));
          expect(response.incident.severity, equals('critical'));
          expect(response.incident.latitude, equals(28.6139));
          expect(response.incident.longitude, equals(77.2090));
          expect(response.incident.relayCount, equals(3));
          expect(response.incident.sourceDeviceId, equals('node-mesh-42'));
          expect(
            response.incident.description,
            equals('Building collapse rescue needed'),
          );
          expect(response.incident.createdAt, equals(offlineTime));
          expect(response.incident.receivedAt, isNotNull);
          expect(response.incident.id, isNotNull);
        },
      );

      test(
        'when submitting offline SOS then preserves original createdAt timestamp',
        () async {
          final incidentId = 'b2c3d4e5-f6a7-4b2c-9d3e-4f5a6b7c8d9e';
          final offlineCreatedAt = DateTime.utc(2026, 10, 11, 8, 30, 0);

          final payload = SosSubmissionPayload(
            incidentId: incidentId,
            latitude: 19.0760,
            longitude: 72.8777,
            createdAt: offlineCreatedAt,
            description: 'Flooding trapped on roof',
            sourceDeviceId: 'phone-offline-01',
            relayCount: 5,
          );

          final response = await endpoints.incident.submitSos(
            sessionBuilder,
            payload,
          );

          expect(response.isNew, isTrue);
          expect(response.incident.createdAt, equals(offlineCreatedAt));
          expect(
            response.incident.receivedAt.isAfter(offlineCreatedAt),
            isTrue,
            reason: 'Server receivedAt must reflect when it was ingested',
          );
        },
      );

      test(
        'when submitting duplicate SOS UUID then returns existing record without creating duplicate',
        () async {
          final incidentId = 'c3d4e5f6-a7b8-4c3d-ae4f-5a6b7c8d9e0f';
          final firstCreatedAt = DateTime.utc(2026, 10, 11, 9, 0, 0);

          final initialPayload = SosSubmissionPayload(
            incidentId: incidentId,
            latitude: 12.9716,
            longitude: 77.5946,
            createdAt: firstCreatedAt,
            description: 'Landslide blocked road',
            sourceDeviceId: 'mesh-sender-1',
            relayCount: 1,
          );

          final firstResponse = await endpoints.incident.submitSos(
            sessionBuilder,
            initialPayload,
          );
          expect(firstResponse.isNew, isTrue);

          final duplicatePayload = SosSubmissionPayload(
            incidentId: incidentId,
            latitude: 12.9716,
            longitude: 77.5946,
            createdAt: firstCreatedAt,
            description: 'Landslide blocked road (mesh retransmission)',
            sourceDeviceId: 'mesh-relay-2',
            relayCount: 4,
          );

          final secondResponse = await endpoints.incident.submitSos(
            sessionBuilder,
            duplicatePayload,
          );

          expect(secondResponse.isNew, isFalse);
          expect(secondResponse.incident.id, equals(firstResponse.incident.id));
          expect(secondResponse.incident.incidentId, equals(incidentId));
          expect(secondResponse.message, contains('previously registered'));
        },
      );

      test(
        'when repeating submissions multiple times then exactly one record exists in database',
        () async {
          final incidentId = 'd4e5f6a7-b8c9-4d4e-bf5a-6b7c8d9e0f1a';
          final createdAt = DateTime.utc(2026, 10, 11, 10, 15, 0);

          final payload = SosSubmissionPayload(
            incidentId: incidentId,
            latitude: 22.5726,
            longitude: 88.3639,
            createdAt: createdAt,
            description: 'Medical emergency',
            sourceDeviceId: 'device-xyz',
            relayCount: 0,
          );

          final res1 = await endpoints.incident.submitSos(
            sessionBuilder,
            payload,
          );
          final res2 = await endpoints.incident.submitSos(
            sessionBuilder,
            payload,
          );
          final res3 = await endpoints.incident.submitSos(
            sessionBuilder,
            payload,
          );

          expect(res1.isNew, isTrue);
          expect(res2.isNew, isFalse);
          expect(res3.isNew, isFalse);
          expect(res2.incident.id, equals(res1.incident.id));
          expect(res3.incident.id, equals(res1.incident.id));
        },
      );

      test(
        'when submitting invalid latitude then throws SosValidationException',
        () async {
          final payload = SosSubmissionPayload(
            incidentId: 'e5f6a7b8-c9d0-4e5f-8012-7c8d9e0f1a2b',
            latitude: 95.0,
            longitude: 77.0,
            createdAt: DateTime.utc(2026, 10, 11, 10, 0, 0),
            description: 'Test',
            relayCount: 0,
          );

          expect(
            () => endpoints.incident.submitSos(sessionBuilder, payload),
            throwsA(
              isA<SosValidationException>().having(
                (e) => e.field,
                'field',
                equals('latitude'),
              ),
            ),
          );
        },
      );

      test(
        'when submitting invalid longitude then throws SosValidationException',
        () async {
          final payload = SosSubmissionPayload(
            incidentId: 'f6a7b8c9-d0e1-4f6a-9123-8d9e0f1a2b3c',
            latitude: 28.0,
            longitude: 195.0,
            createdAt: DateTime.utc(2026, 10, 11, 10, 0, 0),
            description: 'Test',
            relayCount: 0,
          );

          expect(
            () => endpoints.incident.submitSos(sessionBuilder, payload),
            throwsA(
              isA<SosValidationException>().having(
                (e) => e.field,
                'field',
                equals('longitude'),
              ),
            ),
          );
        },
      );

      test(
        'when submitting invalid UUID format then throws SosValidationException',
        () async {
          final payload = SosSubmissionPayload(
            incidentId: 'not-a-valid-uuid-string',
            latitude: 28.0,
            longitude: 77.0,
            createdAt: DateTime.utc(2026, 10, 11, 10, 0, 0),
            description: 'Test',
            relayCount: 0,
          );

          expect(
            () => endpoints.incident.submitSos(sessionBuilder, payload),
            throwsA(
              isA<SosValidationException>().having(
                (e) => e.field,
                'field',
                equals('incidentId'),
              ),
            ),
          );
        },
      );

      test(
        'when submitting timestamp unreasonably far in the future then throws SosValidationException',
        () async {
          final farFuture = DateTime.now().toUtc().add(
            const Duration(days: 10),
          );

          final payload = SosSubmissionPayload(
            incidentId: '01234567-89ab-4cde-8f01-23456789abcd',
            latitude: 28.0,
            longitude: 77.0,
            createdAt: farFuture,
            description: 'Future alert',
            relayCount: 0,
          );

          expect(
            () => endpoints.incident.submitSos(sessionBuilder, payload),
            throwsA(
              isA<SosValidationException>().having(
                (e) => e.field,
                'field',
                equals('createdAt'),
              ),
            ),
          );
        },
      );

      test(
        'when submitting negative relayCount then throws SosValidationException',
        () async {
          final payload = SosSubmissionPayload(
            incidentId: '12345678-9abc-4def-8012-3456789abcde',
            latitude: 28.0,
            longitude: 77.0,
            createdAt: DateTime.utc(2026, 10, 11, 10, 0, 0),
            description: 'Negative relay',
            relayCount: -1,
          );

          expect(
            () => endpoints.incident.submitSos(sessionBuilder, payload),
            throwsA(
              isA<SosValidationException>().having(
                (e) => e.field,
                'field',
                equals('relayCount'),
              ),
            ),
          );
        },
      );
    });

    group('Incident Retrieval & Listing', () {
      test(
        'when fetching existing incident by UUID then returns incident',
        () async {
          final incidentId = '23456789-abcd-4ef0-8123-456789abcdef';
          await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: incidentId,
              latitude: 26.9124,
              longitude: 75.7873,
              createdAt: DateTime.utc(2026, 10, 11, 11, 0, 0),
              description: 'Structural damage',
              relayCount: 0,
            ),
          );

          final incident = await endpoints.incident.getIncident(
            sessionBuilder,
            incidentId,
          );

          expect(incident, isNotNull);
          expect(incident!.incidentId, equals(incidentId));
          expect(incident.status, equals('pending'));
        },
      );

      test('when fetching unknown incident UUID then returns null', () async {
        final unknownId = '99999999-9999-4999-8999-999999999999';
        final incident = await endpoints.incident.getIncident(
          sessionBuilder,
          unknownId,
        );

        expect(incident, isNull);
      });

      test(
        'when listing incidents then applies pagination and stable ordering',
        () async {
          // Seed distinct incidents with ordered creation timestamps
          for (var i = 1; i <= 5; i++) {
            final id = '00000000-0000-4000-8000-00000000000$i';
            await endpoints.incident.submitSos(
              sessionBuilder,
              SosSubmissionPayload(
                incidentId: id,
                latitude: 10.0 + i,
                longitude: 70.0 + i,
                createdAt: DateTime.utc(2026, 10, 11, 10, i, 0),
                description: 'Incident #$i',
                relayCount: i,
              ),
            );
          }

          // Fetch page 1 with limit 2
          final page1 = await endpoints.incident.listIncidents(
            sessionBuilder,
            page: 1,
            limit: 2,
          );

          expect(page1.page, equals(1));
          expect(page1.pageSize, equals(2));
          expect(page1.incidents.length, equals(2));
          expect(page1.hasMore, isTrue);
          expect(page1.totalCount, greaterThanOrEqualTo(5));

          // Deterministic ordering: newest createdAt first
          expect(
            page1.incidents[0].createdAt.isAfter(
                  page1.incidents[1].createdAt,
                ) ||
                page1.incidents[0].createdAt == page1.incidents[1].createdAt,
            isTrue,
          );

          // Fetch page 2
          final page2 = await endpoints.incident.listIncidents(
            sessionBuilder,
            page: 2,
            limit: 2,
          );
          expect(page2.page, equals(2));
          expect(page2.incidents.length, equals(2));
          expect(page2.incidents[0].id, isNot(equals(page1.incidents[0].id)));

          // Upper limit clamp test (requested 250 capped at 100)
          final clampedPage = await endpoints.incident.listIncidents(
            sessionBuilder,
            page: 1,
            limit: 250,
          );
          expect(clampedPage.pageSize, equals(100));
        },
      );

      test(
        'when filtering incidents by status and severity then returns matches',
        () async {
          final id1 = '11111111-2222-4333-8444-555555555551';
          final id2 = '11111111-2222-4333-8444-555555555552';

          await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: id1,
              latitude: 15.0,
              longitude: 75.0,
              createdAt: DateTime.utc(2026, 10, 11, 7, 0, 0),
              description: 'Search match 1',
              relayCount: 0,
            ),
          );
          await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: id2,
              latitude: 16.0,
              longitude: 76.0,
              createdAt: DateTime.utc(2026, 10, 11, 7, 10, 0),
              description: 'Search match 2',
              relayCount: 0,
            ),
          );

          // Acknowledge incident 1 via dispatcher
          await endpoints.incident.updateIncidentStatus(
            dispatcherSession,
            id1,
            'acknowledged',
          );

          // Filter for acknowledged
          final ackList = await endpoints.incident.listIncidents(
            sessionBuilder,
            page: 1,
            limit: 10,
            status: 'acknowledged',
          );
          expect(ackList.incidents.any((inc) => inc.incidentId == id1), isTrue);
          expect(
            ackList.incidents.any((inc) => inc.incidentId == id2),
            isFalse,
          );

          // Filter for pending
          final pendingList = await endpoints.incident.listIncidents(
            sessionBuilder,
            page: 1,
            limit: 10,
            status: 'pending',
          );
          expect(
            pendingList.incidents.any((inc) => inc.incidentId == id2),
            isTrue,
          );
          expect(
            pendingList.incidents.any((inc) => inc.incidentId == id1),
            isFalse,
          );

          // Filter for severity: 'medium'
          final mediumList = await endpoints.incident.listIncidents(
            sessionBuilder,
            page: 1,
            limit: 10,
            severity: 'medium',
          );
          expect(
            mediumList.incidents.any((inc) => inc.incidentId == id2),
            isTrue,
          );
        },
      );

      test(
        'when filtering by date range then returns incidents in range',
        () async {
          final idIn = '22222222-3333-4444-8555-666666666661';
          final idOut = '22222222-3333-4444-8555-666666666662';

          await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: idIn,
              latitude: 18.0,
              longitude: 78.0,
              createdAt: DateTime.utc(2026, 10, 11, 14, 0, 0),
              relayCount: 0,
            ),
          );
          await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: idOut,
              latitude: 18.0,
              longitude: 78.0,
              createdAt: DateTime.utc(2026, 10, 11, 6, 0, 0), // earlier
              relayCount: 0,
            ),
          );

          final rangeList = await endpoints.incident.listIncidents(
            sessionBuilder,
            page: 1,
            limit: 10,
            fromDate: DateTime.utc(2026, 10, 11, 12, 0, 0),
            toDate: DateTime.utc(2026, 10, 11, 16, 0, 0),
          );

          expect(
            rangeList.incidents.any((inc) => inc.incidentId == idIn),
            isTrue,
          );
          expect(
            rangeList.incidents.any((inc) => inc.incidentId == idOut),
            isFalse,
          );
        },
      );
    });

    group('Status Transitions & Authorization', () {
      test(
        'when dispatcher executes valid status transitions then status updates successfully',
        () async {
          final incidentId = '33333333-4444-4555-8666-777777777771';
          await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: incidentId,
              latitude: 13.0,
              longitude: 80.0,
              createdAt: DateTime.utc(2026, 10, 11, 13, 0, 0),
              relayCount: 0,
            ),
          );

          // Transition: pending -> acknowledged
          final ack = await endpoints.incident.updateIncidentStatus(
            dispatcherSession,
            incidentId,
            'acknowledged',
          );
          expect(ack.status, equals('acknowledged'));

          // Transition: acknowledged -> dispatched
          final disp = await endpoints.incident.updateIncidentStatus(
            dispatcherSession,
            incidentId,
            'dispatched',
          );
          expect(disp.status, equals('dispatched'));

          // Transition: dispatched -> resolved
          final res = await endpoints.incident.updateIncidentStatus(
            dispatcherSession,
            incidentId,
            'resolved',
          );
          expect(res.status, equals('resolved'));
          expect(res.resolvedAt, isNotNull);
        },
      );

      test(
        'when attempting invalid status transition then throws SosValidationException',
        () async {
          final incidentId = '44444444-5555-4666-8777-888888888881';
          await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: incidentId,
              latitude: 14.0,
              longitude: 81.0,
              createdAt: DateTime.utc(2026, 10, 11, 14, 0, 0),
              relayCount: 0,
            ),
          );

          // Resolve first
          await endpoints.incident.resolveIncident(
            dispatcherSession,
            incidentId,
          );

          // Attempt invalid backward transition: resolved -> pending
          expect(
            () => endpoints.incident.updateIncidentStatus(
              dispatcherSession,
              incidentId,
              'pending',
            ),
            throwsA(
              isA<SosValidationException>().having(
                (e) => e.field,
                'field',
                equals('status'),
              ),
            ),
          );
        },
      );

      test(
        'when resolving incident then records resolution timestamp and repeated calls are idempotent',
        () async {
          final incidentId = '55555555-6666-4777-8888-999999999991';
          await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: incidentId,
              latitude: 25.0,
              longitude: 85.0,
              createdAt: DateTime.utc(2026, 10, 11, 15, 0, 0),
              relayCount: 0,
            ),
          );

          // First resolution
          final resolvedFirst = await endpoints.incident.resolveIncident(
            dispatcherSession,
            incidentId,
          );
          expect(resolvedFirst.status, equals('resolved'));
          expect(resolvedFirst.resolvedAt, isNotNull);
          final firstResolvedAt = resolvedFirst.resolvedAt;

          // Second resolution call (idempotent)
          final resolvedSecond = await endpoints.incident.resolveIncident(
            dispatcherSession,
            incidentId,
          );
          expect(resolvedSecond.status, equals('resolved'));
          expect(resolvedSecond.resolvedAt, equals(firstResolvedAt));
        },
      );

      test(
        'when unauthenticated user calls updateIncidentStatus or resolveIncident then throws SosAuthorizationException',
        () async {
          final incidentId = '66666666-7777-4888-8999-000000000001';
          await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: incidentId,
              latitude: 21.0,
              longitude: 79.0,
              createdAt: DateTime.utc(2026, 10, 11, 9, 30, 0),
              relayCount: 0,
            ),
          );

          // Unauthenticated updateIncidentStatus
          expect(
            () => endpoints.incident.updateIncidentStatus(
              sessionBuilder,
              incidentId,
              'acknowledged',
            ),
            throwsA(
              isA<SosAuthorizationException>().having(
                (e) => e.reason,
                'reason',
                equals('unauthenticated'),
              ),
            ),
          );

          // Unauthenticated resolveIncident
          expect(
            () => endpoints.incident.resolveIncident(
              sessionBuilder,
              incidentId,
            ),
            throwsA(
              isA<SosAuthorizationException>().having(
                (e) => e.reason,
                'reason',
                equals('unauthenticated'),
              ),
            ),
          );
        },
      );

      test(
        'when non-dispatcher authenticated user calls updateIncidentStatus then throws SosAuthorizationException',
        () async {
          final incidentId = '77777777-8888-4999-8000-111111111111';
          await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: incidentId,
              latitude: 23.0,
              longitude: 83.0,
              createdAt: DateTime.utc(2026, 10, 11, 9, 45, 0),
              relayCount: 0,
            ),
          );

          // Civilian authenticated user lacks 'dispatcher' scope
          expect(
            () => endpoints.incident.updateIncidentStatus(
              civilianSession,
              incidentId,
              'acknowledged',
            ),
            throwsA(
              isA<SosAuthorizationException>().having(
                (e) => e.reason,
                'reason',
                equals('forbidden'),
              ),
            ),
          );
        },
      );
    });

    group('Responder Claiming', () {
      final dispatcher2Session = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          'dispatcher-2',
          {const Scope('dispatcher')},
        ),
      );

      test(
        'when authorized dispatcher claims unclaimed incident then succeeds',
        () async {
          final incidentId = '88888888-9999-4aaa-8bbb-000000000001';
          await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: incidentId,
              latitude: 27.0,
              longitude: 76.0,
              createdAt: DateTime.utc(2026, 10, 11, 8, 0, 0),
              relayCount: 0,
            ),
          );

          final claimed = await endpoints.incident.claimIncident(
            dispatcherSession,
            incidentId,
          );

          expect(claimed.claimedBy, equals('dispatcher-1'));
          expect(claimed.status, equals('acknowledged'));
          expect(claimed.lastUpdatedAt, isNotNull);
        },
      );

      test(
        'when unauthenticated user attempts to claim then throws SosAuthorizationException',
        () async {
          final incidentId = '88888888-9999-4aaa-8bbb-000000000002';
          await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: incidentId,
              latitude: 27.0,
              longitude: 76.0,
              createdAt: DateTime.utc(2026, 10, 11, 8, 0, 0),
              relayCount: 0,
            ),
          );

          expect(
            () => endpoints.incident.claimIncident(
              sessionBuilder,
              incidentId,
            ),
            throwsA(
              isA<SosAuthorizationException>().having(
                (e) => e.reason,
                'reason',
                equals('unauthenticated'),
              ),
            ),
          );
        },
      );

      test(
        'when authenticated non-dispatcher attempts to claim then throws SosAuthorizationException',
        () async {
          final incidentId = '88888888-9999-4aaa-8bbb-000000000003';
          await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: incidentId,
              latitude: 27.0,
              longitude: 76.0,
              createdAt: DateTime.utc(2026, 10, 11, 8, 0, 0),
              relayCount: 0,
            ),
          );

          expect(
            () => endpoints.incident.claimIncident(
              civilianSession,
              incidentId,
            ),
            throwsA(
              isA<SosAuthorizationException>().having(
                (e) => e.reason,
                'reason',
                equals('forbidden'),
              ),
            ),
          );
        },
      );

      test(
        'when second responder attempts to claim already claimed incident then throws SosClaimConflictException',
        () async {
          final incidentId = '88888888-9999-4aaa-8bbb-000000000004';
          await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: incidentId,
              latitude: 27.0,
              longitude: 76.0,
              createdAt: DateTime.utc(2026, 10, 11, 8, 0, 0),
              relayCount: 0,
            ),
          );

          // First claim by dispatcher-1
          await endpoints.incident.claimIncident(
            dispatcherSession,
            incidentId,
          );

          // Second claim by dispatcher-2 must be rejected
          await expectLater(
            () => endpoints.incident.claimIncident(
              dispatcher2Session,
              incidentId,
            ),
            throwsA(
              isA<SosClaimConflictException>()
                  .having(
                    (e) => e.claimedBy,
                    'claimedBy',
                    equals('dispatcher-1'),
                  )
                  .having(
                    (e) => e.incidentId,
                    'incidentId',
                    equals(incidentId),
                  ),
            ),
          );

          // Database still holds dispatcher-1
          final current = await endpoints.incident.getIncident(
            sessionBuilder,
            incidentId,
          );
          expect(current!.claimedBy, equals('dispatcher-1'));
        },
      );

      test(
        'when same responder claims incident again then operation is idempotent',
        () async {
          final incidentId = '88888888-9999-4aaa-8bbb-000000000005';
          await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: incidentId,
              latitude: 27.0,
              longitude: 76.0,
              createdAt: DateTime.utc(2026, 10, 11, 8, 0, 0),
              relayCount: 0,
            ),
          );

          final claim1 = await endpoints.incident.claimIncident(
            dispatcherSession,
            incidentId,
          );
          final claim2 = await endpoints.incident.claimIncident(
            dispatcherSession,
            incidentId,
          );

          expect(claim1.claimedBy, equals('dispatcher-1'));
          expect(claim2.claimedBy, equals('dispatcher-1'));
        },
      );

      test(
        'when claiming nonexistent incident then throws SosNotFoundException',
        () async {
          final nonexistentId = '88888888-9999-4aaa-8bbb-999999999999';
          expect(
            () => endpoints.incident.claimIncident(
              dispatcherSession,
              nonexistentId,
            ),
            throwsA(isA<SosNotFoundException>()),
          );
        },
      );

      test(
        'when claiming resolved incident then throws SosValidationException',
        () async {
          final incidentId = '88888888-9999-4aaa-8bbb-000000000006';
          await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: incidentId,
              latitude: 27.0,
              longitude: 76.0,
              createdAt: DateTime.utc(2026, 10, 11, 8, 0, 0),
              relayCount: 0,
            ),
          );

          await endpoints.incident.resolveIncident(
            dispatcherSession,
            incidentId,
          );

          expect(
            () => endpoints.incident.claimIncident(
              dispatcherSession,
              incidentId,
            ),
            throwsA(
              isA<SosValidationException>().having(
                (e) => e.field,
                'field',
                equals('status'),
              ),
            ),
          );
        },
      );

      test(
        'when another responder attempts to claim then conflict is detected and first claim is preserved',
        () async {
          final incidentId = '88888888-9999-4aaa-8bbb-000000000007';
          await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: incidentId,
              latitude: 27.0,
              longitude: 76.0,
              createdAt: DateTime.utc(2026, 10, 11, 8, 0, 0),
              relayCount: 0,
            ),
          );

          // Responder 1 claims
          final claim1 = await endpoints.incident.claimIncident(
            dispatcherSession,
            incidentId,
          );
          expect(claim1.claimedBy, equals('dispatcher-1'));

          // Responder 2 claims immediately after
          await expectLater(
            () => endpoints.incident.claimIncident(
              dispatcher2Session,
              incidentId,
            ),
            throwsA(
              isA<SosClaimConflictException>().having(
                (e) => e.claimedBy,
                'claimedBy',
                equals('dispatcher-1'),
              ),
            ),
          );

          // State is guaranteed preserved
          final finalState = await endpoints.incident.getIncident(
            sessionBuilder,
            incidentId,
          );
          expect(finalState!.claimedBy, equals('dispatcher-1'));
        },
      );
    });

    group('Deterministic Triage Integration', () {
      test(
        'when submitting incident with critical keywords then severity is critical',
        () async {
          final incidentId = '99999999-aaaa-4bbb-8ccc-000000000001';
          final response = await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: incidentId,
              latitude: 20.0,
              longitude: 75.0,
              createdAt: DateTime.utc(2026, 10, 11, 7, 0, 0),
              description: 'Two people trapped under collapsed wall',
              relayCount: 0,
            ),
          );

          expect(response.incident.severity, equals('critical'));
        },
      );

      test(
        'when submitting incident with high keywords then severity is high',
        () async {
          final incidentId = '99999999-aaaa-4bbb-8ccc-000000000002';
          final response = await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: incidentId,
              latitude: 20.0,
              longitude: 75.0,
              createdAt: DateTime.utc(2026, 10, 11, 7, 0, 0),
              description: 'Severe leg injury from falling debris, bleeding',
              relayCount: 0,
            ),
          );

          expect(response.incident.severity, equals('high'));
        },
      );

      test(
        'when submitting incident with supply requests then severity is low',
        () async {
          final incidentId = '99999999-aaaa-4bbb-8ccc-000000000003';
          final response = await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: incidentId,
              latitude: 20.0,
              longitude: 75.0,
              createdAt: DateTime.utc(2026, 10, 11, 7, 0, 0),
              description: 'Safe on second floor, extra drinking water needed',
              relayCount: 0,
            ),
          );

          expect(response.incident.severity, equals('low'));
        },
      );

      test(
        'when submitting incident with unclassified text then uses conservative default (medium)',
        () async {
          final incidentId = '99999999-aaaa-4bbb-8ccc-000000000004';
          final response = await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: incidentId,
              latitude: 20.0,
              longitude: 75.0,
              createdAt: DateTime.utc(2026, 10, 11, 7, 0, 0),
              description: 'Location report near primary school',
              relayCount: 0,
            ),
          );

          expect(response.incident.severity, equals('medium'));
        },
      );

      test(
        'when duplicate SOS is received then existing severity is preserved and not corrupted',
        () async {
          final incidentId = '99999999-aaaa-4bbb-8ccc-000000000005';
          final initialRes = await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: incidentId,
              latitude: 20.0,
              longitude: 75.0,
              createdAt: DateTime.utc(2026, 10, 11, 7, 0, 0),
              description: 'Victim buried and trapped under rubble',
              relayCount: 0,
            ),
          );
          expect(initialRes.incident.severity, equals('critical'));

          // Duplicate transmission with low-severity wording
          final dupeRes = await endpoints.incident.submitSos(
            sessionBuilder,
            SosSubmissionPayload(
              incidentId: incidentId,
              latitude: 20.0,
              longitude: 75.0,
              createdAt: DateTime.utc(2026, 10, 11, 7, 0, 0),
              description: 'Blanket and supplies needed',
              relayCount: 3,
            ),
          );

          expect(dupeRes.isNew, isFalse);
          expect(
            dupeRes.incident.severity,
            equals('critical'),
            reason:
                'Existing incident severity must not be overwritten by duplicate SOS',
          );
        },
      );
    });
  });
}
