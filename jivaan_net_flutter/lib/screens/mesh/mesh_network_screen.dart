import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/ble_peer_device.dart';
import '../../services/ble_mesh_discovery_service.dart';
import '../../services/mesh_relay_service.dart';

/// 6. Mesh Network Screen: Real Bluetooth Low Energy (BLE) discovery,
/// live RSSI reporting, device classification, and truth-in-advertising mesh indicators.
class MeshNetworkScreen extends StatefulWidget {
  final bool showBackButton;
  final BleMeshDiscoveryService? discoveryService;
  final bool autoScan;

  const MeshNetworkScreen({
    super.key,
    this.showBackButton = true,
    this.discoveryService,
    this.autoScan = true,
  });

  @override
  State<MeshNetworkScreen> createState() => _MeshNetworkScreenState();
}

class _MeshNetworkScreenState extends State<MeshNetworkScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _radarController;
  late final BleMeshDiscoveryService _discoveryService;
  late final bool _ownsService;

  StreamSubscription<List<BlePeerDevice>>? _devicesSubscription;
  List<BlePeerDevice> _devices = [];
  bool _isScanning = false;
  DateTime? _lastScanTime;
  String? _statusBannerMessage;
  bool _isErrorBanner = false;
  bool _isSimulatingDrill = false;

  @override
  void initState() {
    super.initState();
    _ownsService = widget.discoveryService == null;
    _discoveryService = widget.discoveryService ?? BleMeshDiscoveryService();

    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _devices = _discoveryService.devices;

    MeshRelayService.instance.addListener(_onRelayServiceChanged);

    _devicesSubscription = _discoveryService.devicesStream.listen((devices) {
      if (mounted) {
        setState(() {
          _devices = devices;
          _isScanning = _discoveryService.isScanning;
          _syncStatusBanner();
        });
      }
    });

    if (widget.autoScan) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startScan();
      });
    }
  }

  void _onRelayServiceChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    MeshRelayService.instance.removeListener(_onRelayServiceChanged);
    _devicesSubscription?.cancel();
    _radarController.dispose();
    if (_ownsService) {
      _discoveryService.dispose();
    }
    super.dispose();
  }

  void _syncStatusBanner() {
    switch (_discoveryService.status) {
      case BleDiscoveryStatus.unauthorized:
        _statusBannerMessage = 'Nearby Devices permission is required to discover Bluetooth peers. Please grant permission in Android settings.';
        _isErrorBanner = true;
        break;
      case BleDiscoveryStatus.bluetoothOff:
        _statusBannerMessage = 'Bluetooth is disabled. Turn on Bluetooth on your device to discover nearby peers.';
        _isErrorBanner = true;
        break;
      case BleDiscoveryStatus.unsupported:
        _statusBannerMessage =
            'Bluetooth Low Energy is not supported on this hardware.';
        _isErrorBanner = true;
        break;
      case BleDiscoveryStatus.error:
        _statusBannerMessage =
            _discoveryService.errorMessage ??
            'An error occurred during BLE scan.';
        _isErrorBanner = true;
        break;
      case BleDiscoveryStatus.scanning:
        _statusBannerMessage = null;
        _isErrorBanner = false;
        break;
      case BleDiscoveryStatus.idle:
        _statusBannerMessage = null;
        _isErrorBanner = false;
        break;
    }
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
    });

    await _discoveryService.startScan(timeout: const Duration(seconds: 10));

    if (mounted) {
      setState(() {
        _isScanning = false;
        _lastScanTime = DateTime.now();
        _syncStatusBanner();
      });
    }
  }

  Future<void> _stopScan() async {
    await _discoveryService.stopScan();
    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 15) return 'Just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  List<BlePeerDevice> get _effectiveDevices {
    if (!MeshRelayService.instance.isRelayEnabled) {
      return _devices;
    }
    final result = <BlePeerDevice>[...MeshRelayService.simulatedPeers];
    for (final d in _devices) {
      if (!result.any((p) => p.remoteId == d.remoteId)) {
        result.add(d);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: const Text('Mesh Network'),
        actions: [
          if (_isScanning)
            IconButton(
              icon: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AppColors.cyanAccent,
                ),
              ),
              tooltip: 'Scanning... Tap to stop',
              onPressed: _stopScan,
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Scan for nearby BLE devices',
              onPressed: _startScan,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_statusBannerMessage != null) ...[
                _buildStatusBanner(),
                const SizedBox(height: 14),
              ],

              // Radar canvas + side metrics
              _buildRadarSection(),
              const SizedBox(height: 20),

              // Mesh Relay Status Card (interactive toggle)
              _buildStatusCard(),

              // P2P Multi-Hop Simulation Drill Card (visible when relay is enabled)
              if (MeshRelayService.instance.isRelayEnabled) ...[
                const SizedBox(height: 16),
                _buildRelayDrillCard(),
              ],
              const SizedBox(height: 20),

              // Discovered & Mesh peer devices list
              _buildPeerDevicesList(),
              const SizedBox(height: 16),

              // Architectural disclaimer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.cyanAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        MeshRelayService.instance.isRelayEnabled
                            ? 'P2P Mesh Simulation Active: Real 2.4 GHz RF BLE discovery is active alongside verified peer forwarding simulation. Outgoing SOS packets include multi-hop relay metadata.'
                            : 'BLE Discovery Phase: Real Bluetooth Low Energy scanning is active. Discovered devices reflect genuine 2.4 GHz RF advertisements. Multi-hop mesh packet relaying is on standby.',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isErrorBanner
            ? AppColors.errorRed.withValues(alpha: 0.12)
            : AppColors.pendingOrange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isErrorBanner ? AppColors.errorRed : AppColors.pendingOrange,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isErrorBanner ? Icons.warning_amber_rounded : Icons.info_rounded,
            color: _isErrorBanner
                ? AppColors.errorRed
                : AppColors.pendingOrange,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _statusBannerMessage!,
              style: TextStyle(
                color: _isErrorBanner
                    ? AppColors.errorRed
                    : AppColors.pendingOrange,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 18),
            color: _isErrorBanner
                ? AppColors.errorRed
                : AppColors.pendingOrange,
            onPressed: _startScan,
          ),
        ],
      ),
    );
  }

  Widget _buildRadarSection() {
    final effective = _effectiveDevices;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          // Radar visualizer
          SizedBox(
            height: 220,
            child: AnimatedBuilder(
              animation: _radarController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _RadarPainter(
                    progress: _radarController.value,
                    devices: effective,
                  ),
                  child: Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.cyanAccent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cyanAccent.withValues(alpha: 0.35),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.phone_android_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),

          // Visual indicator note
          const Text(
            'Visual scan representation • Radar shows relative signal strength (RSSI), not spatial bearing',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),

          // 3 Metric Tiles Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.bluetooth_searching_rounded,
                  iconColor: AppColors.cyanAccent,
                  value: effective.length.toString(),
                  label: 'Discovered BLE',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.alt_route_rounded,
                  iconColor: MeshRelayService.instance.relayedRequestsCount > 0
                      ? AppColors.cyanAccent
                      : AppColors.textMuted,
                  value: MeshRelayService.instance.relayedRequestsCount.toString(),
                  label: 'Relayed Requests',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.sync_rounded,
                  iconColor: _lastScanTime != null
                      ? AppColors.successGreen
                      : AppColors.textMuted,
                  value: _lastScanTime != null
                      ? _formatTimeAgo(_lastScanTime!)
                      : 'Never',
                  label: 'Last Scan',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final isRelayOn = MeshRelayService.instance.isRelayEnabled;
    final dotColor = isRelayOn ? AppColors.cyanAccent : AppColors.pendingOrange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRelayOn
              ? AppColors.cyanAccent.withValues(alpha: 0.35)
              : AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: dotColor.withValues(alpha: 0.45),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRelayOn
                      ? 'P2P SOS Relay Transport (Active)'
                      : 'P2P SOS Relay Transport (Standby)',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isRelayOn
                      ? 'Multi-hop relay forwarding enabled (${MeshRelayService.instance.simulatedHops} hops). SOS packets route across local BLE mesh peers.'
                      : 'Hardware mesh relay driver is in standby. Toggle to activate P2P multi-hop forwarding.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isRelayOn,
            activeThumbColor: AppColors.cyanAccent,
            onChanged: (val) {
              setState(() {
                MeshRelayService.instance.toggleRelay(val);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRelayDrillCard() {
    final hops = MeshRelayService.instance.simulatedHops;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cyanAccent.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyanAccent.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.cyanAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hub_rounded,
                  color: AppColors.cyanAccent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'P2P Multi-Hop Drill Simulation',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Single-phone interactive mesh relay tester',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.cyanAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.cyanAccent.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '$hops Hops',
                  style: const TextStyle(
                    color: AppColors.cyanAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Hop Route visual diagram
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHopNode('Phone', Icons.phone_android_rounded, true),
                const Icon(Icons.arrow_forward_rounded, color: AppColors.cyanAccent, size: 14),
                _buildHopNode('Relay 1', Icons.sensors_rounded, true),
                if (hops > 1) ...[
                  const Icon(Icons.arrow_forward_rounded, color: AppColors.cyanAccent, size: 14),
                  _buildHopNode('Gateway', Icons.router_rounded, true),
                ],
                const Icon(Icons.arrow_forward_rounded, color: AppColors.cyanAccent, size: 14),
                _buildHopNode('Backend', Icons.cloud_done_rounded, true),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Hop selector chips
          Row(
            children: [
              const Text(
                'Simulated Hops:',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              Wrap(
                spacing: 8,
                children: [1, 2, 3].map((h) {
                  final isSelected = h == hops;
                  return ChoiceChip(
                    label: Text('$h ${h == 1 ? 'hop' : 'hops'}'),
                    selected: isSelected,
                    selectedColor: AppColors.cyanAccent.withValues(alpha: 0.25),
                    backgroundColor: AppColors.surfaceElevated,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.cyanAccent : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.cyanAccent : AppColors.border,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          MeshRelayService.instance.setSimulatedHops(h);
                        });
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Run drill button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSimulatingDrill ? null : _runRelayDrill,
              icon: _isSimulatingDrill
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.play_arrow_rounded, size: 18),
              label: Text(_isSimulatingDrill ? 'Relaying Packet Across Mesh...' : 'Run P2P Multi-Hop Drill'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyanAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHopNode(String label, IconData icon, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: active ? AppColors.cyanAccent : AppColors.textMuted,
          size: 18,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: active ? AppColors.textPrimary : AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _runRelayDrill() async {
    setState(() => _isSimulatingDrill = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    MeshRelayService.instance.recordRelayEvent();
    setState(() => _isSimulatingDrill = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Drill Complete: Simulated SOS packet successfully routed through ${MeshRelayService.instance.simulatedHops} hops! Total relayed: ${MeshRelayService.instance.relayedRequestsCount}',
          ),
          backgroundColor: AppColors.card,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.cyanAccent),
          ),
        ),
      );
    }
  }

  Widget _buildPeerDevicesList() {
    final effective = _effectiveDevices;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Discovered BLE Devices (${effective.length})',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (_isScanning)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.cyanAccent,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (effective.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(
                    _isScanning
                        ? Icons.bluetooth_searching_rounded
                        : Icons.bluetooth_rounded,
                    color: AppColors.textMuted,
                    size: 36,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isScanning
                        ? 'Scanning for nearby Bluetooth Low Energy devices...'
                        : 'No BLE devices discovered.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isScanning
                        ? 'Listening for 2.4 GHz RF advertisements (10s window)...'
                        : 'Tap the refresh button in the top bar to scan.',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...effective.map((device) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      device.isJivaanPeer
                          ? Icons.verified_user_rounded
                          : Icons.bluetooth_rounded,
                      color: device.isJivaanPeer
                          ? AppColors.cyanAccent
                          : AppColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.displayName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            device.peerTypeLabel,
                            style: TextStyle(
                              color: device.isJivaanPeer
                                  ? AppColors.cyanAccent
                                  : AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${device.signalQuality} (${device.signalLabel}) • ${device.hopLabel}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: device.isJivaanPeer
                              ? AppColors.cyanAccent.withValues(alpha: 0.4)
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        device.signalLabel,
                        style: TextStyle(
                          color: device.isJivaanPeer
                              ? AppColors.cyanAccent
                              : AppColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double progress;
  final List<BlePeerDevice> devices;

  _RadarPainter({required this.progress, required this.devices});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2 - 12;

    final circlePaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw concentric rings
    for (int i = 1; i <= 3; i++) {
      final r = maxRadius * (i / 3);
      canvas.drawCircle(center, r, circlePaint);
    }

    // Expanding pulse wave
    final pulseRadius = maxRadius * progress;
    final pulsePaint = Paint()
      ..color = AppColors.cyanAccent.withValues(alpha: (1 - progress) * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, pulseRadius, pulsePaint);

    // Crosshairs
    final crossPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(center.dx - maxRadius, center.dy),
      Offset(center.dx + maxRadius, center.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - maxRadius),
      Offset(center.dx, center.dy + maxRadius),
      crossPaint,
    );

    // Render real discovered devices if any
    final displayList = devices.take(8).toList();
    for (int i = 0; i < displayList.length; i++) {
      final dev = displayList[i];
      // Clamped RSSI (-100 to -40 dBm) maps to distance from center
      final clampedRssi = dev.rssi.clamp(-100, -40);
      final normalizedDist =
          0.30 + (1.0 - (clampedRssi - (-100)) / 60.0) * 0.60;
      final dist = maxRadius * normalizedDist;

      // Distribute angularly around radar
      final count = displayList.length;
      final angle =
          (i * (2 * math.pi / (count == 0 ? 1 : count))) - (math.pi / 2);
      final pos = Offset(
        center.dx + dist * math.cos(angle),
        center.dy + dist * math.sin(angle),
      );

      final color = dev.isJivaanPeer
          ? AppColors.cyanAccent
          : AppColors.textMuted;
      final peerPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawLine(
        center,
        pos,
        Paint()
          ..color = color.withValues(alpha: 0.25)
          ..strokeWidth = 1.0,
      );

      canvas.drawCircle(pos, 5, peerPaint);
      canvas.drawCircle(
        pos,
        8,
        Paint()
          ..color = color.withValues(alpha: 0.25)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.devices.length != devices.length;
}
