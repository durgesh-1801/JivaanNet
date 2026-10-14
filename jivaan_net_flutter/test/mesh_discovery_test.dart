import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jivaan_net_flutter/models/ble_peer_device.dart';
import 'package:jivaan_net_flutter/screens/mesh/mesh_network_screen.dart';
import 'package:jivaan_net_flutter/services/ble_mesh_discovery_service.dart';
import 'package:jivaan_net_flutter/services/mesh_relay_service.dart';

/// Test mock adapter implementing [BleScannerAdapter] without native platform calls.
class FakeBleScannerAdapter implements BleScannerAdapter {
  bool supported = true;
  BluetoothAdapterState state = BluetoothAdapterState.on;
  final StreamController<List<ScanResult>> resultsController =
      StreamController<List<ScanResult>>.broadcast();

  bool scanStarted = false;
  bool scanStopped = false;

  @override
  Future<bool> get isSupported async => supported;

  @override
  Future<BluetoothAdapterState> get adapterState async => state;

  @override
  Stream<List<ScanResult>> get scanResults => resultsController.stream;

  @override
  Future<void> startScan({Duration? timeout}) async {
    scanStarted = true;
  }

  @override
  Future<void> stopScan() async {
    scanStopped = true;
  }
}

void main() {
  group('BlePeerDevice Model Tests', () {
    test('Correctly computes displayName from advertisedName or remoteId', () {
      const namedDevice = BlePeerDevice(
        remoteId: 'AA:BB:CC:DD:EE:FF',
        advertisedName: 'Galaxy Buds Pro',
        rssi: -62,
        isJivaanPeer: false,
      );
      expect(namedDevice.displayName, equals('Galaxy Buds Pro'));

      const unnamedDevice = BlePeerDevice(
        remoteId: '12:34:56:78:90:AB',
        advertisedName: '',
        rssi: -75,
        isJivaanPeer: false,
      );
      expect(unnamedDevice.displayName, equals('BLE Device (12:34:56)'));
    });

    test(
      'Strictly distinguishes JivaanNet peer from generic BLE accessory',
      () {
        const genericDevice = BlePeerDevice(
          remoteId: '11:22:33:44:55:66',
          advertisedName: 'SmartWatch-BT',
          rssi: -82,
          isJivaanPeer: false,
        );
        expect(
          genericDevice.peerTypeLabel,
          equals('Generic BLE Device (Unverified)'),
        );
        expect(genericDevice.hopLabel, equals('Direct RF (Generic)'));
        expect(genericDevice.relayCountLabel, equals('0 relayed'));
        expect(genericDevice.lastSyncLabel, equals('Not linked'));

        const jivaanDevice = BlePeerDevice(
          remoteId: 'AA:11:22:33:44:55',
          advertisedName: 'jivaan-node-01',
          rssi: -55,
          isJivaanPeer: true,
        );
        expect(jivaanDevice.peerTypeLabel, equals('Verified JivaanNet Peer'));
        expect(jivaanDevice.hopLabel, equals('Direct RF (1 hop)'));
      },
    );

    test('Maps RSSI to signal quality accurately', () {
      const strong = BlePeerDevice(
        remoteId: '1',
        advertisedName: '',
        rssi: -50,
        isJivaanPeer: false,
      );
      expect(strong.signalQuality, equals('Strong'));
      expect(strong.signalLabel, equals('-50 dBm'));

      const moderate = BlePeerDevice(
        remoteId: '2',
        advertisedName: '',
        rssi: -72,
        isJivaanPeer: false,
      );
      expect(moderate.signalQuality, equals('Moderate'));

      const weak = BlePeerDevice(
        remoteId: '3',
        advertisedName: '',
        rssi: -88,
        isJivaanPeer: false,
      );
      expect(weak.signalQuality, equals('Weak'));
    });
  });

  group('BleMeshDiscoveryService Tests', () {
    late FakeBleScannerAdapter fakeAdapter;
    late BleMeshDiscoveryService service;

    setUp(() {
      fakeAdapter = FakeBleScannerAdapter();
      service = BleMeshDiscoveryService(adapter: fakeAdapter);
    });

    tearDown(() async {
      await service.dispose();
    });

    test('Handles Bluetooth unsupported gracefully', () async {
      fakeAdapter.supported = false;

      await service.startScan();

      expect(service.status, equals(BleDiscoveryStatus.unsupported));
      expect(service.errorMessage, contains('not supported'));
      expect(service.devices, isEmpty);
    });

    test('Handles Bluetooth turned off gracefully', () async {
      fakeAdapter.state = BluetoothAdapterState.off;

      await service.startScan();

      expect(service.status, equals(BleDiscoveryStatus.bluetoothOff));
      expect(service.errorMessage, contains('Bluetooth is turned off'));
      expect(service.devices, isEmpty);
    });

    test('Handles Nearby Devices permission denied gracefully', () async {
      fakeAdapter.state = BluetoothAdapterState.unauthorized;

      await service.startScan();

      expect(service.status, equals(BleDiscoveryStatus.unauthorized));
      expect(service.errorMessage, contains('permission was denied'));
      expect(service.devices, isEmpty);
    });
  });

  group('MeshNetworkScreen Widget Tests', () {
    setUp(() {
      MeshRelayService.instance.reset();
    });

    testWidgets('Renders mesh status card and toggles P2P relay simulation', (
      tester,
    ) async {
      final fakeAdapter = FakeBleScannerAdapter();
      final service = BleMeshDiscoveryService(adapter: fakeAdapter);

      await tester.pumpWidget(
        MaterialApp(
          home: MeshNetworkScreen(discoveryService: service, autoScan: false),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Check title
      expect(find.text('Mesh Network'), findsOneWidget);

      // Check initial standby status card
      expect(find.text('P2P SOS Relay Transport (Standby)'), findsOneWidget);
      expect(
        find.textContaining('Hardware mesh relay driver is in standby'),
        findsOneWidget,
      );

      // Verify switch is present and interactive
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      final switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isFalse);
      expect(switchWidget.onChanged, isNotNull);

      // Toggle switch to ON
      await tester.tap(switchFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify active P2P mesh state and simulation drill card
      expect(find.text('P2P SOS Relay Transport (Active)'), findsOneWidget);
      expect(find.text('P2P Multi-Hop Drill Simulation'), findsOneWidget);
      expect(find.textContaining('Jivaan-Relay-Node-01'), findsOneWidget);

      // Check visual radar disclaimer
      expect(
        find.textContaining('Radar shows relative signal strength (RSSI)'),
        findsOneWidget,
      );

      // Check active simulation disclaimer at bottom
      expect(find.textContaining('P2P Mesh Simulation Active'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await service.dispose();
    });

    testWidgets('Displays warning banner when Bluetooth is turned off', (
      tester,
    ) async {
      final fakeAdapter = FakeBleScannerAdapter();
      fakeAdapter.state = BluetoothAdapterState.off;
      final service = BleMeshDiscoveryService(adapter: fakeAdapter);

      await tester.pumpWidget(
        MaterialApp(
          home: MeshNetworkScreen(discoveryService: service, autoScan: true),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Bluetooth is disabled'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await service.dispose();
    });
  });
}
