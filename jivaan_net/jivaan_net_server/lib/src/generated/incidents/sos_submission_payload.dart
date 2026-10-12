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

/// Payload submitted by a mobile client or mesh relay when reporting an SOS incident.
abstract class SosSubmissionPayload
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SosSubmissionPayload._({
    required this.incidentId,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.description,
    this.sourceDeviceId,
    required this.relayCount,
  });

  factory SosSubmissionPayload({
    required String incidentId,
    required double latitude,
    required double longitude,
    required DateTime createdAt,
    String? description,
    String? sourceDeviceId,
    required int relayCount,
  }) = _SosSubmissionPayloadImpl;

  factory SosSubmissionPayload.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SosSubmissionPayload(
      incidentId: jsonSerialization['incidentId'] as String,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      description: jsonSerialization['description'] as String?,
      sourceDeviceId: jsonSerialization['sourceDeviceId'] as String?,
      relayCount: jsonSerialization['relayCount'] as int,
    );
  }

  /// Client-generated UUID identifying the original SOS incident for idempotency.
  String incidentId;

  /// Geographic latitude of the incident (-90 to 90).
  double latitude;

  /// Geographic longitude of the incident (-180 to 180).
  double longitude;

  /// Original creation time on the client device (preserves offline timestamp).
  DateTime createdAt;

  /// Optional short description or notes.
  String? description;

  /// Optional pseudonymous identifier of the source device.
  String? sourceDeviceId;

  /// Number of mesh hops/relays reported by the client (>= 0).
  int relayCount;

  /// Returns a shallow copy of this [SosSubmissionPayload]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SosSubmissionPayload copyWith({
    String? incidentId,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    String? description,
    String? sourceDeviceId,
    int? relayCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SosSubmissionPayload',
      'incidentId': incidentId,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toJson(),
      if (description != null) 'description': description,
      if (sourceDeviceId != null) 'sourceDeviceId': sourceDeviceId,
      'relayCount': relayCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SosSubmissionPayload',
      'incidentId': incidentId,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toJson(),
      if (description != null) 'description': description,
      if (sourceDeviceId != null) 'sourceDeviceId': sourceDeviceId,
      'relayCount': relayCount,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SosSubmissionPayloadImpl extends SosSubmissionPayload {
  _SosSubmissionPayloadImpl({
    required String incidentId,
    required double latitude,
    required double longitude,
    required DateTime createdAt,
    String? description,
    String? sourceDeviceId,
    required int relayCount,
  }) : super._(
         incidentId: incidentId,
         latitude: latitude,
         longitude: longitude,
         createdAt: createdAt,
         description: description,
         sourceDeviceId: sourceDeviceId,
         relayCount: relayCount,
       );

  /// Returns a shallow copy of this [SosSubmissionPayload]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SosSubmissionPayload copyWith({
    String? incidentId,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    Object? description = _Undefined,
    Object? sourceDeviceId = _Undefined,
    int? relayCount,
  }) {
    return SosSubmissionPayload(
      incidentId: incidentId ?? this.incidentId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      description: description is String? ? description : this.description,
      sourceDeviceId: sourceDeviceId is String?
          ? sourceDeviceId
          : this.sourceDeviceId,
      relayCount: relayCount ?? this.relayCount,
    );
  }
}
