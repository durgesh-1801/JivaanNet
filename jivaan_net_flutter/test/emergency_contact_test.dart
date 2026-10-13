import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jivaan_net_flutter/models/emergency_contact.dart';
import 'package:jivaan_net_flutter/screens/contacts/emergency_contacts_screen.dart';
import 'package:jivaan_net_flutter/services/emergency_contact_service.dart';

void main() {
  group('EmergencyContact Model Tests', () {
    test('toMap and fromMap serialize and deserialize correctly', () {
      const contact = EmergencyContact(
        id: 'c_test_1',
        name: 'Dr. John Doe',
        phone: '+91 98765 00000',
        isPrimary: true,
      );

      final map = contact.toMap();
      expect(map['id'], equals('c_test_1'));
      expect(map['name'], equals('Dr. John Doe'));
      expect(map['phone'], equals('+91 98765 00000'));
      expect(map['is_primary'], equals(1));

      final restored = EmergencyContact.fromMap(map);
      expect(restored, equals(contact));
      expect(restored.isPrimary, isTrue);
    });

    test('copyWith updates fields as expected', () {
      const contact = EmergencyContact(
        id: 'c1',
        name: 'Jane',
        phone: '1234',
        isPrimary: false,
      );

      final updated = contact.copyWith(isPrimary: true, name: 'Jane Doe');
      expect(updated.id, equals('c1'));
      expect(updated.name, equals('Jane Doe'));
      expect(updated.isPrimary, isTrue);
    });
  });

  group('EmergencyContactService In-Memory & Persistence Tests', () {
    test('loads initial seeded contacts on first call', () async {
      final service = EmergencyContactService();
      final contacts = await service.getContacts();

      expect(contacts.isNotEmpty, isTrue);
      expect(contacts.any((c) => c.name == 'Mom'), isTrue);
      expect(contacts.any((c) => c.isPrimary), isTrue);
    });

    test(
      'addContact adds contact and setPrimary updates primary status',
      () async {
        final service = EmergencyContactService();
        const newContact = EmergencyContact(
          id: 'c_doctor',
          name: 'Emergency Clinic',
          phone: '+91 11 2233 4455',
          isPrimary: false,
        );

        await service.addContact(newContact);
        var contacts = await service.getContacts();
        expect(contacts.any((c) => c.id == 'c_doctor'), isTrue);

        // Set new contact as primary
        await service.setPrimaryContact('c_doctor');
        contacts = await service.getContacts();
        final doctor = contacts.firstWhere((c) => c.id == 'c_doctor');
        expect(doctor.isPrimary, isTrue);

        final mom = contacts.firstWhere((c) => c.name == 'Mom');
        expect(mom.isPrimary, isFalse);

        // Check getPrimaryContact
        final primary = await service.getPrimaryContact();
        expect(primary?.id, equals('c_doctor'));
      },
    );

    test('deleteContact removes contact', () async {
      final service = EmergencyContactService();
      await service.deleteContact('c_doctor');
      final contacts = await service.getContacts();
      expect(contacts.any((c) => c.id == 'c_doctor'), isFalse);
    });

    test(
      'clearContacts empties list and does not re-seed automatically',
      () async {
        final service = EmergencyContactService();
        await service.clearContacts();
        final contacts = await service.getContacts();
        expect(contacts, isEmpty);
      },
    );
  });

  group('EmergencyContactsScreen Widget Tests', () {
    testWidgets('renders contacts and primary badge', (
      WidgetTester tester,
    ) async {
      final service = EmergencyContactService();
      // Re-seed with test contacts
      await service.clearContacts();
      await service.addContact(
        const EmergencyContact(
          id: 't1',
          name: 'Primary Contact Test',
          phone: '+91 12345 67890',
          isPrimary: true,
        ),
      );
      await service.addContact(
        const EmergencyContact(
          id: 't2',
          name: 'Secondary Contact Test',
          phone: '+91 98765 43210',
          isPrimary: false,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EmergencyContactsScreen(
            showBackButton: false,
            contactService: service,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Primary Contact Test'), findsOneWidget);
      expect(find.text('Secondary Contact Test'), findsOneWidget);
      expect(find.text('Primary'), findsOneWidget);
    });

    testWidgets('displays empty state when no contacts exist', (
      WidgetTester tester,
    ) async {
      final service = EmergencyContactService();
      await service.clearContacts();

      await tester.pumpWidget(
        MaterialApp(
          home: EmergencyContactsScreen(
            showBackButton: false,
            contactService: service,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Emergency Contacts'), findsOneWidget);
      expect(find.text('Add Contact'), findsOneWidget);
    });

    testWidgets('adds contact via dialog and updates screen', (
      WidgetTester tester,
    ) async {
      final service = EmergencyContactService();
      await service.clearContacts();

      await tester.pumpWidget(
        MaterialApp(
          home: EmergencyContactsScreen(
            showBackButton: false,
            contactService: service,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Add Contact button in empty state
      await tester.tap(find.text('Add Contact'));
      await tester.pumpAndSettle();

      expect(find.text('Add Emergency Contact'), findsOneWidget);

      // Enter name and phone
      await tester.enterText(find.byType(TextField).first, 'Uncle Bob');
      await tester.enterText(find.byType(TextField).last, '+91 98888 77777');

      // Tap Add in dialog
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pumpAndSettle();

      expect(find.text('Uncle Bob'), findsOneWidget);
      expect(find.text('+91 98888 77777'), findsOneWidget);

      // First contact added should automatically be primary
      expect(find.text('Primary'), findsOneWidget);
    });
  });
}
