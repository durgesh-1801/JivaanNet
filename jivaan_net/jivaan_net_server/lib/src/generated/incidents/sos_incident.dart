/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;

/// SOS Incident reported by a device or mesh network in emergency response.
abstract class SosIncident
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  SosIncident._({
    this.id,
    required this.incidentId,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.receivedAt,
    required this.status,
    required this.severity,
    this.description,
    this.sourceDeviceId,
    required this.relayCount,
    required this.lastUpdatedAt,
    this.claimedBy,
    this.resolvedAt,
  });

  factory SosIncident({
    int? id,
    required String incidentId,
    required double latitude,
    required double longitude,
    required DateTime createdAt,
    required DateTime receivedAt,
    required String status,
    required String severity,
    String? description,
    String? sourceDeviceId,
    required int relayCount,
    required DateTime lastUpdatedAt,
    String? claimedBy,
    DateTime? resolvedAt,
  }) = _SosIncidentImpl;

  factory SosIncident.fromJson(Map<String, dynamic> jsonSerialization) {
    return SosIncident(
      id: jsonSerialization['id'] as int?,
      incidentId: jsonSerialization['incidentId'] as String,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      receivedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
      status: jsonSerialization['status'] as String,
      severity: jsonSerialization['severity'] as String,
      description: jsonSerialization['description'] as String?,
      sourceDeviceId: jsonSerialization['sourceDeviceId'] as String?,
      relayCount: jsonSerialization['relayCount'] as int,
      lastUpdatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastUpdatedAt'],
      ),
      claimedBy: jsonSerialization['claimedBy'] as String?,
      resolvedAt: jsonSerialization['resolvedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['resolvedAt']),
    );
  }

  static final t = SosIncidentTable();

  static const db = SosIncidentRepository._();

  @override
  int? id;

  /// Client-generated UUID identifying the original SOS incident for idempotency.
  String incidentId;

  /// Geographic latitude of the incident.
  double latitude;

  /// Geographic longitude of the incident.
  double longitude;

  /// Original creation time of the incident on the device (preserves offline timestamp).
  DateTime createdAt;

  /// Time when the server received and ingested the incident.
  DateTime receivedAt;

  /// Current status of the incident (e.g., pending, acknowledged, dispatched, resolved).
  String status;

  /// Priority classification of the incident (e.g., low, medium, high, critical).
  String severity;

  /// Optional short description or notes regarding the incident.
  String? description;

  /// Optional pseudonymous identifier of the source device that created the SOS.
  String? sourceDeviceId;

  /// Number of hops/relays reported by mesh sync.
  int relayCount;

  /// Timestamp of the latest update to this incident.
  DateTime lastUpdatedAt;

  /// Optional identifier of the responder who claimed the incident.
  String? claimedBy;

  /// Timestamp when the incident was marked resolved.
  DateTime? resolvedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [SosIncident]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SosIncident copyWith({
    int? id,
    String? incidentId,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? receivedAt,
    String? status,
    String? severity,
    String? description,
    String? sourceDeviceId,
    int? relayCount,
    DateTime? lastUpdatedAt,
    String? claimedBy,
    DateTime? resolvedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SosIncident',
      if (id != null) 'id': id,
      'incidentId': incidentId,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toJson(),
      'receivedAt': receivedAt.toJson(),
      'status': status,
      'severity': severity,
      if (description != null) 'description': description,
      if (sourceDeviceId != null) 'sourceDeviceId': sourceDeviceId,
      'relayCount': relayCount,
      'lastUpdatedAt': lastUpdatedAt.toJson(),
      if (claimedBy != null) 'claimedBy': claimedBy,
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SosIncident',
      if (id != null) 'id': id,
      'incidentId': incidentId,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toJson(),
      'receivedAt': receivedAt.toJson(),
      'status': status,
      'severity': severity,
      if (description != null) 'description': description,
      if (sourceDeviceId != null) 'sourceDeviceId': sourceDeviceId,
      'relayCount': relayCount,
      'lastUpdatedAt': lastUpdatedAt.toJson(),
      if (claimedBy != null) 'claimedBy': claimedBy,
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
    };
  }

  static SosIncidentInclude include() {
    return SosIncidentInclude._();
  }

  static SosIncidentIncludeList includeList({
    _is.WhereExpressionBuilder<SosIncidentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SosIncidentTable>? orderBy,
    _is.OrderByListBuilder<SosIncidentTable>? orderByList,
    SosIncidentInclude? include,
  }) {
    return SosIncidentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SosIncident.t),
      orderByList: orderByList?.call(SosIncident.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SosIncidentImpl extends SosIncident {
  _SosIncidentImpl({
    int? id,
    required String incidentId,
    required double latitude,
    required double longitude,
    required DateTime createdAt,
    required DateTime receivedAt,
    required String status,
    required String severity,
    String? description,
    String? sourceDeviceId,
    required int relayCount,
    required DateTime lastUpdatedAt,
    String? claimedBy,
    DateTime? resolvedAt,
  }) : super._(
         id: id,
         incidentId: incidentId,
         latitude: latitude,
         longitude: longitude,
         createdAt: createdAt,
         receivedAt: receivedAt,
         status: status,
         severity: severity,
         description: description,
         sourceDeviceId: sourceDeviceId,
         relayCount: relayCount,
         lastUpdatedAt: lastUpdatedAt,
         claimedBy: claimedBy,
         resolvedAt: resolvedAt,
       );

  /// Returns a shallow copy of this [SosIncident]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SosIncident copyWith({
    Object? id = _Undefined,
    String? incidentId,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? receivedAt,
    String? status,
    String? severity,
    Object? description = _Undefined,
    Object? sourceDeviceId = _Undefined,
    int? relayCount,
    DateTime? lastUpdatedAt,
    Object? claimedBy = _Undefined,
    Object? resolvedAt = _Undefined,
  }) {
    return SosIncident(
      id: id is int? ? id : this.id,
      incidentId: incidentId ?? this.incidentId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      receivedAt: receivedAt ?? this.receivedAt,
      status: status ?? this.status,
      severity: severity ?? this.severity,
      description: description is String? ? description : this.description,
      sourceDeviceId: sourceDeviceId is String?
          ? sourceDeviceId
          : this.sourceDeviceId,
      relayCount: relayCount ?? this.relayCount,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      claimedBy: claimedBy is String? ? claimedBy : this.claimedBy,
      resolvedAt: resolvedAt is DateTime? ? resolvedAt : this.resolvedAt,
    );
  }
}

class SosIncidentUpdateTable extends _is.UpdateTable<SosIncidentTable> {
  SosIncidentUpdateTable(super.table);

  _is.ColumnValue<String, String> incidentId(String value) => _is.ColumnValue(
    table.incidentId,
    value,
  );

  _is.ColumnValue<double, double> latitude(double value) => _is.ColumnValue(
    table.latitude,
    value,
  );

  _is.ColumnValue<double, double> longitude(double value) => _is.ColumnValue(
    table.longitude,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> receivedAt(DateTime value) =>
      _is.ColumnValue(
        table.receivedAt,
        value,
      );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> severity(String value) => _is.ColumnValue(
    table.severity,
    value,
  );

  _is.ColumnValue<String, String> description(String? value) => _is.ColumnValue(
    table.description,
    value,
  );

  _is.ColumnValue<String, String> sourceDeviceId(String? value) =>
      _is.ColumnValue(
        table.sourceDeviceId,
        value,
      );

  _is.ColumnValue<int, int> relayCount(int value) => _is.ColumnValue(
    table.relayCount,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> lastUpdatedAt(DateTime value) =>
      _is.ColumnValue(
        table.lastUpdatedAt,
        value,
      );

  _is.ColumnValue<String, String> claimedBy(String? value) => _is.ColumnValue(
    table.claimedBy,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> resolvedAt(DateTime? value) =>
      _is.ColumnValue(
        table.resolvedAt,
        value,
      );
}

class SosIncidentTable extends _is.Table<int?> {
  SosIncidentTable({super.tableRelation}) : super(tableName: 'sos_incident') {
    updateTable = SosIncidentUpdateTable(this);
    incidentId = _is.ColumnString(
      'incidentId',
      this,
    );
    latitude = _is.ColumnDouble(
      'latitude',
      this,
    );
    longitude = _is.ColumnDouble(
      'longitude',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    receivedAt = _is.ColumnDateTime(
      'receivedAt',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    severity = _is.ColumnString(
      'severity',
      this,
    );
    description = _is.ColumnString(
      'description',
      this,
    );
    sourceDeviceId = _is.ColumnString(
      'sourceDeviceId',
      this,
    );
    relayCount = _is.ColumnInt(
      'relayCount',
      this,
    );
    lastUpdatedAt = _is.ColumnDateTime(
      'lastUpdatedAt',
      this,
    );
    claimedBy = _is.ColumnString(
      'claimedBy',
      this,
    );
    resolvedAt = _is.ColumnDateTime(
      'resolvedAt',
      this,
    );
  }

  late final SosIncidentUpdateTable updateTable;

  /// Client-generated UUID identifying the original SOS incident for idempotency.
  late final _is.ColumnString incidentId;

  /// Geographic latitude of the incident.
  late final _is.ColumnDouble latitude;

  /// Geographic longitude of the incident.
  late final _is.ColumnDouble longitude;

  /// Original creation time of the incident on the device (preserves offline timestamp).
  late final _is.ColumnDateTime createdAt;

  /// Time when the server received and ingested the incident.
  late final _is.ColumnDateTime receivedAt;

  /// Current status of the incident (e.g., pending, acknowledged, dispatched, resolved).
  late final _is.ColumnString status;

  /// Priority classification of the incident (e.g., low, medium, high, critical).
  late final _is.ColumnString severity;

  /// Optional short description or notes regarding the incident.
  late final _is.ColumnString description;

  /// Optional pseudonymous identifier of the source device that created the SOS.
  late final _is.ColumnString sourceDeviceId;

  /// Number of hops/relays reported by mesh sync.
  late final _is.ColumnInt relayCount;

  /// Timestamp of the latest update to this incident.
  late final _is.ColumnDateTime lastUpdatedAt;

  /// Optional identifier of the responder who claimed the incident.
  late final _is.ColumnString claimedBy;

  /// Timestamp when the incident was marked resolved.
  late final _is.ColumnDateTime resolvedAt;

  @override
  List<_is.Column> get columns => [
    id,
    incidentId,
    latitude,
    longitude,
    createdAt,
    receivedAt,
    status,
    severity,
    description,
    sourceDeviceId,
    relayCount,
    lastUpdatedAt,
    claimedBy,
    resolvedAt,
  ];
}

class SosIncidentInclude extends _is.IncludeObject {
  SosIncidentInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => SosIncident.t;
}

class SosIncidentIncludeList extends _is.IncludeList {
  SosIncidentIncludeList._({
    _is.WhereExpressionBuilder<SosIncidentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SosIncident.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => SosIncident.t;
}

class SosIncidentRepository {
  const SosIncidentRepository._();

  /// Returns a list of [SosIncident]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<SosIncident>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SosIncidentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SosIncidentTable>? orderBy,
    _is.OrderByListBuilder<SosIncidentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SosIncident>(
      where: where?.call(SosIncident.t),
      orderBy: orderBy?.call(SosIncident.t),
      orderByList: orderByList?.call(SosIncident.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [SosIncident] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<SosIncident?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SosIncidentTable>? where,
    int? offset,
    _is.OrderByBuilder<SosIncidentTable>? orderBy,
    _is.OrderByListBuilder<SosIncidentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SosIncident>(
      where: where?.call(SosIncident.t),
      orderBy: orderBy?.call(SosIncident.t),
      orderByList: orderByList?.call(SosIncident.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SosIncident] by its [id] or null if no such row exists.
  Future<SosIncident?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SosIncident>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SosIncident]s in the list and returns the inserted rows.
  ///
  /// The returned [SosIncident]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SosIncident>> insert(
    _is.DatabaseSession session,
    List<SosIncident> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SosIncident>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SosIncident] and returns the inserted row.
  ///
  /// The returned [SosIncident] will have its `id` field set.
  Future<SosIncident> insertRow(
    _is.DatabaseSession session,
    SosIncident row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SosIncident>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SosIncident]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [SosIncident]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SosIncident>> upsert(
    _is.DatabaseSession session,
    List<SosIncident> rows, {
    required _is.ColumnSelections<SosIncidentTable> conflictColumns,
    _is.ColumnSelections<SosIncidentTable>? updateColumns,
    _is.WhereExpressionBuilder<SosIncidentTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SosIncident>(
      rows,
      conflictColumns: conflictColumns(SosIncident.t),
      updateColumns: updateColumns?.call(SosIncident.t),
      updateWhere: updateWhere?.call(SosIncident.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SosIncident] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [SosIncident] will have its `id` field set.
  Future<SosIncident?> upsertRow(
    _is.DatabaseSession session,
    SosIncident row, {
    required _is.ColumnSelections<SosIncidentTable> conflictColumns,
    _is.ColumnSelections<SosIncidentTable>? updateColumns,
    _is.WhereExpressionBuilder<SosIncidentTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SosIncident>(
      row,
      conflictColumns: conflictColumns(SosIncident.t),
      updateColumns: updateColumns?.call(SosIncident.t),
      updateWhere: updateWhere?.call(SosIncident.t),
      transaction: transaction,
    );
  }

  /// Updates all [SosIncident]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SosIncident>> update(
    _is.DatabaseSession session,
    List<SosIncident> rows, {
    _is.ColumnSelections<SosIncidentTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SosIncident>(
      rows,
      columns: columns?.call(SosIncident.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SosIncident]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SosIncident> updateRow(
    _is.DatabaseSession session,
    SosIncident row, {
    _is.ColumnSelections<SosIncidentTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SosIncident>(
      row,
      columns: columns?.call(SosIncident.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SosIncident] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SosIncident?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<SosIncidentUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SosIncident>(
      id,
      columnValues: columnValues(SosIncident.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SosIncident]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SosIncident>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SosIncidentUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SosIncidentTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SosIncidentTable>? orderBy,
    _is.OrderByListBuilder<SosIncidentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SosIncident>(
      columnValues: columnValues(SosIncident.t.updateTable),
      where: where(SosIncident.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SosIncident.t),
      orderByList: orderByList?.call(SosIncident.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SosIncident]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SosIncident>> delete(
    _is.DatabaseSession session,
    List<SosIncident> rows, {
    _is.OrderByBuilder<SosIncidentTable>? orderBy,
    _is.OrderByListBuilder<SosIncidentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SosIncident>(
      rows,
      orderBy: orderBy?.call(SosIncident.t),
      orderByList: orderByList?.call(SosIncident.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SosIncident].
  Future<SosIncident> deleteRow(
    _is.DatabaseSession session,
    SosIncident row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SosIncident>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SosIncident>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SosIncidentTable> where,
    _is.OrderByBuilder<SosIncidentTable>? orderBy,
    _is.OrderByListBuilder<SosIncidentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SosIncident>(
      where: where(SosIncident.t),
      orderBy: orderBy?.call(SosIncident.t),
      orderByList: orderByList?.call(SosIncident.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SosIncidentTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SosIncident>(
      where: where?.call(SosIncident.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SosIncident] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SosIncidentTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SosIncident>(
      where: where(SosIncident.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
