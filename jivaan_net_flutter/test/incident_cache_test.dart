import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jivaan_net_client/jivaan_net_client.dart';
import 'package:jivaan_net_flutter/screens/requests/my_sos_requests_screen.dart';
import 'package:jivaan_net_flutter/services/incident_cache_service.dart';

void main() {
  group('IncidentCacheService In-Memory & Fallback Tests', () {
    test(
      'saveIncidents and getCachedIncidents preserve incident data',
      () async {
        final cacheService = IncidentCacheService();
        final incident = SosIncident(
          incidentId: 'test-incident-uuid-001',
          latitude: 26.9124,
          longitude: 75.7873,
          createdAt: DateTime.utc(2026, 10, 13, 10, 0),
          receivedAt: DateTime.utc(2026, 10, 13, 10, 1),
          status: 'pending',
          severity: 'critical',
          description: 'Building collapse test',
          relayCount: 0,
          lastUpdatedAt: DateTime.utc(2026, 10, 13, 10, 1),
        );

        await cacheService.saveIncidents([incident]);

        final cached = await cacheService.getCachedIncidents();
        expect(cached.length, equals(1));
        expect(cached.first.incidentId, equals('test-incident-uuid-001'));
        expect(cached.first.description, equals('Building collapse test'));
        expect(cached.first.severity, equals('critical'));

        final cacheTime = await cacheService.getLastCacheTime();
        expect(cacheTime, isNotNull);

        await cacheService.clearCache();
        final cleared = await cacheService.getCachedIncidents();
        expect(cleared, isEmpty);
      },
    );
  });

  group('MySosRequestsScreen Offline Caching Widget Tests', () {
    testWidgets(
      'displays cached incidents and offline banner when backend is unreachable',
      (WidgetTester tester) async {
        final cacheService = IncidentCacheService();
        final cachedIncident = SosIncident(
          incidentId: 'cached-uuid-12345678',
          latitude: 28.6139,
          longitude: 77.2090,
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          receivedAt: DateTime.now().subtract(const Duration(minutes: 5)),
          status: 'pending',
          severity: 'high',
          description: 'Trapped under debris, need immediate help',
          relayCount: 1,
          lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        );

        // Pre-populate cache
        await cacheService.saveIncidents([cachedIncident]);

        // Pump MySosRequestsScreen with a disconnected mock client (or default which fails to connect)
        await tester.pumpWidget(
          MaterialApp(
            home: MySosRequestsScreen(
              showBackButton: false,
              cacheService: cacheService,
            ),
          ),
        );

        // Allow microtasks and initial cache read to complete
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Verify cached incident is visible immediately
        expect(
          find.text('Trapped under debris, need immediate help'),
          findsOneWidget,
        );
        expect(find.textContaining('CACHEDUU'), findsOneWidget);

        // Verify offline indicator banner is present
        expect(
          find.textContaining('Offline Mode • Showing cached incidents'),
          findsOneWidget,
        );
        expect(find.text('Retry'), findsOneWidget);
      },
    );

    testWidgets(
      'displays clear offline error when no cache exists and backend is unreachable',
      (WidgetTester tester) async {
        final cacheService = IncidentCacheService();
        await cacheService.clearCache();

        await tester.pumpWidget(
          MaterialApp(
            home: MySosRequestsScreen(
              showBackButton: false,
              cacheService: cacheService,
            ),
          ),
        );

        // Allow microtasks to complete
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // When connection fails and no cache exists, shows offline message
        expect(find.text('Offline — No Cached Incidents'), findsOneWidget);
        expect(find.text('Retry Connection'), findsOneWidget);
      },
    );
  });
}
