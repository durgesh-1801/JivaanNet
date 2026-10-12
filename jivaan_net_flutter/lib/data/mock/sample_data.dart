import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Status of an SOS request in the offline-first lifecycle.
enum SosRequestStatus {
  pending('Pending', AppColors.pendingOrange, AppColors.pendingBadgeBg),
  synced('Synced', AppColors.successGreen, AppColors.successBadgeBg),
  failed('Failed', AppColors.errorRed, AppColors.failedBadgeBg);

  final String label;
  final Color foreground;
  final Color background;

  const SosRequestStatus(this.label, this.foreground, this.background);
}

/// Core emergency categories matching JivaanNet design specifications.
enum EmergencyCategory {
  medical(
    'Medical',
    'Medical Emergency',
    Icons.favorite_rounded,
    AppColors.sosRed,
    Color(0x33E53935),
  ),
  rescue(
    'Rescue',
    'Rescue Operation',
    Icons.person_pin_circle_rounded,
    AppColors.cyanAccent,
    Color(0x3300D2FF),
  ),
  foodWater(
    'Food & Water',
    'Food & Water Relief',
    Icons.restaurant_rounded,
    AppColors.pendingOrange,
    Color(0x33FF9F0A),
  ),
  other(
    'Other',
    'General Emergency',
    Icons.more_horiz_rounded,
    Color(0xFF8B9CB5),
    Color(0x338B9CB5),
  );

  final String label;
  final String fullTitle;
  final IconData icon;
  final Color accentColor;
  final Color bgTint;

  const EmergencyCategory(
    this.label,
    this.fullTitle,
    this.icon,
    this.accentColor,
    this.bgTint,
  );
}

/// Timeline entry tracking offline-first message progression.
class StatusTimelineStep {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrent;
  final IconData icon;

  const StatusTimelineStep({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    this.isCurrent = false,
    required this.icon,
  });
}

/// Simulated SOS request preview model.
///
/// NOTE: This is strictly for UI layout demonstration and offline UI prototyping.
/// Real emergency dispatch and Serverpod client networking will bind to actual endpoints.
class SampleSosRequest {
  final String id;
  final EmergencyCategory category;
  final String title;
  final String description;
  final String location;
  final String coordinates;
  final String formattedTime;
  final String timeAgo;
  final SosRequestStatus status;
  final List<StatusTimelineStep> timeline;

  const SampleSosRequest({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.location,
    required this.coordinates,
    required this.formattedTime,
    required this.timeAgo,
    required this.status,
    required this.timeline,
  });
}

/// Sample emergency contact for the contacts screen preview.
class SampleEmergencyContact {
  final String id;
  final String name;
  final String phone;
  final bool isPrimary;

  const SampleEmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.isPrimary = false,
  });
}

/// Sample relief resource for the nearby help screen preview.
class SampleReliefResource {
  final String id;
  final String name;
  final String type;
  final String distance;
  final String status;
  final IconData icon;
  final Color accentColor;

  const SampleReliefResource({
    required this.id,
    required this.name,
    required this.type,
    required this.distance,
    required this.status,
    required this.icon,
    required this.accentColor,
  });
}

/// Central catalog of preview mock data.
abstract final class MockDataProvider {
  static const String disclaimer =
      'UI PREVIEW MODE: Live GPS, real mesh broadcast, and Serverpod sync are not connected yet.';

  static const String mockCurrentLocation = 'Jaipur, Rajasthan';
  static const String mockCoordinates = '26.9124° N, 75.7873° E';

  static final List<SampleSosRequest> requests = [
    const SampleSosRequest(
      id: '#JVN-20261015-001',
      category: EmergencyCategory.medical,
      title: 'Medical Emergency',
      description: 'Need immediate medical assistance. 2 people injured after building collapse.',
      location: 'Jaipur, Rajasthan',
      coordinates: '26.9124° N, 75.7873° E',
      formattedTime: '15 Oct 2026, 9:32 AM',
      timeAgo: '2 mins ago',
      status: SosRequestStatus.pending,
      timeline: [
        StatusTimelineStep(
          title: 'Created on device',
          subtitle: '15 Oct 2026, 9:32 AM',
          isCompleted: true,
          icon: Icons.check_circle_rounded,
        ),
        StatusTimelineStep(
          title: 'Saved locally',
          subtitle: 'Request stored in offline queue',
          isCompleted: true,
          icon: Icons.check_circle_rounded,
        ),
        StatusTimelineStep(
          title: 'Waiting for connectivity',
          subtitle: 'Will sync when network is available',
          isCompleted: false,
          isCurrent: true,
          icon: Icons.access_time_filled_rounded,
        ),
        StatusTimelineStep(
          title: 'Delivered to server',
          subtitle: 'Pending...',
          isCompleted: false,
          icon: Icons.cloud_upload_rounded,
        ),
      ],
    ),
    const SampleSosRequest(
      id: '#JVN-20261014-002',
      category: EmergencyCategory.rescue,
      title: 'Rescue',
      description:
          'Rising water level in street. Family of 4 stranded on terrace.',
      location: 'Ajmer, Rajasthan',
      coordinates: '26.4499° N, 74.6399° E',
      formattedTime: '14 Oct 2026, 4:15 PM',
      timeAgo: '1 day ago',
      status: SosRequestStatus.synced,
      timeline: [
        StatusTimelineStep(
          title: 'Created on device',
          subtitle: '14 Oct 2026, 4:15 PM',
          isCompleted: true,
          icon: Icons.check_circle_rounded,
        ),
        StatusTimelineStep(
          title: 'Saved locally',
          subtitle: 'Stored in offline queue',
          isCompleted: true,
          icon: Icons.check_circle_rounded,
        ),
        StatusTimelineStep(
          title: 'Relayed via Mesh',
          subtitle: 'Forwarded by 2 nearby peers',
          isCompleted: true,
          icon: Icons.hub_rounded,
        ),
        StatusTimelineStep(
          title: 'Delivered to server',
          subtitle: 'Acknowledged by Central Dispatch',
          isCompleted: true,
          icon: Icons.cloud_done_rounded,
        ),
      ],
    ),
    const SampleSosRequest(
      id: '#JVN-20261013-003',
      category: EmergencyCategory.foodWater,
      title: 'Food & Water',
      description:
          'Potable drinking water running critically low for 25 people.',
      location: 'Jaipur, Rajasthan',
      coordinates: '26.9124° N, 75.7873° E',
      formattedTime: '13 Oct 2026, 11:20 AM',
      timeAgo: '2 days ago',
      status: SosRequestStatus.synced,
      timeline: [
        StatusTimelineStep(
          title: 'Created on device',
          subtitle: '13 Oct 2026, 11:20 AM',
          isCompleted: true,
          icon: Icons.check_circle_rounded,
        ),
        StatusTimelineStep(
          title: 'Delivered to server',
          subtitle: 'Acknowledged by NGO relief point',
          isCompleted: true,
          icon: Icons.cloud_done_rounded,
        ),
      ],
    ),
    const SampleSosRequest(
      id: '#JVN-20261012-004',
      category: EmergencyCategory.other,
      title: 'Other',
      description:
          'Power transformer blast caused local blackout and fire hazard.',
      location: 'Jaipur, Rajasthan',
      coordinates: '26.9124° N, 75.7873° E',
      formattedTime: '12 Oct 2026, 6:45 PM',
      timeAgo: '3 days ago',
      status: SosRequestStatus.failed,
      timeline: [
        StatusTimelineStep(
          title: 'Created on device',
          subtitle: '12 Oct 2026, 6:45 PM',
          isCompleted: true,
          icon: Icons.check_circle_rounded,
        ),
        StatusTimelineStep(
          title: 'Transmission Failed',
          subtitle: 'No peers found within timeout window. Retrying queued.',
          isCompleted: false,
          isCurrent: true,
          icon: Icons.error_rounded,
        ),
      ],
    ),
    const SampleSosRequest(
      id: '#JVN-20261010-005',
      category: EmergencyCategory.medical,
      title: 'Medical Emergency',
      description: 'Elderly person suffering severe dehydration and fever.',
      location: 'Jaipur, Rajasthan',
      coordinates: '26.9124° N, 75.7873° E',
      formattedTime: '10 Oct 2026, 2:10 PM',
      timeAgo: '5 days ago',
      status: SosRequestStatus.pending,
      timeline: [
        StatusTimelineStep(
          title: 'Created on device',
          subtitle: '10 Oct 2026, 2:10 PM',
          isCompleted: true,
          icon: Icons.check_circle_rounded,
        ),
        StatusTimelineStep(
          title: 'Waiting for connectivity',
          subtitle: 'Queued locally in offline database',
          isCompleted: false,
          isCurrent: true,
          icon: Icons.access_time_filled_rounded,
        ),
      ],
    ),
  ];

  static final List<SampleEmergencyContact> contacts = [
    const SampleEmergencyContact(
      id: 'c1',
      name: 'Mom',
      phone: '+91 98765 43210',
      isPrimary: true,
    ),
    const SampleEmergencyContact(
      id: 'c2',
      name: 'Dad',
      phone: '+91 98765 43211',
    ),
    const SampleEmergencyContact(
      id: 'c3',
      name: 'Sibling',
      phone: '+91 98765 43212',
    ),
    const SampleEmergencyContact(
      id: 'c4',
      name: 'Friend',
      phone: '+91 98765 43213',
    ),
  ];

  static final List<SampleReliefResource> resources = [
    const SampleReliefResource(
      id: 'r1',
      name: 'City Relief Shelter',
      type: 'Government Shelter',
      distance: '2.3 km',
      status: 'Open',
      icon: Icons.night_shelter_rounded,
      accentColor: AppColors.pendingOrange,
    ),
    const SampleReliefResource(
      id: 'r2',
      name: 'Civil Hospital',
      type: 'Medical Facility',
      distance: '3.1 km',
      status: 'Open',
      icon: Icons.local_hospital_rounded,
      accentColor: AppColors.cyanAccent,
    ),
    const SampleReliefResource(
      id: 'r3',
      name: 'Food Distribution Center',
      type: 'NGO Relief Camp',
      distance: '4.5 km',
      status: 'Open',
      icon: Icons.restaurant_rounded,
      accentColor: AppColors.pendingOrange,
    ),
  ];
}
