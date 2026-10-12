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

/// Exception thrown when an unauthorized user attempts a protected operation.
abstract class SosAuthorizationException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  SosAuthorizationException._({
    required this.message,
    required this.reason,
  });

  factory SosAuthorizationException({
    required String message,
    required String reason,
  }) = _SosAuthorizationExceptionImpl;

  factory SosAuthorizationException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SosAuthorizationException(
      message: jsonSerialization['message'] as String,
      reason: jsonSerialization['reason'] as String,
    );
  }

  /// Human-readable reason for authorization failure.
  String message;

  /// Error code or category (e.g. unauthenticated, forbidden).
  String reason;

  /// Returns a shallow copy of this [SosAuthorizationException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SosAuthorizationException copyWith({
    String? message,
    String? reason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SosAuthorizationException',
      'message': message,
      'reason': reason,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SosAuthorizationException',
      'message': message,
      'reason': reason,
    };
  }

  @override
  String toString() {
    return 'SosAuthorizationException(message: $message, reason: $reason)';
  }
}

class _SosAuthorizationExceptionImpl extends SosAuthorizationException {
  _SosAuthorizationExceptionImpl({
    required String message,
    required String reason,
  }) : super._(
         message: message,
         reason: reason,
       );

  /// Returns a shallow copy of this [SosAuthorizationException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SosAuthorizationException copyWith({
    String? message,
    String? reason,
  }) {
    return SosAuthorizationException(
      message: message ?? this.message,
      reason: reason ?? this.reason,
    );
  }
}
