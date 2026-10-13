/// Represents a Bluetooth Low Energy device discovered during scanning.
class BlePeerDevice {
  final String remoteId;
  final String advertisedName;
  final int rssi;
  final bool isJivaanPeer;
  final DateTime? lastSeen;
  final List<String> serviceUuids;

  const BlePeerDevice({
    required this.remoteId,
    required this.advertisedName,
    required this.rssi,
    required this.isJivaanPeer,
    this.lastSeen,
    this.serviceUuids = const [],
  });

  /// User-visible display name.
  /// Falls back to a truncated remote ID if no name was advertised.
  String get displayName {
    if (advertisedName.trim().isNotEmpty) {
      return advertisedName.trim();
    }
    final shortId = remoteId.length > 8 ? remoteId.substring(0, 8) : remoteId;
    return 'BLE Device ($shortId)';
  }

  /// Distinction between authentic JivaanNet peers and ordinary BLE accessories.
  String get peerTypeLabel => isJivaanPeer
      ? 'Verified JivaanNet Peer'
      : 'Generic BLE Device (Unverified)';

  /// Signal strength interpretation based on RSSI in dBm.
  String get signalLabel => '$rssi dBm';

  /// Qualitative signal strength indicator.
  String get signalQuality {
    if (rssi >= -65) return 'Strong';
    if (rssi >= -80) return 'Moderate';
    return 'Weak';
  }

  /// Hop description — direct RF discovery cannot claim multi-hop relay.
  String get hopLabel =>
      isJivaanPeer ? 'Direct RF (1 hop)' : 'Direct RF (Generic)';

  /// Relay count — 0 until packet forwarding drivers are linked.
  String get relayCountLabel => '0 relayed';

  /// Sync timestamp — unavailable until P2P sync transport exists.
  String get lastSyncLabel => 'Not linked';
}
