import 'package:flutter/material.dart';
import 'package:jivaan_net_client/jivaan_net_client.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock/sample_data.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_badge.dart';

/// 5. Request Details Screen: Granular incident view with timeline tracking.
/// Supports both real [SosIncident] returned by Serverpod and mock [SampleSosRequest] previews.
class RequestDetailsScreen extends StatelessWidget {
  final SampleSosRequest? request;
  final SosIncident? incident;
  final EmergencyCategory? category;

  /// Constructor for mock preview requests.
  const RequestDetailsScreen({
    super.key,
    required SampleSosRequest this.request,
  }) : incident = null,
       category = null;

  /// Constructor for actual server-persisted SOS incidents.
  const RequestDetailsScreen.fromIncident({
    super.key,
    required SosIncident this.incident,
    this.category = EmergencyCategory.medical,
  }) : request = null;

  bool get isLiveIncident => incident != null;

  EmergencyCategory get effectiveCategory => isLiveIncident
      ? (category ?? EmergencyCategory.medical)
      : request!.category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Request Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Banner: Category Icon, Title, Status Badge
              _buildHeaderBanner(),
              const SizedBox(height: 16),

              // Details Card (ID, Severity, Status, Created At, Location, Description)
              _buildDetailsCard(),
              const SizedBox(height: 24),

              // Status Timeline
              const SectionHeader(title: 'Status Timeline'),
              const SizedBox(height: 8),
              _buildTimelineCard(),
              const SizedBox(height: 20),

              // Banner: Server verification for live incidents or preview disclaimer for mocks
              _buildBanner(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    final cat = effectiveCategory;
    final title = isLiveIncident ? cat.fullTitle : request!.title;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cat.bgTint,
              shape: BoxShape.circle,
            ),
            child: Icon(cat.icon, color: cat.accentColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (!isLiveIncident) {
      return StatusBadge.fromStatus(request!.status);
    }

    final status = incident!.status.toLowerCase();
    Color foreground;
    Color background;
    String label;

    switch (status) {
      case 'pending':
        foreground = AppColors.pendingOrange;
        background = AppColors.pendingBadgeBg;
        label = 'Pending';
        break;
      case 'acknowledged':
        foreground = AppColors.blueAccent;
        background = const Color(0x33388AF6);
        label = 'Acknowledged';
        break;
      case 'dispatched':
        foreground = AppColors.cyanAccent;
        background = const Color(0x3300D2FF);
        label = 'Dispatched';
        break;
      case 'resolved':
        foreground = AppColors.successGreen;
        background = AppColors.successBadgeBg;
        label = 'Resolved';
        break;
      default:
        foreground = AppColors.textPrimary;
        background = AppColors.surfaceElevated;
        label = status.isNotEmpty
            ? '${status[0].toUpperCase()}${status.substring(1)}'
            : 'Unknown';
    }

    return StatusBadge(
      label: label,
      foregroundColor: foreground,
      backgroundColor: background,
    );
  }

  Widget _buildDetailsCard() {
    final id = isLiveIncident ? incident!.incidentId : request!.id;
    final timeStr = isLiveIncident
        ? _formatTimestamp(incident!.createdAt)
        : request!.formattedTime;
    final description = isLiveIncident
        ? (incident!.description?.isNotEmpty == true
              ? incident!.description!
              : 'No description provided.')
        : request!.description;

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
          _buildFieldRow(isLiveIncident ? 'Incident ID' : 'Request ID', id),
          if (isLiveIncident) ...[
            const Divider(height: 20, color: AppColors.border),
            _buildSeverityRow(incident!.severity),
            const Divider(height: 20, color: AppColors.border),
            _buildFieldRow('Status', _formatStatus(incident!.status)),
          ],
          const Divider(height: 20, color: AppColors.border),
          _buildFieldRow('Created At', timeStr),
          const Divider(height: 20, color: AppColors.border),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 90,
                child: Text(
                  'Location',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.location_on_rounded,
                color: AppColors.sosRed,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  isLiveIncident
                      ? '${_formatCoordinates(incident!.latitude, incident!.longitude)}\nLat: ${incident!.latitude.toStringAsFixed(6)}, Lng: ${incident!.longitude.toStringAsFixed(6)}'
                      : '${request!.coordinates}\n${request!.location}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.border),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Description',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityRow(String severity) {
    Color fg;
    Color bg;
    switch (severity.toLowerCase()) {
      case 'critical':
        fg = AppColors.sosRed;
        bg = const Color(0x33E53935);
        break;
      case 'high':
        fg = AppColors.pendingOrange;
        bg = const Color(0x33FF9F0A);
        break;
      case 'medium':
        fg = AppColors.cyanAccent;
        bg = const Color(0x3300D2FF);
        break;
      case 'low':
        fg = AppColors.successGreen;
        bg = const Color(0x3330D158);
        break;
      default:
        fg = AppColors.textSecondary;
        bg = AppColors.surfaceElevated;
    }

    final formatted = severity.isNotEmpty
        ? '${severity[0].toUpperCase()}${severity.substring(1)}'
        : 'Unknown';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 90,
          child: Text(
            'Severity',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        StatusBadge(
          label: formatted,
          foregroundColor: fg,
          backgroundColor: bg,
          fontSize: 11,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        ),
      ],
    );
  }

  Widget _buildFieldRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineCard() {
    final timelineSteps = isLiveIncident
        ? _buildIncidentTimeline()
        : request!.timeline;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: timelineSteps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isLast = index == timelineSteps.length - 1;

          Color iconColor;
          Color circleBg;

          if (step.isCompleted) {
            iconColor = AppColors.successGreen;
            circleBg = const Color(0x2B30D158);
          } else if (step.isCurrent) {
            iconColor = AppColors.pendingOrange;
            circleBg = const Color(0x2BFF9F0A);
          } else {
            iconColor = AppColors.textMuted;
            circleBg = AppColors.surfaceElevated;
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: circleBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(step.icon, color: iconColor, size: 16),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 34,
                      color: step.isCompleted
                          ? AppColors.successGreen.withValues(alpha: 0.4)
                          : AppColors.border,
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: TextStyle(
                          color: step.isCompleted || step.isCurrent
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step.subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<StatusTimelineStep> _buildIncidentTimeline() {
    final status = incident!.status.toLowerCase();
    final isPending = status == 'pending';
    final isAcknowledged = status == 'acknowledged';
    final isDispatched = status == 'dispatched';
    final isResolved = status == 'resolved';

    return [
      StatusTimelineStep(
        title: 'Created on device',
        subtitle:
            'Recorded with live GPS coordinates (${_formatTimestamp(incident!.createdAt)})',
        isCompleted: true,
        icon: Icons.phone_android_rounded,
      ),
      StatusTimelineStep(
        title: 'Delivered to Serverpod',
        subtitle:
            'Received directly by backend API (${_formatTimestamp(incident!.receivedAt)})',
        isCompleted: true,
        icon: Icons.cloud_done_rounded,
      ),
      StatusTimelineStep(
        title: 'Incident Registration',
        subtitle: isPending
            ? 'Status: Pending response coordination'
            : 'Status: ${_formatStatus(incident!.status)}',
        isCompleted: !isPending,
        isCurrent: isPending,
        icon: Icons.verified_rounded,
      ),
      if (isAcknowledged || isDispatched || isResolved)
        StatusTimelineStep(
          title: 'Acknowledged by Coordinator',
          subtitle: incident!.claimedBy != null
              ? 'Claimed by: ${incident!.claimedBy}'
              : 'Dispatcher acknowledged receipt',
          isCompleted: isDispatched || isResolved,
          isCurrent: isAcknowledged,
          icon: Icons.assignment_ind_rounded,
        ),
      if (isDispatched || isResolved)
        StatusTimelineStep(
          title: 'Emergency Responders Dispatched',
          subtitle: 'Field units en route to coordinates',
          isCompleted: isResolved,
          isCurrent: isDispatched,
          icon: Icons.emergency_rounded,
        ),
      if (isResolved)
        StatusTimelineStep(
          title: 'Incident Resolved',
          subtitle: incident!.resolvedAt != null
              ? 'Resolved at ${_formatTimestamp(incident!.resolvedAt!)}'
              : 'Marked resolved on server',
          isCompleted: true,
          icon: Icons.check_circle_rounded,
        ),
    ];
  }

  Widget _buildBanner() {
    if (isLiveIncident) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.cloud_done_rounded,
              color: AppColors.successGreen,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'LIVE SERVER INCIDENT: Verified & registered with Serverpod backend (Relay count: ${incident!.relayCount}).',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.offline_bolt_rounded,
            color: AppColors.cyanAccent,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              MockDataProvider.disclaimer,
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatCoordinates(double lat, double lng) {
    final latDir = lat >= 0 ? 'N' : 'S';
    final lngDir = lng >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(4)}° $latDir, ${lng.abs().toStringAsFixed(4)}° $lngDir';
  }

  static String _formatTimestamp(DateTime dt) {
    final local = dt.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[local.month - 1];
    final day = local.day.toString().padLeft(2, '0');
    final year = local.year;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$month $day, $year • $hour:$minute';
  }

  static String _formatStatus(String status) {
    if (status.isEmpty) return 'Unknown';
    return '${status[0].toUpperCase()}${status.substring(1)}';
  }
}
