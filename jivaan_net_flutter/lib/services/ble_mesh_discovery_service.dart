import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../models/ble_peer_device.dart';

/// Status of the BLE discovery service.
enum BleDiscoveryStatus {
  idle,
  scanning,
  unsupported,
  bluetoothOff,
  unauthorized,
  error,
}

/// Abstract scanner interface to allow unit testing without native BLE hardware.
abstract class BleScannerAdapter {
  Future<bool> get isSupported;
  Future<BluetoothAdapterState> get adapterState;
  Stream<List<ScanResult>> get scanResults;
  Future<void> startScan({Duration? timeout});
  Future<void> stopScan();
}

/// Default production adapter using [FlutterBluePlus].
class FlutterBluePlusAdapter implements BleScannerAdapter {
  const FlutterBluePlusAdapter();

  @override
  Future<bool> get isSupported => FlutterBluePlus.isSupported;

  @override
  Future<BluetoothAdapterState> get adapterState async {
    try {
      return await FlutterBluePlus.adapterState.first;
    } catch (_) {
      return BluetoothAdapterState.unknown;
    }
  }

  @override
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  @override
  Future<void> startScan({Duration? timeout}) {
    return FlutterBluePlus.startScan(
      timeout: timeout,
      androidUsesFineLocation: false,
    );
  }

  @override
  Future<void> stopScan() {
    return FlutterBluePlus.stopScan();
  }
}

/// Service handling Bluetooth Low Energy discovery for JivaanNet.
/// Discovers real nearby BLE devices and identifies verified JivaanNet peers.
class BleMeshDiscoveryService {
  BleMeshDiscoveryService({BleScannerAdapter? adapter})
    : _adapter = adapter ?? const FlutterBluePlusAdapter();

  final BleScannerAdapter _adapter;

  /// Custom 128-bit UUID reserved for JivaanNet peer-to-peer advertisements.
  static const String jivaanNetServiceUuid =
      '0000fe90-0000-1000-8000-00805f9b34fb';

  /// Advertised name prefix identifying JivaanNet nodes.
  static const String jivaanNetAdvPrefix = 'jivaan';

  final Map<String, BlePeerDevice> _discoveredDevices = {};
  final StreamController<List<BlePeerDevice>> _devicesController =
      StreamController<List<BlePeerDevice>>.broadcast();

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  BleDiscoveryStatus _status = BleDiscoveryStatus.idle;
  String? _errorMessage;

  BleDiscoveryStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isScanning => _status == BleDiscoveryStatus.scanning;

  /// Returns current list of discovered devices sorted by strongest RSSI first.
  List<BlePeerDevice> get devices {
    final list = _discoveredDevices.values.toList();
    list.sort((a, b) => b.rssi.compareTo(a.rssi));
    return List.unmodifiable(list);
  }

  /// Stream of discovered devices updated in real-time as packets arrive.
  Stream<List<BlePeerDevice>> get devicesStream => _devicesController.stream;

  /// Number of verified JivaanNet peers discovered.
  int get verifiedPeerCount =>
      _discoveredDevices.values.where((d) => d.isJivaanPeer).length;

  /// Number of total nearby BLE devices detected.
  int get nearbyDeviceCount => _discoveredDevices.length;

  /// Starts a real BLE scan with a specified timeout.
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    _errorMessage = null;

    try {
      // 1. Verify hardware support
      final supported = await _adapter.isSupported;
      if (!supported) {
        _status = BleDiscoveryStatus.unsupported;
        _errorMessage = 'Bluetooth Low Energy is not supported on this device.';
        _notifyDevices();
        return;
      }

      // 2. Check adapter power state
      final adapterState = await _adapter.adapterState;
      if (adapterState == BluetoothAdapterState.unauthorized) {
        _status = BleDiscoveryStatus.unauthorized;
        _errorMessage = 'Nearby Devices permission was denied. Please allow Bluetooth permission in Android settings.';
        _notifyDevices();
        return;
      }

      if (adapterState == BluetoothAdapterState.off) {
        _status = BleDiscoveryStatus.bluetoothOff;
        _errorMessage = 'Bluetooth is turned off. Please turn on Bluetooth to scan for nearby peers.';
        _notifyDevices();
        return;
      }

      // 3. Clear previous scan list and start scanning
      _discoveredDevices.clear();
      _notifyDevices();
      _status = BleDiscoveryStatus.scanning;

      await _scanSubscription?.cancel();
      _scanSubscription = _adapter.scanResults.listen(
        _onScanResults,
        onError: (Object error) {
          debugPrint('BLE Scan stream error: $error');
          _status = BleDiscoveryStatus.error;
          _errorMessage = 'Scan error: $error';
          _notifyDevices();
        },
      );

      await _adapter.startScan(timeout: timeout);

      // Once startScan finishes its timeout:
      _status = BleDiscoveryStatus.idle;
      _notifyDevices();
    } catch (e) {
      debugPrint('BLE startScan failed: $e');
      _status = BleDiscoveryStatus.error;
      _errorMessage = 'Failed to start BLE scan: $e';
      _notifyDevices();
    }
  }

  /// Stops an active BLE scan.
  Future<void> stopScan() async {
    try {
      await _adapter.stopScan();
    } catch (_) {}
    _status = BleDiscoveryStatus.idle;
    _notifyDevices();
  }

  void _onScanResults(List<ScanResult> results) {
    for (final result in results) {
      final remoteId = result.device.remoteId.str;
      final advName = result.advertisementData.advName;
      final platformName = result.device.platformName;
      final rawName = advName.isNotEmpty ? advName : platformName;

      final serviceUuids = result.advertisementData.serviceUuids
          .map((uuid) => uuid.str.toLowerCase())
          .toList();

      final isJivaan =
          serviceUuids.contains(jivaanNetServiceUuid.toLowerCase()) ||
          rawName.toLowerCase().startsWith(
            BleMeshDiscoveryService.jivaanNetAdvPrefix,
          );

      _discoveredDevices[remoteId] = BlePeerDevice(
        remoteId: remoteId,
        advertisedName: rawName,
        rssi: result.rssi,
        isJivaanPeer: isJivaan,
        lastSeen: DateTime.now(),
        serviceUuids: serviceUuids,
      );
    }
    _notifyDevices();
  }

  void _notifyDevices() {
    if (!_devicesController.isClosed) {
      _devicesController.add(devices);
    }
  }

  /// Disposes resources.
  Future<void> dispose() async {
    await _scanSubscription?.cancel();
    await _devicesController.close();
  }
}
