import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jivaan_net_flutter/models/emergency_contact.dart';
import 'package:jivaan_net_flutter/screens/sos/confirm_sos_screen.dart';
import 'package:jivaan_net_flutter/services/emergency_contact_service.dart';
import 'package:jivaan_net_flutter/services/emergency_sms_preview_service.dart';

void main() {
  group('EmergencySmsPreviewService Message Construction Tests', () {
    test('buildTestEmergencyMessage includes required test drill markers and location link', () {
      final msg = EmergencySmsPreviewService.buildTestEmergencyMessage(
        incidentId: 'test-uuid-12345678',
        latitude: 26.9124,
        longitude: 75.7873,
        categoryLabel: 'Medical',
        description: 'Need immediate first aid kit.',
      );

      // 1. Must contain test drill warning
      expect(msg, contains('[TEST DRILL — DO NOT DISPATCH]'));

      // 2. Must clearly state this is a drill / not real
      expect(msg, contains('This is NOT a real emergency'));
      expect(msg, contains('Do not contact emergency services'));

      // 3. Must include incident ID
      expect(msg, contains('Incident ID: #TESTUUID'));

      // 4. Must include coordinates
      expect(msg, contains('GPS Coordinates: 26.9124° N, 75.7873° E'));

      // 5. Must include Google Maps link
      expect(msg, contains('https://maps.google.com/?q=26.9124,75.7873'));

      // 6. Must include details and category
      expect(msg, contains('Medical'));
      expect(msg, contains('Need immediate first aid kit.'));
    });

    test(
      'buildTestEmergencyMessage handles missing coordinates gracefully',
      () {
        final msg = EmergencySmsPreviewService.buildTestEmergencyMessage(
          incidentId: 'no-gps-test',
          latitude: null,
          longitude: null,
          categoryLabel: 'Rescue',
        );

        expect(msg, contains('[TEST DRILL — DO NOT DISPATCH]'));
        expect(msg, contains('Location unavailable (test drill mode)'));
        expect(msg, isNot(contains('https://maps.google.com/')));
      },
    );

    test('createSmsUri constructs properly formatted SMS URI', () {
      final uri = EmergencySmsPreviewService.createSmsUri(
        '+91 98765 43210',
        'Hello World Test',
      );

      expect(uri.scheme, equals('sms'));
      expect(uri.path, equals('+919876543210'));
      expect(uri.queryParameters['body'], equals('Hello World Test'));
    });
  });

  group('ConfirmSosScreen Emergency SMS Preview Widget Tests', () {
    testWidgets(
      'renders Preview Emergency SMS action and primary contact details',
      (WidgetTester tester) async {
        final contactService = EmergencyContactService();
        await contactService.clearContacts();
        await contactService.addContact(
          const EmergencyContact(
            id: 'primary_1',
            name: 'Dad',
            phone: '+91 98765 00000',
            isPrimary: true,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(home: ConfirmSosScreen(contactService: contactService)),
        );

        await tester.pumpAndSettle();

        // Check section header and button
        expect(find.text('Emergency Contacts (Test Mode)'), findsOneWidget);
        expect(find.text('Preview Emergency SMS (Test Mode)'), findsOneWidget);
        expect(find.textContaining('Dad (+91 98765 00000)'), findsOneWidget);
      },
    );

    testWidgets(
      'shows No Primary Contact dialog when no primary contact exists',
      (WidgetTester tester) async {
        final contactService = EmergencyContactService();
        await contactService.clearContacts();

        await tester.pumpWidget(
          MaterialApp(home: ConfirmSosScreen(contactService: contactService)),
        );

        await tester.pumpAndSettle();

        // Ensure Preview Emergency SMS button is visible in scroll view and tap it
        final previewButton = find.text('Preview Emergency SMS (Test Mode)');
        expect(previewButton, findsOneWidget);
        await tester.ensureVisible(previewButton);
        await tester.pumpAndSettle();

        await tester.tap(previewButton);
        await tester.pumpAndSettle();

        // Verify prompt dialog directing user to configure contacts
        expect(find.text('No Primary Contact'), findsOneWidget);
        expect(find.text('Configure Contacts'), findsOneWidget);
        expect(
          find.textContaining(
            'Please configure a primary contact in Emergency Contacts',
          ),
          findsOneWidget,
        );
      },
    );
  });
}
