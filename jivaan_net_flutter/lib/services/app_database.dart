import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Centralized SQLite database manager for JivaanNet.
///
/// Coordinates schema creation, migrations, and shared connections across
/// services (incident caching, emergency contacts).
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const String dbName = 'jivaan_net_incidents_cache.db';
  static const int currentVersion = 2;

  static const String incidentsTable = 'cached_incidents';
  static const String metaTable = 'cache_metadata';
  static const String contactsTable = 'emergency_contacts';

  Database? _db;
  bool _sqliteDisabled = false;

  /// Retrieves or opens the shared SQLite database instance.
  Future<Database?> getDatabase() async {
    if (_sqliteDisabled) return null;
    if (_db != null && _db!.isOpen) return _db;

    try {
      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, dbName);

      _db = await openDatabase(
        path,
        version: currentVersion,
        onCreate: (db, version) async {
          await _createTablesV1(db);
          await _createContactsTableV2(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await _createContactsTableV2(db);
          }
        },
      );
      return _db;
    } catch (e) {
      _sqliteDisabled = true;
      debugPrint(
        'AppDatabase: SQLite unavailable ($e), falling back to in-memory mode.',
      );
      return null;
    }
  }

  static Future<void> _createTablesV1(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $incidentsTable (
        incident_id TEXT PRIMARY KEY,
        data_json TEXT NOT NULL,
        created_at_epoch INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $metaTable (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createContactsTableV2(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $contactsTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        is_primary INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  /// Sets custom database or resets state for unit and widget testing.
  @visibleForTesting
  void setDatabaseForTesting(Database? db) {
    _db = db;
    _sqliteDisabled = (db == null);
  }

  /// Clears closed database references.
  @visibleForTesting
  void reset() {
    _db = null;
    _sqliteDisabled = false;
  }
}
