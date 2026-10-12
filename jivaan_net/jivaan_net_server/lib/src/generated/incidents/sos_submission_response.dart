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
import 'package:jivaan_net_server/src/generated/protocol.dart' as _ing6h13c;
import 'package:serverpod/serverpod.dart' as _is;
import '../incidents/sos_incident.dart' as _i8nztuvl;

/// Response returned by the server following an SOS incident submission.
abstract class SosSubmissionResponse
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SosSubmissionResponse._({
    required this.incident,
    required this.isNew,
    required this.message,
  });

  factory SosSubmissionResponse({
    required _i8nztuvl.SosIncident incident,
    required bool isNew,
    required String message,
  }) = _SosSubmissionResponseImpl;

  factory SosSubmissionResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SosSubmissionResponse(
      incident: _ing6h13c.Protocol().deserialize<_i8nztuvl.SosIncident>(
        jsonSerialization['incident'],
      ),
      isNew: _is.BoolJsonExtension.fromJson(jsonSerialization['isNew']),
      message: jsonSerialization['message'] as String,
    );
  }

  /// The persisted SOS incident record (new or previously existing).
  _i8nztuvl.SosIncident incident;

  /// True if newly created by this request, false if it was already received (duplicate).
  bool isNew;

  /// Informative status message.
  String message;

  /// Returns a shallow copy of this [SosSubmissionResponse]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SosSubmissionResponse copyWith({
    _i8nztuvl.SosIncident? incident,
    bool? isNew,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SosSubmissionResponse',
      'incident': incident.toJson(),
      'isNew': isNew,
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SosSubmissionResponse',
      'incident': incident.toJsonForProtocol(),
      'isNew': isNew,
      'message': message,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _SosSubmissionResponseImpl extends SosSubmissionResponse {
  _SosSubmissionResponseImpl({
    required _i8nztuvl.SosIncident incident,
    required bool isNew,
    required String message,
  }) : super._(
         incident: incident,
         isNew: isNew,
         message: message,
       );

  /// Returns a shallow copy of this [SosSubmissionResponse]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SosSubmissionResponse copyWith({
    _i8nztuvl.SosIncident? incident,
    bool? isNew,
    String? message,
  }) {
    return SosSubmissionResponse(
      incident: incident ?? this.incident.copyWith(),
      isNew: isNew ?? this.isNew,
      message: message ?? this.message,
    );
  }
}
