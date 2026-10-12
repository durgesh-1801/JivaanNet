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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// SOS Incident reported by a device or mesh network in emergency response.
abstract class SosIncident
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      receivedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
      status: jsonSerialization['status'] as String,
      severity: jsonSerialization['severity'] as String,
      description: jsonSerialization['description'] as String?,
      sourceDeviceId: jsonSerialization['sourceDeviceId'] as String?,
      relayCount: jsonSerialization['relayCount'] as int,
      lastUpdatedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastUpdatedAt'],
      ),
      claimedBy: jsonSerialization['claimedBy'] as String?,
      resolvedAt: jsonSerialization['resolvedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['resolvedAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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

  /// Returns a shallow copy of this [SosIncident]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
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
  @_isc.useResult
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
