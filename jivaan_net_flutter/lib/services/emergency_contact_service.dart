import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../models/emergency_contact.dart';
import 'app_database.dart';

/// Persistent service managing trusted emergency contacts in local SQLite storage.
///
/// Ensures user-added contacts, deletions, and primary status persist across
/// sessions, screen changes, and app restarts.
class EmergencyContactService {
  final AppDatabase _appDb;
  List<EmergencyContact>? _memoryCache;
  bool _memorySeeded = false;

  EmergencyContactService({AppDatabase? appDb})
    : _appDb = appDb ?? AppDatabase.instance;

  Future<Database?> _getDatabase() => _appDb.getDatabase();

  /// Default baseline contacts initially provided on fresh installations.
  static const List<EmergencyContact> initialMockContacts = [
    EmergencyContact(
      id: 'c1',
      name: 'Mom',
      phone: '+91 98765 43210',
      isPrimary: true,
    ),
    EmergencyContact(
      id: 'c2',
      name: 'Dad',
      phone: '+91 98765 43211',
      isPrimary: false,
    ),
    EmergencyContact(
      id: 'c3',
      name: 'Sibling',
      phone: '+91 98765 43212',
      isPrimary: false,
    ),
    EmergencyContact(
      id: 'c4',
      name: 'Friend',
      phone: '+91 98765 43213',
      isPrimary: false,
    ),
  ];

  /// Loads all stored emergency contacts, ordered with the primary contact first.
  Future<List<EmergencyContact>> getContacts() async {
    final db = await _getDatabase();
    if (db == null) {
      if (_memoryCache == null) {
        if (!_memorySeeded) {
          _memoryCache = List.from(initialMockContacts);
          _memorySeeded = true;
        } else {
          _memoryCache = [];
        }
      }
      final sorted = List<EmergencyContact>.from(_memoryCache!)
        ..sort((a, b) {
          if (a.isPrimary != b.isPrimary) {
            return a.isPrimary ? -1 : 1;
          }
          return a.name.compareTo(b.name);
        });
      return sorted;
    }

    try {
      // Check if initial seeding has already occurred
      final metaRows = await db.query(
        AppDatabase.metaTable,
        where: 'key = ?',
        whereArgs: ['contacts_seeded'],
      );

      if (metaRows.isEmpty) {
        // First run: seed initial contacts into database
        await db.transaction((txn) async {
          for (final c in initialMockContacts) {
            await txn.insert(
              AppDatabase.contactsTable,
              c.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
          await txn.insert(AppDatabase.metaTable, {
            'key': 'contacts_seeded',
            'value': 'true',
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        });
      }

      final rows = await db.query(
        AppDatabase.contactsTable,
        orderBy: 'is_primary DESC, name ASC',
      );

      final contacts = rows.map((r) => EmergencyContact.fromMap(r)).toList();
      _memoryCache = List.unmodifiable(contacts);
      return contacts;
    } catch (e) {
      debugPrint('EmergencyContactService: Error fetching contacts: $e');
      return _memoryCache != null
          ? List<EmergencyContact>.from(_memoryCache!)
          : [];
    }
  }

  /// Adds a new emergency contact to persistent storage.
  Future<void> addContact(EmergencyContact contact) async {
    final db = await _getDatabase();

    // If marked as primary, reset all other contacts' primary flag
    if (contact.isPrimary) {
      await _demoteAllPrimary(db);
    }

    if (db != null) {
      try {
        await db.insert(
          AppDatabase.contactsTable,
          contact.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (e) {
        debugPrint('EmergencyContactService: Error inserting contact: $e');
      }
    }

    // Update in-memory state
    final current = await getContacts();
    final updated = List<EmergencyContact>.from(current)
      ..removeWhere((c) => c.id == contact.id);

    if (contact.isPrimary) {
      for (var i = 0; i < updated.length; i++) {
        if (updated[i].isPrimary) {
          updated[i] = updated[i].copyWith(isPrimary: false);
        }
      }
    }

    updated.add(contact);
    _memoryCache = List.unmodifiable(updated);
  }

  /// Sets a specific contact as primary and demotes all other contacts.
  Future<void> setPrimaryContact(String id) async {
    final db = await _getDatabase();
    if (db != null) {
      try {
        await db.transaction((txn) async {
          await txn.update(AppDatabase.contactsTable, {'is_primary': 0});
          await txn.update(
            AppDatabase.contactsTable,
            {'is_primary': 1},
            where: 'id = ?',
            whereArgs: [id],
          );
        });
      } catch (e) {
        debugPrint(
          'EmergencyContactService: Error setting primary contact: $e',
        );
      }
    }

    if (_memoryCache != null) {
      final updated = _memoryCache!.map((c) {
        return c.copyWith(isPrimary: c.id == id);
      }).toList();
      _memoryCache = List.unmodifiable(updated);
    }
  }

  /// Deletes a contact by identifier from persistent storage.
  Future<void> deleteContact(String id) async {
    final db = await _getDatabase();
    if (db != null) {
      try {
        await db.delete(
          AppDatabase.contactsTable,
          where: 'id = ?',
          whereArgs: [id],
        );
      } catch (e) {
        debugPrint('EmergencyContactService: Error deleting contact: $e');
      }
    }

    if (_memoryCache != null) {
      final updated = List<EmergencyContact>.from(_memoryCache!)
        ..removeWhere((c) => c.id == id);
      _memoryCache = List.unmodifiable(updated);
    }
  }

  /// Retrieves the current primary contact, if one is designated.
  Future<EmergencyContact?> getPrimaryContact() async {
    final contacts = await getContacts();
    try {
      return contacts.firstWhere((c) => c.isPrimary);
    } catch (_) {
      return null;
    }
  }

  /// Clears all stored contacts from storage.
  Future<void> clearContacts() async {
    _memoryCache = [];
    _memorySeeded = true;

    final db = await _getDatabase();
    if (db == null) return;

    try {
      await db.delete(AppDatabase.contactsTable);
      await db.insert(AppDatabase.metaTable, {
        'key': 'contacts_seeded',
        'value': 'true',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint('EmergencyContactService: Error clearing contacts: $e');
    }
  }

  Future<void> _demoteAllPrimary(Database? db) async {
    if (db != null) {
      try {
        await db.update(AppDatabase.contactsTable, {'is_primary': 0});
      } catch (e) {
        debugPrint(
          'EmergencyContactService: Error demoting primary contacts: $e',
        );
      }
    }
    if (_memoryCache != null) {
      final updated = _memoryCache!
          .map((c) => c.copyWith(isPrimary: false))
          .toList();
      _memoryCache = List.unmodifiable(updated);
    }
  }
}
