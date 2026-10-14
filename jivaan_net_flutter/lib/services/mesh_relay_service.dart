import 'package:flutter/foundation.dart';
import '../models/ble_peer_device.dart';

/// Singleton service managing P2P SOS mesh packet relaying and multi-hop transport state.
class MeshRelayService extends ChangeNotifier {
  static final MeshRelayService instance = MeshRelayService._();
  MeshRelayService._();

  bool _isRelayEnabled = false;
  int _relayedRequestsCount = 0;
  int _simulatedHops = 2;

  bool get isRelayEnabled => _isRelayEnabled;
  int get relayedRequestsCount => _relayedRequestsCount;
  int get simulatedHops => _simulatedHops;

  static const List<BlePeerDevice> simulatedPeers = [
    BlePeerDevice(
      remoteId: 'JV:RELAY:01',
      advertisedName: 'Jivaan-Relay-Node-01',
      rssi: -58,
      isJivaanPeer: true,
    ),
    BlePeerDevice(
      remoteId: 'JV:GATEWAY:02',
      advertisedName: 'Jivaan-Gateway-Alpha',
      rssi: -64,
      isJivaanPeer: true,
    ),
  ];

  void toggleRelay(bool value) {
    _isRelayEnabled = value;
    notifyListeners();
  }

  void setSimulatedHops(int hops) {
    _simulatedHops = hops.clamp(1, 5);
    notifyListeners();
  }

  void recordRelayEvent({int count = 1}) {
    _relayedRequestsCount += count;
    notifyListeners();
  }

  void reset() {
    _isRelayEnabled = false;
    _relayedRequestsCount = 0;
    _simulatedHops = 2;
    notifyListeners();
  }
}
