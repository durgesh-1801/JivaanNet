import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:jivaan_net_client/jivaan_net_client.dart';

/// Physical network interface state of the device radio.
enum NetworkInterfaceType {
  none,
  wifi,
  cellular,
  ethernet,
  other,
}

/// Reachability state of the remote Serverpod backend.
enum BackendReachability {
  unknown,
  reachable,
  unreachable,
}

/// Comprehensive connectivity state separating device radio from backend server health.
class AppConnectivityState {
  final NetworkInterfaceType networkType;
  final BackendReachability backendReachability;
  final DateTime? lastChecked;
  final String? lastError;

  const AppConnectivityState({
    required this.networkType,
    required this.backendReachability,
    this.lastChecked,
    this.lastError,
  });

  bool get hasNetworkConnection => networkType != NetworkInterfaceType.none;
  bool get isServerReachable =>
      backendReachability == BackendReachability.reachable;

  String get networkLabel {
    switch (networkType) {
      case NetworkInterfaceType.wifi:
        return 'Wi-Fi';
      case NetworkInterfaceType.cellular:
        return 'Cellular';
      case NetworkInterfaceType.ethernet:
        return 'Ethernet';
      case NetworkInterfaceType.other:
        return 'Connected';
      case NetworkInterfaceType.none:
        return 'No Network';
    }
  }

  AppConnectivityState copyWith({
    NetworkInterfaceType? networkType,
    BackendReachability? backendReachability,
    DateTime? lastChecked,
    String? lastError,
  }) {
    return AppConnectivityState(
      networkType: networkType ?? this.networkType,
      backendReachability: backendReachability ?? this.backendReachability,
      lastChecked: lastChecked ?? this.lastChecked,
      lastError: lastError ?? this.lastError,
    );
  }
}

/// Service managing device connectivity and Serverpod backend reachability.
///
/// Distinguishes between local physical network access (Wi-Fi/Cellular) and
/// actual end-to-end communication with the Serverpod backend.
class ConnectivityService {
  static final ConnectivityService instance = ConnectivityService();

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final StreamController<AppConnectivityState> _stateController =
      StreamController<AppConnectivityState>.broadcast();

  AppConnectivityState _state = const AppConnectivityState(
    networkType: NetworkInterfaceType.none,
    backendReachability: BackendReachability.unknown,
  );

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _init();
  }

  AppConnectivityState get state => _state;
  bool get hasNetworkConnection => _state.hasNetworkConnection;
  bool get isServerReachable => _state.isServerReachable;
  Stream<AppConnectivityState> get stateStream => _stateController.stream;

  void _init() {
    try {
      _subscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
        onError: (Object error) {
          debugPrint('[ConnectivityService] Connectivity stream error: $error');
        },
      );

      // Initial check
      _connectivity.checkConnectivity().then(_onConnectivityChanged).catchError(
        (Object e) {
          debugPrint('[ConnectivityService] Initial connectivity check failed: $e');
          return <ConnectivityResult>[ConnectivityResult.none];
        },
      );
    } catch (e) {
      debugPrint('[ConnectivityService] Initialization error: $e');
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final type = _mapConnectivityResults(results);
    final previousType = _state.networkType;

    _state = _state.copyWith(networkType: type);

    // If completely disconnected from network, backend is definitely unreachable
    if (type == NetworkInterfaceType.none) {
      _state = _state.copyWith(
        backendReachability: BackendReachability.unreachable,
        lastError: 'No physical network connection (Wi-Fi or cellular).',
      );
    }

    debugPrint(
      '[ConnectivityService] Device network interface changed: ${previousType.name} -> ${type.name}',
    );

    _notifyState();
  }

  NetworkInterfaceType _mapConnectivityResults(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      if (results.length == 1) return NetworkInterfaceType.none;
    }
    if (results.contains(ConnectivityResult.wifi)) {
      return NetworkInterfaceType.wifi;
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return NetworkInterfaceType.cellular;
    }
    if (results.contains(ConnectivityResult.ethernet)) {
      return NetworkInterfaceType.ethernet;
    }
    if (results.contains(ConnectivityResult.other)) {
      return NetworkInterfaceType.other;
    }
    return NetworkInterfaceType.none;
  }

  /// Probes Serverpod backend reachability by performing a lightweight query.
  Future<bool> checkBackendReachability(
    Client client, {
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final endpoint = client.host;
    final now = DateTime.now();

    try {
      debugPrint(
        '[ConnectivityService] Checking Serverpod health at $endpoint...',
      );

      // Lightweight 1-item incident list call
      await client.incident
          .listIncidents(page: 1, limit: 1)
          .timeout(timeout);

      _state = _state.copyWith(
        backendReachability: BackendReachability.reachable,
        lastChecked: now,
        lastError: null,
      );

      debugPrint(
        '[ConnectivityService] Serverpod backend is REACHABLE at $endpoint',
      );

      _notifyState();
      return true;
    } catch (e) {
      final cleanError = _formatDiagnosticError(e);
      _state = _state.copyWith(
        backendReachability: BackendReachability.unreachable,
        lastChecked: now,
        lastError: cleanError,
      );

      debugPrint(
        '[ConnectivityService] Serverpod backend is UNREACHABLE at $endpoint: $cleanError',
      );

      _notifyState();
      return false;
    }
  }

  /// Called after any successful Serverpod API call in the application.
  void reportSuccess() {
    if (_state.backendReachability != BackendReachability.reachable) {
      _state = _state.copyWith(
        backendReachability: BackendReachability.reachable,
        lastChecked: DateTime.now(),
        lastError: null,
      );
      _notifyState();
    }
  }

  /// Called after any failed Serverpod API call in the application.
  void reportFailure(Object error) {
    final cleanError = _formatDiagnosticError(error);
    _state = _state.copyWith(
      backendReachability: BackendReachability.unreachable,
      lastChecked: DateTime.now(),
      lastError: cleanError,
    );
    _notifyState();
  }

  String _formatDiagnosticError(Object error) {
    final str = error.toString();
    if (str.contains('Connection refused')) {
      return 'Connection refused. If testing on Android via USB, verify "adb reverse tcp:8080 tcp:8080".';
    }
    if (str.contains('SocketException')) {
      return 'Network socket error: $str';
    }
    if (str.contains('TimeoutException')) {
      return 'Server request timed out.';
    }
    return str;
  }

  void _notifyState() {
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _stateController.close();
  }
}
