import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jivaan_net_client/jivaan_net_client.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_colors.dart';
import '../../services/incident_cache_service.dart';
import '../../shared/widgets/status_badge.dart';

/// Represents a dynamic relief resource situated on the map.
class EmergencyMapResource {
  final String id;
  final String name;
  final String type;
  final LatLng location;
  final IconData icon;
  final Color accentColor;
  final String status;
  final double distanceMeters;

  const EmergencyMapResource({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.icon,
    required this.accentColor,
    required this.status,
    required this.distanceMeters,
  });

  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toStringAsFixed(0)} m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }
}

/// 7. Nearby Help Screen: Real interactive OpenStreetMap (OSM) viewer with live GPS,
/// dynamic emergency resources, and cached SOS incident alert markers.
class NearbyHelpScreen extends StatefulWidget {
  final bool showBackButton;

  const NearbyHelpScreen({super.key, this.showBackButton = true});

  @override
  State<NearbyHelpScreen> createState() => _NearbyHelpScreenState();
}

class _NearbyHelpScreenState extends State<NearbyHelpScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final IncidentCacheService _incidentCacheService = IncidentCacheService();

  String _selectedCategory = 'All';
  bool _useDarkTiles = true;
  bool _isLoadingGps = true;
  String? _locationStatusText;

  LatLng _currentCenter = const LatLng(26.9124, 75.7873); // Default anchor
  LatLng? _userGpsLocation;
  List<SosIncident> _cachedIncidents = [];
  List<EmergencyMapResource> _dynamicResources = [];
  EmergencyMapResource? _selectedResource;
  SosIncident? _selectedIncident;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initLocationAndResources();
    _loadCachedIncidents();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initLocationAndResources() async {
    setState(() {
      _isLoadingGps = true;
      _locationStatusText = 'Acquiring GPS fix...';
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _locationStatusText = 'Location service disabled (using fallback)';
            _isLoadingGps = false;
            _generateNearbyResources(_currentCenter);
          });
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _locationStatusText = 'GPS permission denied (using fallback)';
            _isLoadingGps = false;
            _generateNearbyResources(_currentCenter);
          });
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final userPos = LatLng(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          _userGpsLocation = userPos;
          _currentCenter = userPos;
          _isLoadingGps = false;
          _locationStatusText =
              '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
          _generateNearbyResources(userPos);
        });

        // Smoothly center map camera to user position
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(userPos, 14.5);
        });
      }
    } catch (e) {
      debugPrint('NearbyHelpScreen: Error acquiring location: $e');
      if (mounted) {
        setState(() {
          _isLoadingGps = false;
          _locationStatusText = 'GPS timeout (using default)';
          _generateNearbyResources(_currentCenter);
        });
      }
    }
  }

  Future<void> _loadCachedIncidents() async {
    try {
      final incidents = await _incidentCacheService.getCachedIncidents();
      if (mounted) {
        setState(() {
          _cachedIncidents = incidents;
        });
      }
    } catch (e) {
      debugPrint('NearbyHelpScreen: Could not load cached incidents: $e');
    }
  }

  void _generateNearbyResources(LatLng center) {
    // Dynamically generates realistic emergency response points surrounding the user's real GPS anchor
    final items = [
      EmergencyMapResource(
        id: 'res_hospital',
        name: 'Emergency Trauma Care',
        type: 'Medical Facility',
        location: LatLng(center.latitude + 0.0072, center.longitude + 0.0055),
        icon: Icons.local_hospital_rounded,
        accentColor: AppColors.cyanAccent,
        status: 'Open 24/7',
        distanceMeters: Geolocator.distanceBetween(
          center.latitude,
          center.longitude,
          center.latitude + 0.0072,
          center.longitude + 0.0055,
        ),
      ),
      EmergencyMapResource(
        id: 'res_shelter',
        name: 'Community Relief Shelter',
        type: 'Government Shelter',
        location: LatLng(center.latitude - 0.0064, center.longitude - 0.0048),
        icon: Icons.night_shelter_rounded,
        accentColor: AppColors.pendingOrange,
        status: 'Capacity 180/300',
        distanceMeters: Geolocator.distanceBetween(
          center.latitude,
          center.longitude,
          center.latitude - 0.0064,
          center.longitude - 0.0048,
        ),
      ),
      EmergencyMapResource(
        id: 'res_food',
        name: 'Disaster Food & Water Supply',
        type: 'NGO Relief Camp',
        location: LatLng(center.latitude + 0.0045, center.longitude - 0.0082),
        icon: Icons.restaurant_rounded,
        accentColor: AppColors.pendingOrange,
        status: 'Distributing Now',
        distanceMeters: Geolocator.distanceBetween(
          center.latitude,
          center.longitude,
          center.latitude + 0.0045,
          center.longitude - 0.0082,
        ),
      ),
      EmergencyMapResource(
        id: 'res_police',
        name: 'Disaster Coordination Post',
        type: 'Police & First Responders',
        location: LatLng(center.latitude - 0.0035, center.longitude + 0.0090),
        icon: Icons.local_police_rounded,
        accentColor: AppColors.successGreen,
        status: 'Active',
        distanceMeters: Geolocator.distanceBetween(
          center.latitude,
          center.longitude,
          center.latitude - 0.0035,
          center.longitude + 0.0090,
        ),
      ),
    ];

    // Sort by proximity
    items.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    _dynamicResources = items;
  }

  void _recenterToUser() {
    if (_userGpsLocation != null) {
      _mapController.move(_userGpsLocation!, 15.0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Map recentered to your live GPS location.'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _initLocationAndResources();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredResources = _dynamicResources.where((r) {
      if (_selectedCategory == 'Shelters') return r.type.contains('Shelter');
      if (_selectedCategory == 'Medical') return r.type.contains('Medical');
      if (_selectedCategory == 'Food') return r.type.contains('Relief Camp') || r.type.contains('Food');
      if (_selectedCategory == 'Incidents') return false;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: const Text('Nearby Help & Map'),
        actions: [
          // Refresh GPS button
          IconButton(
            icon: _isLoadingGps
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.sosRed,
                    ),
                  )
                : const Icon(Icons.my_location_rounded),
            tooltip: 'Recenter to my GPS',
            onPressed: _recenterToUser,
          ),
          // Toggle Dark/Light Map Tiles
          IconButton(
            icon: Icon(
              _useDarkTiles ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            tooltip: _useDarkTiles ? 'Switch to Standard Map' : 'Switch to Dark Map',
            onPressed: () {
              setState(() {
                _useDarkTiles = !_useDarkTiles;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildCategoryChip('All'),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Shelters'),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Medical'),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Food'),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Incidents'),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Live OpenStreetMap Area
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1829),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentCenter,
                        initialZoom: 14.0,
                        minZoom: 3.0,
                        maxZoom: 18.0,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                        onTap: (_, p) {
                          if (_selectedResource != null || _selectedIncident != null) {
                            setState(() {
                              _selectedResource = null;
                              _selectedIncident = null;
                            });
                          }
                        },
                      ),
                      children: [
                        // OpenStreetMap Tiles Layer (100% Free & No API key needed)
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'org.jivaannet.jivaan_net_flutter',
                          tileBuilder: _useDarkTiles
                              ? (context, tileWidget, tile) {
                                  return ColorFiltered(
                                    colorFilter: const ColorFilter.matrix(<double>[
                                      -0.65, 0, 0, 0, 215, // Red
                                      0, -0.65, 0, 0, 220, // Green
                                      0, 0, -0.55, 0, 230, // Blue (subtle tactical slate tone)
                                      0, 0, 0, 1, 0,
                                    ]),
                                    child: tileWidget,
                                  );
                                }
                              : null,
                        ),

                        // Markers Layer
                        MarkerLayer(
                          markers: [
                            // 1. User Location Marker
                            if (_userGpsLocation != null)
                              Marker(
                                point: _userGpsLocation!,
                                width: 50,
                                height: 50,
                                child: AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, _) {
                                    final scale = 1.0 + (_pulseController.value * 0.25);
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: 38 * scale,
                                          height: 38 * scale,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.sosRed.withValues(
                                              alpha: 0.25 * (1 - _pulseController.value),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: AppColors.sosRed,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2.5),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.sosRed.withValues(alpha: 0.6),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),

                            // 2. Relief Resources Markers
                            if (_selectedCategory != 'Incidents')
                              ...filteredResources.map((res) {
                                final isSelected = _selectedResource?.id == res.id;
                                return Marker(
                                  point: res.location,
                                  width: 70,
                                  height: 60,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedResource = res;
                                        _selectedIncident = null;
                                      });
                                      _mapController.move(res.location, 15.5);
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            color: isSelected ? Colors.white : AppColors.card,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: res.accentColor,
                                              width: isSelected ? 3 : 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: res.accentColor.withValues(alpha: 0.5),
                                                blurRadius: isSelected ? 12 : 6,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            res.icon,
                                            color: res.accentColor,
                                            size: 18,
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 2),
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.8),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: res.accentColor.withValues(alpha: 0.5),
                                              width: 0.5,
                                            ),
                                          ),
                                          child: Text(
                                            res.name.split(' ').first,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),

                            // 3. Cached SOS Incidents Markers
                            if (_selectedCategory == 'All' || _selectedCategory == 'Incidents')
                              ..._cachedIncidents.map((incident) {
                                final point = LatLng(incident.latitude, incident.longitude);
                                final isSelected = _selectedIncident?.incidentId == incident.incidentId;
                                return Marker(
                                  point: point,
                                  width: 60,
                                  height: 55,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedIncident = incident;
                                        _selectedResource = null;
                                      });
                                      _mapController.move(point, 16.0);
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.sosRed,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: isSelected ? 3 : 1.5,
                                            ),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: AppColors.sosRed,
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.warning_amber_rounded,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 2),
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppColors.sosRed.withValues(alpha: 0.9),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'SOS (${incident.severity})',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ],
                    ),

                    // Map Zoom (+ / -) Overlay Controls
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMapControlButton(
                            icon: Icons.add_rounded,
                            onPressed: () {
                              final zoom = _mapController.camera.zoom + 1.0;
                              _mapController.move(_mapController.camera.center, math.min(zoom, 18.0));
                            },
                          ),
                          const SizedBox(height: 6),
                          _buildMapControlButton(
                            icon: Icons.remove_rounded,
                            onPressed: () {
                              final zoom = _mapController.camera.zoom - 1.0;
                              _mapController.move(_mapController.camera.center, math.max(zoom, 3.0));
                            },
                          ),
                        ],
                      ),
                    ),

                    // Selected Item Floating Callout (if tapped)
                    if (_selectedResource != null)
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 60,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.card.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _selectedResource!.accentColor),
                            boxShadow: const [
                              BoxShadow(color: Colors.black45, blurRadius: 10),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(_selectedResource!.icon, color: _selectedResource!.accentColor, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedResource!.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${_selectedResource!.type} • ${_selectedResource!.formattedDistance}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                                onPressed: () => setState(() => _selectedResource = null),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Selected Incident Callout
                    if (_selectedIncident != null)
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 60,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.card.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.sosRed),
                            boxShadow: const [
                              BoxShadow(color: Colors.black45, blurRadius: 10),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: AppColors.sosRed, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'SOS Incident: ${_selectedIncident!.severity.toUpperCase()}',
                                      style: const TextStyle(
                                        color: AppColors.sosRed,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _selectedIncident!.description ?? 'Emergency SOS',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                                onPressed: () => setState(() => _selectedIncident = null),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Live OpenStreetMap Banner & GPS Status
                    Positioned(
                      bottom: 8,
                      left: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border, width: 0.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: _userGpsLocation != null
                                        ? AppColors.successGreen
                                        : AppColors.pendingOrange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _userGpsLocation != null
                                      ? 'Live GPS • ${_locationStatusText ?? ""}'
                                      : (_locationStatusText ?? 'Acquiring GPS...'),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              '© OpenStreetMap',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Bottom List of Help Resources & Incidents
            Expanded(
              flex: 4,
              child: filteredResources.isEmpty && _cachedIncidents.isEmpty
                  ? const Center(
                      child: Text(
                        'No emergency facilities in this filter',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      children: [
                        // If Incidents filter or All: show active SOS alerts
                        if ((_selectedCategory == 'All' || _selectedCategory == 'Incidents') &&
                            _cachedIncidents.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Active SOS Incidents on Map',
                              style: TextStyle(
                                color: AppColors.sosRed,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ..._cachedIncidents.map((incident) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: AppColors.card,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: AppColors.border),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    setState(() {
                                      _selectedIncident = incident;
                                      _selectedResource = null;
                                    });
                                    _mapController.move(
                                      LatLng(incident.latitude, incident.longitude),
                                      15.5,
                                    );
                                  },
                                  leading: const CircleAvatar(
                                    backgroundColor: AppColors.failedBadgeBg,
                                    child: Icon(Icons.warning_rounded, color: AppColors.sosRed),
                                  ),
                                  title: Text(
                                    incident.description ?? 'Emergency SOS',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Triage: ${incident.severity.toUpperCase()} • Status: ${incident.status}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  trailing: const Icon(Icons.navigation_rounded, color: AppColors.sosRed),
                                ),
                              )),
                          const Divider(color: AppColors.border, height: 20),
                        ],

                        // Relief facilities list
                        if (_selectedCategory != 'Incidents') ...[
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Nearby Relief Resources',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...filteredResources.map((resource) {
                            final isSelected = _selectedResource?.id == resource.id;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              color: isSelected ? AppColors.surfaceElevated : AppColors.card,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: isSelected ? resource.accentColor : AppColors.border,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedResource = resource;
                                    _selectedIncident = null;
                                  });
                                  _mapController.move(resource.location, 16.0);
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: resource.accentColor.withValues(alpha: 0.18),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          resource.icon,
                                          color: resource.accentColor,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              resource.name,
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              resource.type,
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            resource.formattedDistance,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          StatusBadge.open(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 4),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: Colors.white),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final isSelected = _selectedCategory == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = label;
          _selectedResource = null;
          _selectedIncident = null;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.sosRed : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.sosRed : AppColors.border,
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
