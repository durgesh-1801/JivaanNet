/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'incidents/incident_list_page.dart' as _i4zshnar;
import 'incidents/sos_authorization_exception.dart' as _ijrb4cu5;
import 'incidents/sos_claim_conflict_exception.dart' as _ie8sbyxc;
import 'incidents/sos_incident.dart' as _icwbpmo2;
import 'incidents/sos_not_found_exception.dart' as _iz80nfvz;
import 'incidents/sos_submission_payload.dart' as _ia2lvbfc;
import 'incidents/sos_submission_response.dart' as _i9y08tve;
import 'incidents/sos_validation_exception.dart' as _ic750ofi;
export 'greetings/greeting.dart';
export 'incidents/incident_list_page.dart';
export 'incidents/sos_authorization_exception.dart';
export 'incidents/sos_claim_conflict_exception.dart';
export 'incidents/sos_incident.dart';
export 'incidents/sos_not_found_exception.dart';
export 'incidents/sos_submission_payload.dart';
export 'incidents/sos_submission_response.dart';
export 'incidents/sos_validation_exception.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'sos_incident',
      dartName: 'SosIncident',
      schema: 'public',
      module: 'jivaan_net',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'incidentId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'latitude',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'longitude',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'receivedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'severity',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'description',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'sourceDeviceId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'relayCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'lastUpdatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'claimedBy',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'resolvedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'sos_incident_incident_id_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'incidentId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'sos_incident_status_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'status',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'sos_incident_created_at_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _i4zshnar.IncidentListPage) {
      return _i4zshnar.IncidentListPage.fromJson(data) as T;
    }
    if (t == _ijrb4cu5.SosAuthorizationException) {
      return _ijrb4cu5.SosAuthorizationException.fromJson(data) as T;
    }
    if (t == _ie8sbyxc.SosClaimConflictException) {
      return _ie8sbyxc.SosClaimConflictException.fromJson(data) as T;
    }
    if (t == _icwbpmo2.SosIncident) {
      return _icwbpmo2.SosIncident.fromJson(data) as T;
    }
    if (t == _iz80nfvz.SosNotFoundException) {
      return _iz80nfvz.SosNotFoundException.fromJson(data) as T;
    }
    if (t == _ia2lvbfc.SosSubmissionPayload) {
      return _ia2lvbfc.SosSubmissionPayload.fromJson(data) as T;
    }
    if (t == _i9y08tve.SosSubmissionResponse) {
      return _i9y08tve.SosSubmissionResponse.fromJson(data) as T;
    }
    if (t == _ic750ofi.SosValidationException) {
      return _ic750ofi.SosValidationException.fromJson(data) as T;
    }
    if (t == _is.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i4zshnar.IncidentListPage?>()) {
      return (data != null ? _i4zshnar.IncidentListPage.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ijrb4cu5.SosAuthorizationException?>()) {
      return (data != null
              ? _ijrb4cu5.SosAuthorizationException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ie8sbyxc.SosClaimConflictException?>()) {
      return (data != null
              ? _ie8sbyxc.SosClaimConflictException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_icwbpmo2.SosIncident?>()) {
      return (data != null ? _icwbpmo2.SosIncident.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iz80nfvz.SosNotFoundException?>()) {
      return (data != null
              ? _iz80nfvz.SosNotFoundException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ia2lvbfc.SosSubmissionPayload?>()) {
      return (data != null
              ? _ia2lvbfc.SosSubmissionPayload.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i9y08tve.SosSubmissionResponse?>()) {
      return (data != null
              ? _i9y08tve.SosSubmissionResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ic750ofi.SosValidationException?>()) {
      return (data != null
              ? _ic750ofi.SosValidationException.fromJson(data)
              : null)
          as T;
    }
    if (t == List<_icwbpmo2.SosIncident>) {
      return (data as List)
              .map((e) => deserialize<_icwbpmo2.SosIncident>(e))
              .toList()
          as T;
    }
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _izw8z7ou.Greeting => 'Greeting',
      _i4zshnar.IncidentListPage => 'IncidentListPage',
      _ijrb4cu5.SosAuthorizationException => 'SosAuthorizationException',
      _ie8sbyxc.SosClaimConflictException => 'SosClaimConflictException',
      _icwbpmo2.SosIncident => 'SosIncident',
      _iz80nfvz.SosNotFoundException => 'SosNotFoundException',
      _ia2lvbfc.SosSubmissionPayload => 'SosSubmissionPayload',
      _i9y08tve.SosSubmissionResponse => 'SosSubmissionResponse',
      _ic750ofi.SosValidationException => 'SosValidationException',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('jivaan_net.', '');
    }

    switch (data) {
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _i4zshnar.IncidentListPage():
        return 'IncidentListPage';
      case _ijrb4cu5.SosAuthorizationException():
        return 'SosAuthorizationException';
      case _ie8sbyxc.SosClaimConflictException():
        return 'SosClaimConflictException';
      case _icwbpmo2.SosIncident():
        return 'SosIncident';
      case _iz80nfvz.SosNotFoundException():
        return 'SosNotFoundException';
      case _ia2lvbfc.SosSubmissionPayload():
        return 'SosSubmissionPayload';
      case _i9y08tve.SosSubmissionResponse():
        return 'SosSubmissionResponse';
      case _ic750ofi.SosValidationException():
        return 'SosValidationException';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'IncidentListPage') {
      return deserialize<_i4zshnar.IncidentListPage>(data['data']);
    }
    if (dataClassName == 'SosAuthorizationException') {
      return deserialize<_ijrb4cu5.SosAuthorizationException>(data['data']);
    }
    if (dataClassName == 'SosClaimConflictException') {
      return deserialize<_ie8sbyxc.SosClaimConflictException>(data['data']);
    }
    if (dataClassName == 'SosIncident') {
      return deserialize<_icwbpmo2.SosIncident>(data['data']);
    }
    if (dataClassName == 'SosNotFoundException') {
      return deserialize<_iz80nfvz.SosNotFoundException>(data['data']);
    }
    if (dataClassName == 'SosSubmissionPayload') {
      return deserialize<_ia2lvbfc.SosSubmissionPayload>(data['data']);
    }
    if (dataClassName == 'SosSubmissionResponse') {
      return deserialize<_i9y08tve.SosSubmissionResponse>(data['data']);
    }
    if (dataClassName == 'SosValidationException') {
      return deserialize<_ic750ofi.SosValidationException>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('jivaan_net', this);
    _iacs.Protocol().registerHostProtocol('jivaan_net', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _icwbpmo2.SosIncident:
        return _icwbpmo2.SosIncident.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'jivaan_net';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
