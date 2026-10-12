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

/// Exception thrown when SOS submission payload fails validation.
abstract class SosValidationException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  SosValidationException._({
    required this.message,
    this.field,
  });

  factory SosValidationException({
    required String message,
    String? field,
  }) = _SosValidationExceptionImpl;

  factory SosValidationException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SosValidationException(
      message: jsonSerialization['message'] as String,
      field: jsonSerialization['field'] as String?,
    );
  }

  /// Human-readable explanation of why validation failed.
  String message;

  /// Field name that failed validation, if applicable.
  String? field;

  /// Returns a shallow copy of this [SosValidationException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SosValidationException copyWith({
    String? message,
    String? field,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SosValidationException',
      'message': message,
      if (field != null) 'field': field,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SosValidationException',
      'message': message,
      if (field != null) 'field': field,
    };
  }

  @override
  String toString() {
    return 'SosValidationException(message: $message, field: $field)';
  }
}

class _Undefined {}

class _SosValidationExceptionImpl extends SosValidationException {
  _SosValidationExceptionImpl({
    required String message,
    String? field,
  }) : super._(
         message: message,
         field: field,
       );

  /// Returns a shallow copy of this [SosValidationException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SosValidationException copyWith({
    String? message,
    Object? field = _Undefined,
  }) {
    return SosValidationException(
      message: message ?? this.message,
      field: field is String? ? field : this.field,
    );
  }
}
