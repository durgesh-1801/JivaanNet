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

/// A paginated response page containing incidents and pagination metadata.
abstract class IncidentListPage
    implements _is.SerializableModel, _is.ProtocolSerialization {
  IncidentListPage._({
    required this.incidents,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  factory IncidentListPage({
    required List<_i8nztuvl.SosIncident> incidents,
    required int totalCount,
    required int page,
    required int pageSize,
    required bool hasMore,
  }) = _IncidentListPageImpl;

  factory IncidentListPage.fromJson(Map<String, dynamic> jsonSerialization) {
    return IncidentListPage(
      incidents: _ing6h13c.Protocol().deserialize<List<_i8nztuvl.SosIncident>>(
        jsonSerialization['incidents'],
      ),
      totalCount: jsonSerialization['totalCount'] as int,
      page: jsonSerialization['page'] as int,
      pageSize: jsonSerialization['pageSize'] as int,
      hasMore: _is.BoolJsonExtension.fromJson(jsonSerialization['hasMore']),
    );
  }

  /// List of SOS incidents on this page.
  List<_i8nztuvl.SosIncident> incidents;

  /// Total number of incidents matching the filter query.
  int totalCount;

  /// Current 1-based page number.
  int page;

  /// Number of items requested per page.
  int pageSize;

  /// True if there are more incidents beyond this page.
  bool hasMore;

  /// Returns a shallow copy of this [IncidentListPage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  IncidentListPage copyWith({
    List<_i8nztuvl.SosIncident>? incidents,
    int? totalCount,
    int? page,
    int? pageSize,
    bool? hasMore,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IncidentListPage',
      'incidents': incidents.toJson(valueToJson: (v) => v.toJson()),
      'totalCount': totalCount,
      'page': page,
      'pageSize': pageSize,
      'hasMore': hasMore,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IncidentListPage',
      'incidents': incidents.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'totalCount': totalCount,
      'page': page,
      'pageSize': pageSize,
      'hasMore': hasMore,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _IncidentListPageImpl extends IncidentListPage {
  _IncidentListPageImpl({
    required List<_i8nztuvl.SosIncident> incidents,
    required int totalCount,
    required int page,
    required int pageSize,
    required bool hasMore,
  }) : super._(
         incidents: incidents,
         totalCount: totalCount,
         page: page,
         pageSize: pageSize,
         hasMore: hasMore,
       );

  /// Returns a shallow copy of this [IncidentListPage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  IncidentListPage copyWith({
    List<_i8nztuvl.SosIncident>? incidents,
    int? totalCount,
    int? page,
    int? pageSize,
    bool? hasMore,
  }) {
    return IncidentListPage(
      incidents:
          incidents ?? this.incidents.map((e0) => e0.copyWith()).toList(),
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
