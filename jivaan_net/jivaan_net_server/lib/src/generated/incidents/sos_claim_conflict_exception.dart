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

/// Exception thrown when a responder attempts to claim an already-claimed incident.
abstract class SosClaimConflictException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  SosClaimConflictException._({
    required this.message,
    required this.incidentId,
    this.claimedBy,
  });

  factory SosClaimConflictException({
    required String message,
    required String incidentId,
    String? claimedBy,
  }) = _SosClaimConflictExceptionImpl;

  factory SosClaimConflictException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SosClaimConflictException(
      message: jsonSerialization['message'] as String,
      incidentId: jsonSerialization['incidentId'] as String,
      claimedBy: jsonSerialization['claimedBy'] as String?,
    );
  }

  /// Explanation of the conflict.
  String message;

  /// UUID of the incident.
  String incidentId;

  /// Identity of the existing claimant.
  String? claimedBy;

  /// Returns a shallow copy of this [SosClaimConflictException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SosClaimConflictException copyWith({
    String? message,
    String? incidentId,
    String? claimedBy,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SosClaimConflictException',
      'message': message,
      'incidentId': incidentId,
      if (claimedBy != null) 'claimedBy': claimedBy,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SosClaimConflictException',
      'message': message,
      'incidentId': incidentId,
      if (claimedBy != null) 'claimedBy': claimedBy,
    };
  }

  @override
  String toString() {
    return 'SosClaimConflictException(message: $message, incidentId: $incidentId, claimedBy: $claimedBy)';
  }
}

class _Undefined {}

class _SosClaimConflictExceptionImpl extends SosClaimConflictException {
  _SosClaimConflictExceptionImpl({
    required String message,
    required String incidentId,
    String? claimedBy,
  }) : super._(
         message: message,
         incidentId: incidentId,
         claimedBy: claimedBy,
       );

  /// Returns a shallow copy of this [SosClaimConflictException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SosClaimConflictException copyWith({
    String? message,
    String? incidentId,
    Object? claimedBy = _Undefined,
  }) {
    return SosClaimConflictException(
      message: message ?? this.message,
      incidentId: incidentId ?? this.incidentId,
      claimedBy: claimedBy is String? ? claimedBy : this.claimedBy,
    );
  }
}
