import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:jivaan_net_client/jivaan_net_client.dart';
import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

/// Persistent local cache service for Serverpod [SosIncident] records.
///
/// Stores fetched incidents in local SQLite storage to enable instant offline
/// display when connectivity is unavailable. Includes an in-memory fallback
/// to gracefully handle environments where SQLite platform channels are absent.
class IncidentCacheService {
  final AppDatabase _appDb;
  List<SosIncident>? _memoryCache;
  DateTime? _memoryCacheTime;

  IncidentCacheService({AppDatabase? appDb})
    : _appDb = appDb ?? AppDatabase.instance;

  Future<Database?> _getDatabase() => _appDb.getDatabase();

  /// Persists a list of [SosIncident] items to local storage.
  Future<void> saveIncidents(List<SosIncident> incidents) async {
    final now = DateTime.now();
    _memoryCache = List<SosIncident>.unmodifiable(incidents);
    _memoryCacheTime = now;

    final db = await _getDatabase();
    if (db == null) return;

    try {
      await db.transaction((txn) async {
        await txn.delete(AppDatabase.incidentsTable);
        final batch = txn.batch();
        for (final incident in incidents) {
          final jsonStr = jsonEncode(incident.toJson());
          batch.insert(AppDatabase.incidentsTable, {
            'incident_id': incident.incidentId,
            'data_json': jsonStr,
            'created_at_epoch': incident.createdAt.millisecondsSinceEpoch,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        batch.insert(AppDatabase.metaTable, {
          'key': 'last_cached_at',
          'value': now.toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
        await batch.commit(noResult: true);
      });
    } catch (e) {
      debugPrint('IncidentCacheService: Failed to persist to SQLite: $e');
    }
  }

  /// Loads previously cached incidents from local storage.
  ///
  /// Returns an empty list if no incidents have been cached yet.
  Future<List<SosIncident>> getCachedIncidents() async {
    final db = await _getDatabase();
    if (db == null) {
      return _memoryCache != null ? List<SosIncident>.from(_memoryCache!) : [];
    }

    try {
      final rows = await db.query(
        AppDatabase.incidentsTable,
        orderBy: 'created_at_epoch DESC',
      );

      final list = <SosIncident>[];
      for (final row in rows) {
        final jsonStr = row['data_json'] as String;
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        list.add(SosIncident.fromJson(map));
      }

      _memoryCache = List<SosIncident>.unmodifiable(list);
      return list;
    } catch (e) {
      debugPrint('IncidentCacheService: Failed to read from SQLite: $e');
      return _memoryCache != null ? List<SosIncident>.from(_memoryCache!) : [];
    }
  }

  /// Returns the timestamp when the incident cache was last updated, or `null`.
  Future<DateTime?> getLastCacheTime() async {
    if (_memoryCacheTime != null) return _memoryCacheTime;

    final db = await _getDatabase();
    if (db == null) return _memoryCacheTime;

    try {
      final rows = await db.query(
        AppDatabase.metaTable,
        where: 'key = ?',
        whereArgs: ['last_cached_at'],
      );

      if (rows.isNotEmpty) {
        final val = rows.first['value'] as String;
        final parsed = DateTime.tryParse(val);
        _memoryCacheTime = parsed;
        return parsed;
      }
    } catch (e) {
      debugPrint('IncidentCacheService: Failed to read last_cached_at: $e');
    }

    return _memoryCacheTime;
  }

  /// Clears all cached incidents and metadata from local storage.
  Future<void> clearCache() async {
    _memoryCache = null;
    _memoryCacheTime = null;

    final db = await _getDatabase();
    if (db == null) return;

    try {
      await db.delete(AppDatabase.incidentsTable);
      await db.delete(AppDatabase.metaTable);
    } catch (e) {
      debugPrint('IncidentCacheService: Failed to clear SQLite cache: $e');
    }
  }
}
