import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../triage/deterministic_triage_service.dart';

/// Endpoint managing SOS incident ingestion, lifecycle operations, and dispatch claiming.
class IncidentEndpoint extends Endpoint {
  static final _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  /// Valid lifecycle statuses for SOS incidents.
  static const Set<String> validStatuses = {
    'pending',
    'acknowledged',
    'dispatched',
    'resolved',
  };

  /// Allowed status transitions:
  /// - pending -> acknowledged, dispatched, resolved
  /// - acknowledged -> dispatched, resolved
  /// - dispatched -> resolved
  /// - resolved -> resolved (idempotent terminal state)
  static const Map<String, Set<String>> allowedTransitions = {
    'pending': {'acknowledged', 'dispatched', 'resolved'},
    'acknowledged': {'dispatched', 'resolved'},
    'dispatched': {'resolved'},
    'resolved': {'resolved'},
  };

  /// Scopes permitted to perform responder and dispatch operations.
  static const Scope dispatcherScope = Scope('dispatcher');
  static const Scope adminScope = Scope('admin');

  /// Ingests an SOS incident submitted by a mobile client or mesh relay.
  ///
  /// Initial severity is assigned deterministically by trusted backend logic
  /// ([DeterministicTriageService]) based on verified emergency details.
  ///
  /// This operation is idempotent: submitting the same [incidentId] UUID multiple times
  /// returns the existing incident record with `isNew: false` without altering its severity.
  Future<SosSubmissionResponse> submitSos(
    Session session,
    SosSubmissionPayload payload,
  ) async {
    _validatePayload(payload);

    final normalizedIncidentId = payload.incidentId.trim().toLowerCase();
    final now = DateTime.now().toUtc();

    // Assign priority deterministically via trusted backend triage service
    final initialSeverity = DeterministicTriageService.classify(
      description: payload.description,
    );

    final newIncident = SosIncident(
      incidentId: normalizedIncidentId,
      latitude: payload.latitude,
      longitude: payload.longitude,
      createdAt: payload.createdAt.toUtc(),
      receivedAt: now,
      status: 'pending',
      severity: initialSeverity,
      description: payload.description?.trim(),
      sourceDeviceId: payload.sourceDeviceId?.trim(),
      relayCount: payload.relayCount,
      lastUpdatedAt: now,
      claimedBy: null,
      resolvedAt: null,
    );

    try {
      // Step 1: Attempt atomic insert with ignoreConflicts: true (PostgreSQL ON CONFLICT DO NOTHING).
      // This protects against concurrent duplicate submissions.
      final insertedRows = await SosIncident.db.insert(
        session,
        [newIncident],
        ignoreConflicts: true,
      );

      if (insertedRows.isNotEmpty) {
        session.log(
          'Successfully ingested new SOS incident $normalizedIncidentId with severity $initialSeverity',
          level: LogLevel.info,
        );
        return SosSubmissionResponse(
          incident: insertedRows.first,
          isNew: true,
          message: 'SOS incident successfully registered.',
        );
      }

      // Step 2: If ignoreConflicts returned an empty list, an incident with this UUID already exists.
      final existingIncident = await SosIncident.db.findFirstRow(
        session,
        where: (t) => t.incidentId.equals(normalizedIncidentId),
      );

      if (existingIncident != null) {
        session.log(
          'Duplicate SOS incident submission received for $normalizedIncidentId',
          level: LogLevel.info,
        );
        return SosSubmissionResponse(
          incident: existingIncident,
          isNew: false,
          message: 'Incident previously registered (duplicate submission).',
        );
      }

      throw DatabaseException('Failed to insert or locate SOS incident.');
    } on DatabaseUniqueViolationException {
      // Direct constraint collision recovery for concurrent submissions
      final existingIncident = await SosIncident.db.findFirstRow(
        session,
        where: (t) => t.incidentId.equals(normalizedIncidentId),
      );

      if (existingIncident != null) {
        session.log(
          'Handled concurrent duplicate SOS submission for $normalizedIncidentId',
          level: LogLevel.info,
        );
        return SosSubmissionResponse(
          incident: existingIncident,
          isNew: false,
          message: 'Incident previously registered (duplicate submission).',
        );
      }
      rethrow;
    } catch (e, stackTrace) {
      session.log(
        'Error processing SOS incident $normalizedIncidentId: $e',
        level: LogLevel.error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Retrieves a single incident by its client-generated [incidentId] UUID.
  /// Returns `null` if no incident matches the given UUID.
  Future<SosIncident?> getIncident(
    Session session,
    String incidentId,
  ) async {
    _validateUuid(incidentId);
    final normalizedId = incidentId.trim().toLowerCase();

    return await SosIncident.db.findFirstRow(
      session,
      where: (t) => t.incidentId.equals(normalizedId),
    );
  }

  /// Lists incidents with pagination and optional filtering by status, severity,
  /// and createdAt range.
  ///
  /// Ordering is stable and deterministic: sorted by `createdAt DESC`, with `id DESC`
  /// as the tie-breaker.
  Future<IncidentListPage> listIncidents(
    Session session, {
    int page = 1,
    int limit = 20,
    String? status,
    String? severity,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final sanitizedPage = page < 1 ? 1 : page;
    final sanitizedLimit = limit < 1 ? 20 : (limit > 100 ? 100 : limit);
    final offset = (sanitizedPage - 1) * sanitizedLimit;

    Expression? filterExpr;

    if (status != null && status.trim().isNotEmpty) {
      final normalizedStatus = status.trim().toLowerCase();
      final statusExpr = SosIncident.t.status.equals(normalizedStatus);
      filterExpr = statusExpr;
    }

    if (severity != null && severity.trim().isNotEmpty) {
      final normalizedSeverity = severity.trim().toLowerCase();
      final sevExpr = SosIncident.t.severity.equals(normalizedSeverity);
      filterExpr = filterExpr == null ? sevExpr : filterExpr & sevExpr;
    }

    if (fromDate != null) {
      final fromExpr = SosIncident.t.createdAt >= fromDate.toUtc();
      filterExpr = filterExpr == null ? fromExpr : filterExpr & fromExpr;
    }

    if (toDate != null) {
      final toExpr = SosIncident.t.createdAt <= toDate.toUtc();
      filterExpr = filterExpr == null ? toExpr : filterExpr & toExpr;
    }

    final totalCount = await SosIncident.db.count(
      session,
      where: filterExpr == null ? null : (t) => filterExpr!,
    );

    final incidents = await SosIncident.db.find(
      session,
      where: filterExpr == null ? null : (t) => filterExpr!,
      limit: sanitizedLimit,
      offset: offset,
      orderByList: (t) => [t.createdAt.desc(), t.id.desc()],
    );

    final hasMore = (offset + incidents.length) < totalCount;

    return IncidentListPage(
      incidents: incidents,
      totalCount: totalCount,
      page: sanitizedPage,
      pageSize: sanitizedLimit,
      hasMore: hasMore,
    );
  }

  /// Claims an unclaimed SOS incident for the authenticated responder/dispatcher.
  ///
  /// Concurrency safety: Uses an atomic database transaction with `LockMode.forUpdate`
  /// row locking to ensure two responders attempting concurrent claims on the same
  /// incident cannot both succeed.
  ///
  /// - Requires authentication with `dispatcher` or `admin` scope.
  /// - Throws [SosNotFoundException] if the incident does not exist.
  /// - Throws [SosValidationException] if the incident has already been resolved.
  /// - Throws [SosClaimConflictException] if the incident is already claimed by another responder.
  /// - If the same responder calls claim again, the operation is idempotent and returns the incident.
  Future<SosIncident> claimIncident(
    Session session,
    String incidentId,
  ) async {
    _requireDispatcher(session);
    _validateUuid(incidentId);

    final normalizedId = incidentId.trim().toLowerCase();
    final responderId = session.authenticated!.userIdentifier;

    return await session.db.transaction<SosIncident>((tx) async {
      final incident = await SosIncident.db.findFirstRow(
        session,
        where: (t) => t.incidentId.equals(normalizedId),
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );

      if (incident == null) {
        throw SosNotFoundException(
          message: 'Incident not found: $incidentId',
          incidentId: incidentId,
        );
      }

      if (incident.status == 'resolved') {
        throw SosValidationException(
          message: 'Cannot claim an incident that has already been resolved.',
          field: 'status',
        );
      }

      if (incident.claimedBy != null && incident.claimedBy!.isNotEmpty) {
        if (incident.claimedBy == responderId) {
          // Idempotent: already claimed by the same responder
          return incident;
        }
        throw SosClaimConflictException(
          message:
              'Incident has already been claimed by responder "${incident.claimedBy}".',
          incidentId: incidentId,
          claimedBy: incident.claimedBy,
        );
      }

      final now = DateTime.now().toUtc();
      incident.claimedBy = responderId;
      incident.lastUpdatedAt = now;

      // When claiming a pending incident, advance lifecycle to acknowledged
      if (incident.status == 'pending') {
        incident.status = 'acknowledged';
      }

      final updated = await SosIncident.db.updateRow(
        session,
        incident,
        transaction: tx,
      );

      session.log(
        'Incident $normalizedId successfully claimed by responder "$responderId"',
        level: LogLevel.info,
      );

      return updated;
    });
  }

  /// Updates an incident's lifecycle status through validated transitions.
  ///
  /// Requires authentication and `dispatcher` or `admin` authorization.
  Future<SosIncident> updateIncidentStatus(
    Session session,
    String incidentId,
    String newStatus,
  ) async {
    _requireDispatcher(session);
    _validateUuid(incidentId);

    final normalizedStatus = newStatus.trim().toLowerCase();
    if (!validStatuses.contains(normalizedStatus)) {
      throw SosValidationException(
        message:
            'Invalid status "$newStatus". Valid statuses are: ${validStatuses.join(", ")}.',
        field: 'status',
      );
    }

    final normalizedId = incidentId.trim().toLowerCase();
    final incident = await SosIncident.db.findFirstRow(
      session,
      where: (t) => t.incidentId.equals(normalizedId),
    );

    if (incident == null) {
      throw SosNotFoundException(
        message: 'Incident not found: $incidentId',
        incidentId: incidentId,
      );
    }

    final currentStatus = incident.status;
    if (currentStatus == normalizedStatus) {
      return incident; // Idempotent no-op
    }

    final allowed = allowedTransitions[currentStatus] ?? {};
    if (!allowed.contains(normalizedStatus)) {
      throw SosValidationException(
        message:
            'Invalid status transition from "$currentStatus" to "$normalizedStatus". Allowed transitions from "$currentStatus": ${allowed.join(", ")}.',
        field: 'status',
      );
    }

    final now = DateTime.now().toUtc();
    incident.status = normalizedStatus;
    incident.lastUpdatedAt = now;

    if (normalizedStatus == 'resolved') {
      incident.resolvedAt ??= now;
    }

    return await SosIncident.db.updateRow(session, incident);
  }

  /// Marks an incident resolved and records resolution timestamps.
  /// Repeated calls on an already-resolved incident are idempotent.
  ///
  /// Requires authentication and `dispatcher` or `admin` authorization.
  Future<SosIncident> resolveIncident(
    Session session,
    String incidentId,
  ) async {
    _requireDispatcher(session);
    _validateUuid(incidentId);

    final normalizedId = incidentId.trim().toLowerCase();
    final incident = await SosIncident.db.findFirstRow(
      session,
      where: (t) => t.incidentId.equals(normalizedId),
    );

    if (incident == null) {
      throw SosNotFoundException(
        message: 'Incident not found: $incidentId',
        incidentId: incidentId,
      );
    }

    if (incident.status == 'resolved') {
      return incident; // Idempotent
    }

    final allowed = allowedTransitions[incident.status] ?? {};
    if (!allowed.contains('resolved')) {
      throw SosValidationException(
        message:
            'Cannot resolve incident currently in "${incident.status}" status.',
        field: 'status',
      );
    }

    final now = DateTime.now().toUtc();
    incident.status = 'resolved';
    incident.lastUpdatedAt = now;
    incident.resolvedAt ??= now;

    return await SosIncident.db.updateRow(session, incident);
  }

  void _requireDispatcher(Session session) {
    final auth = session.authenticated;
    if (auth == null) {
      throw SosAuthorizationException(
        message:
            'Authentication required. Please sign in as an authorized dispatcher.',
        reason: 'unauthenticated',
      );
    }

    final scopes = auth.scopes;
    final isAuthorized =
        scopes.contains(dispatcherScope) ||
        scopes.contains(adminScope) ||
        scopes.contains(Scope.admin);

    if (!isAuthorized) {
      throw SosAuthorizationException(
        message:
            'Access denied: user "${auth.userIdentifier}" does not have dispatcher authorization.',
        reason: 'forbidden',
      );
    }
  }

  void _validateUuid(String id) {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty || !_uuidRegex.hasMatch(trimmedId)) {
      throw SosValidationException(
        message: 'incidentId must be a valid UUID.',
        field: 'incidentId',
      );
    }
  }

  void _validatePayload(SosSubmissionPayload payload) {
    _validateUuid(payload.incidentId);

    // Latitude validation (-90.0 to 90.0)
    if (!payload.latitude.isFinite ||
        payload.latitude < -90.0 ||
        payload.latitude > 90.0) {
      throw SosValidationException(
        message: 'latitude must be a finite number between -90.0 and 90.0.',
        field: 'latitude',
      );
    }

    // Longitude validation (-180.0 to 180.0)
    if (!payload.longitude.isFinite ||
        payload.longitude < -180.0 ||
        payload.longitude > 180.0) {
      throw SosValidationException(
        message: 'longitude must be a finite number between -180.0 and 180.0.',
        field: 'longitude',
      );
    }

    // Timestamp validation
    final now = DateTime.now().toUtc();
    final createdUtc = payload.createdAt.toUtc();
    // Allow up to 15 minutes of clock drift into the future
    if (createdUtc.isAfter(now.add(const Duration(minutes: 15)))) {
      throw SosValidationException(
        message: 'createdAt cannot be unreasonably far in the future.',
        field: 'createdAt',
      );
    }
    // Reject timestamps before year 2020
    if (createdUtc.isBefore(DateTime.utc(2020, 1, 1))) {
      throw SosValidationException(
        message: 'createdAt is unreasonably far in the past.',
        field: 'createdAt',
      );
    }

    // Description length (max 2000 chars)
    if (payload.description != null && payload.description!.length > 2000) {
      throw SosValidationException(
        message:
            'description exceeds maximum allowed length (2000 characters).',
        field: 'description',
      );
    }

    // Source device ID length (max 255 chars)
    if (payload.sourceDeviceId != null &&
        payload.sourceDeviceId!.length > 255) {
      throw SosValidationException(
        message:
            'sourceDeviceId exceeds maximum allowed length (255 characters).',
        field: 'sourceDeviceId',
      );
    }

    // Relay count validation (>= 0 and bounded)
    if (payload.relayCount < 0 || payload.relayCount > 1000) {
      throw SosValidationException(
        message: 'relayCount must be between 0 and 1000.',
        field: 'relayCount',
      );
    }
  }
}
