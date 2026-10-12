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

/// Exception thrown when a requested incident cannot be found.
abstract class SosNotFoundException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  SosNotFoundException._({
    required this.message,
    required this.incidentId,
  });

  factory SosNotFoundException({
    required String message,
    required String incidentId,
  }) = _SosNotFoundExceptionImpl;

  factory SosNotFoundException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SosNotFoundException(
      message: jsonSerialization['message'] as String,
      incidentId: jsonSerialization['incidentId'] as String,
    );
  }

  /// Human-readable message.
  String message;

  /// The incident UUID that was not found.
  String incidentId;

  /// Returns a shallow copy of this [SosNotFoundException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SosNotFoundException copyWith({
    String? message,
    String? incidentId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SosNotFoundException',
      'message': message,
      'incidentId': incidentId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SosNotFoundException',
      'message': message,
      'incidentId': incidentId,
    };
  }

  @override
  String toString() {
    return 'SosNotFoundException(message: $message, incidentId: $incidentId)';
  }
}

class _SosNotFoundExceptionImpl extends SosNotFoundException {
  _SosNotFoundExceptionImpl({
    required String message,
    required String incidentId,
  }) : super._(
         message: message,
         incidentId: incidentId,
       );

  /// Returns a shallow copy of this [SosNotFoundException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SosNotFoundException copyWith({
    String? message,
    String? incidentId,
  }) {
    return SosNotFoundException(
      message: message ?? this.message,
      incidentId: incidentId ?? this.incidentId,
    );
  }
}
