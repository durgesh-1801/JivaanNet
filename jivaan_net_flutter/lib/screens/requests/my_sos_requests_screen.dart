import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:jivaan_net_client/jivaan_net_client.dart';

import '../../core/theme/app_colors.dart';
import '../../main.dart' as app_main;
import '../../services/connectivity_service.dart';
import '../../services/incident_cache_service.dart';
import '../../shared/widgets/sos_request_card.dart';
import 'request_details_screen.dart';

/// 4. My SOS Requests Screen: Fetches real SOS incidents from the Serverpod backend
/// with persistent offline caching and interactive status filters.
class MySosRequestsScreen extends StatefulWidget {
  final bool showBackButton;
  final Client? client;
  final IncidentCacheService? cacheService;
  final Connectivity? connectivity;

  const MySosRequestsScreen({
    super.key,
    this.showBackButton = true,
    this.client,
    this.cacheService,
    this.connectivity,
  });

  @override
  State<MySosRequestsScreen> createState() => _MySosRequestsScreenState();
}

class _MySosRequestsScreenState extends State<MySosRequestsScreen> {
  String _selectedFilter = 'All';
  List<SosIncident> _incidents = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isShowingCachedData = false;
  DateTime? _lastCacheTime;
  String? _errorMessage;

  late final IncidentCacheService _cacheService;
  late final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  Client get _activeClient => widget.client ?? app_main.client;

  @override
  void initState() {
    super.initState();
    _cacheService = widget.cacheService ?? IncidentCacheService();
    _connectivity = widget.connectivity ?? Connectivity();

    _loadCacheAndFetch();
    _setupConnectivityListener();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  /// Sets up an auto-refresh listener when network connectivity is restored.
  void _setupConnectivityListener() {
    try {
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (results) {
          final hasConnection = results.any(
            (r) => r != ConnectivityResult.none,
          );
          if (hasConnection &&
              _isShowingCachedData &&
              !_isRefreshing &&
              mounted) {
            _fetchFromServer(isBackground: true);
          }
        },
        onError: (e) {
          debugPrint('Connectivity listener error: $e');
        },
      );
    } catch (e) {
      debugPrint('Failed to initialize connectivity listener: $e');
    }
  }

  /// Immediately loads cached incidents, then attempts to fetch fresh data from Serverpod.
  Future<void> _loadCacheAndFetch() async {
    // 1. Instant local cache load
    final cached = await _cacheService.getCachedIncidents();
    final cacheTime = await _cacheService.getLastCacheTime();

    if (mounted && cached.isNotEmpty) {
      setState(() {
        _incidents = cached;
        _lastCacheTime = cacheTime;
        _isShowingCachedData = true;
        _isLoading = false;
      });
    }

    // 2. Fetch fresh data from backend
    await _fetchFromServer(isBackground: cached.isNotEmpty);
  }

  /// Fetches incidents from Serverpod.
  ///
  /// If [isBackground] is true, existing displayed data is kept visible while
  /// fetching, avoiding full-screen loading spinners.
  Future<void> _fetchFromServer({bool isBackground = false}) async {
    if (!mounted) return;

    setState(() {
      if (isBackground || _incidents.isNotEmpty) {
        _isRefreshing = true;
      } else {
        _isLoading = true;
      }
      _errorMessage = null;
    });

    try {
      debugPrint(
        '[MySosRequestsScreen] Fetching incidents from Serverpod at ${_activeClient.host}...',
      );
      final page = await _activeClient.incident.listIncidents(
        page: 1,
        limit: 100,
      );

      // Persist to local storage
      await _cacheService.saveIncidents(page.incidents);
      final now = DateTime.now();

      ConnectivityService.instance.reportSuccess();
      debugPrint(
        '[MySosRequestsScreen] Serverpod responded successfully with ${page.incidents.length} incidents.',
      );

      if (mounted) {
        setState(() {
          _incidents = page.incidents;
          _isShowingCachedData = false;
          _lastCacheTime = now;
          _isLoading = false;
          _isRefreshing = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      ConnectivityService.instance.reportFailure(e);
      debugPrint(
        '[MySosRequestsScreen] Failed to fetch incidents from Serverpod at ${_activeClient.host}: $e',
      );

      if (!mounted) return;

      if (_incidents.isNotEmpty) {
        // Retain cached data on screen and indicate offline/stale state
        setState(() {
          _isShowingCachedData = true;
          _isLoading = false;
          _isRefreshing = false;
        });

        if (!isBackground) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Server unreachable at ${_activeClient.host}. Displaying cached incidents.',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.card,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Retry',
                textColor: AppColors.pendingOrange,
                onPressed: () => _fetchFromServer(isBackground: false),
              ),
            ),
          );
        }
      } else {
        // No cache available and network failed
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _isShowingCachedData = false;
          _errorMessage = _cleanErrorMessage(e);
        });
      }
    }
  }

  String _cleanErrorMessage(Object error) {
    final msg = error.toString();
    if (msg.contains('Connection refused')) {
      return 'Serverpod backend unreachable at ${_activeClient.host}.\nIf testing on an Android device via USB, run "adb reverse tcp:8080 tcp:8080".';
    }
    if (msg.contains('SocketException') || msg.contains('Failed host lookup')) {
      return 'Network socket error connecting to ${_activeClient.host}. Please verify server address and connection.';
    }
    if (msg.startsWith('Exception: ')) {
      return msg.substring('Exception: '.length);
    }
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    final allCount = _incidents.length;
    final pendingCount = _incidents
        .where((i) => i.status.toLowerCase() == 'pending')
        .length;
    final acknowledgedCount = _incidents
        .where((i) => i.status.toLowerCase() == 'acknowledged')
        .length;
    final dispatchedCount = _incidents
        .where((i) => i.status.toLowerCase() == 'dispatched')
        .length;
    final resolvedCount = _incidents
        .where((i) => i.status.toLowerCase() == 'resolved')
        .length;
    const failedCount = 0;

    final filteredIncidents = _incidents.where((i) {
      final status = i.status.toLowerCase();
      switch (_selectedFilter) {
        case 'Pending':
          return status == 'pending';
        case 'Acknowledged':
          return status == 'acknowledged';
        case 'Dispatched':
          return status == 'dispatched';
        case 'Resolved':
          return status == 'resolved';
        case 'Failed':
          return false;
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: const Text('My SOS Requests'),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.sosRed,
                    ),
                  )
                : const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _isLoading || _isRefreshing
                ? null
                : () => _fetchFromServer(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildFilterChip('All', 'All ($allCount)'),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Pending',
                    'Pending ($pendingCount)',
                    color: AppColors.pendingOrange,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Acknowledged',
                    'Acknowledged ($acknowledgedCount)',
                    color: AppColors.blueAccent,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Dispatched',
                    'Dispatched ($dispatchedCount)',
                    color: AppColors.cyanAccent,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Resolved',
                    'Resolved ($resolvedCount)',
                    color: AppColors.successGreen,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Failed',
                    'Failed ($failedCount)',
                    color: AppColors.errorRed,
                  ),
                ],
              ),
            ),

            // Offline Cache Banner (Non-blocking stale data indicator)
            if (_isShowingCachedData && _incidents.isNotEmpty)
              _buildOfflineBanner(),

            // Requests Body
            Expanded(child: _buildBody(filteredIncidents)),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    final lastUpdated = _lastCacheTime != null
        ? ' • Cached ${SosRequestCard.timeAgo(_lastCacheTime!)}'
        : '';
    final connState = ConnectivityService.instance.state;
    final String statusDetail;
    if (connState.hasNetworkConnection) {
      statusDetail =
          'Connected via ${connState.networkLabel}, but Serverpod unreachable at ${_activeClient.host}';
    } else {
      statusDetail = 'No physical network connection (Wi-Fi or cellular)';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.pendingBadgeBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.pendingOrange.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: AppColors.pendingOrange,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Offline Mode • Showing cached incidents$lastUpdated',
                  style: const TextStyle(
                    color: AppColors.pendingOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (_isRefreshing)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.pendingOrange,
                  ),
                )
              else
                InkWell(
                  onTap: () => _fetchFromServer(isBackground: false),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          color: AppColors.pendingOrange,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Retry',
                          style: TextStyle(
                            color: AppColors.pendingOrange,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              statusDetail,
              style: TextStyle(
                color: AppColors.pendingOrange.withValues(alpha: 0.85),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List<SosIncident> filteredIncidents) {
    if (_isLoading && _incidents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.sosRed,
            ),
            SizedBox(height: 16),
            Text(
              'Loading SOS incidents...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null && _incidents.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.failedBadgeBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.errorRed.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  color: AppColors.errorRed,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Offline — No Cached Incidents',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_errorMessage\n\nNo cached incidents are stored on this device. Reconnect to the server and retry.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _fetchFromServer(isBackground: false),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry Connection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sosRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_incidents.isEmpty) {
      return RefreshIndicator(
        color: AppColors.sosRed,
        backgroundColor: AppColors.card,
        onRefresh: () => _fetchFromServer(isBackground: false),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.inbox_rounded,
                      color: AppColors.textMuted,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No SOS Incidents Found',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No emergency incidents have been registered on the server yet. Create an SOS to broadcast your first request.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () => _fetchFromServer(isBackground: false),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (filteredIncidents.isEmpty) {
      return RefreshIndicator(
        color: AppColors.sosRed,
        backgroundColor: AppColors.card,
        onRefresh: () => _fetchFromServer(isBackground: false),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_selectedFilter == 'Failed') ...[
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.failedBadgeBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.errorRed,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Failed Incidents on Server',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'The central database and cache only record incidents successfully registered by Serverpod. Submissions that fail during network disruption remain on the local device or mesh buffer and are not recorded centrally.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ] else ...[
                    const Icon(
                      Icons.filter_list_off_rounded,
                      color: AppColors.textMuted,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No $_selectedFilter Incidents',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'There are currently no incidents matching the "$_selectedFilter" status filter.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.sosRed,
      backgroundColor: AppColors.card,
      onRefresh: () => _fetchFromServer(isBackground: false),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: filteredIncidents.length,
        itemBuilder: (context, index) {
          final incident = filteredIncidents[index];
          return SosRequestCard.fromIncident(
            incident: incident,
            showChevron: true,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RequestDetailsScreen.fromIncident(
                    incident: incident,
                    category: SosRequestCard.inferCategory(incident),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label, {Color? color}) {
    final isSelected = _selectedFilter == filterKey;
    final activeColor = color ?? AppColors.sosRed;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color != null
                    ? activeColor.withValues(alpha: 0.25)
                    : AppColors.sosRed)
              : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
