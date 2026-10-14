import 'package:flutter/material.dart';
import 'package:jivaan_net_client/jivaan_net_client.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock/sample_data.dart';
import 'status_badge.dart';

/// Card widget representing an SOS incident in list or recent activity views.
/// Supports both server-persisted [SosIncident] and preview [SampleSosRequest].
class SosRequestCard extends StatelessWidget {
  final SampleSosRequest? request;
  final SosIncident? incident;
  final VoidCallback onTap;
  final bool showChevron;
  final bool compact;

  /// Constructor for preview mock requests.
  const SosRequestCard({
    super.key,
    required SampleSosRequest this.request,
    required this.onTap,
    this.showChevron = true,
    this.compact = false,
  }) : incident = null;

  /// Constructor for live Serverpod incidents.
  const SosRequestCard.fromIncident({
    super.key,
    required SosIncident this.incident,
    required this.onTap,
    this.showChevron = true,
    this.compact = false,
  }) : request = null;

  bool get isLive => incident != null;

  @override
  Widget build(BuildContext context) {
    if (isLive) {
      return _buildIncidentCard(context, incident!);
    }
    return _buildMockRequestCard(context, request!);
  }

  /// Builds the card for live Serverpod incidents.
  Widget _buildIncidentCard(BuildContext context, SosIncident incident) {
    final cat = inferCategory(incident);
    final hasDesc =
        incident.description != null && incident.description!.trim().isNotEmpty;
    final title = hasDesc
        ? incident.description!.trim()
        : 'Emergency SOS #${shortId(incident.incidentId)}';
    final coordStr = formatCoordinates(incident.latitude, incident.longitude);
    final formattedTime = formatTimestamp(incident.createdAt);
    final relativeTime = timeAgo(incident.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Category icon badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cat.bgTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(cat.icon, color: cat.accentColor, size: 24),
              ),
              const SizedBox(width: 14),

              // Incident Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          '#${shortId(incident.incidentId)}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (incident.relayCount > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cyanAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.cyanAccent.withValues(alpha: 0.4),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.hub_rounded,
                                  color: AppColors.cyanAccent,
                                  size: 9,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${incident.relayCount}h',
                                  style: const TextStyle(
                                    color: AppColors.cyanAccent,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const Text(
                          ' • ',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            compact ? relativeTime : formattedTime,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.sosRed,
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            coordStr,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Status and Severity badges
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusBadge.fromIncidentStatus(incident.status),
                  const SizedBox(height: 4),
                  StatusBadge.fromSeverity(incident.severity),
                ],
              ),

              if (showChevron) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the card for mock/preview requests.
  Widget _buildMockRequestCard(BuildContext context, SampleSosRequest req) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Category icon badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: req.category.bgTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  req.category.icon,
                  color: req.category.accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Incident Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      req.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    if (compact) ...[
                      Text(
                        req.location,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else ...[
                      Text(
                        req.formattedTime,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        req.location,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Status and action
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusBadge.fromStatus(req.status),
                  if (compact) ...[
                    const SizedBox(height: 4),
                    Text(
                      req.timeAgo,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),

              if (showChevron) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Classifies category from an incident's description.
  static EmergencyCategory inferCategory(SosIncident incident) {
    final desc = incident.description?.toLowerCase() ?? '';
    if (desc.contains('food') ||
        desc.contains('water') ||
        desc.contains('ration') ||
        desc.contains('starv')) {
      return EmergencyCategory.foodWater;
    }
    if (desc.contains('trapped') ||
        desc.contains('buried') ||
        desc.contains('rescue') ||
        desc.contains('flood') ||
        desc.contains('boat') ||
        desc.contains('collapse')) {
      return EmergencyCategory.rescue;
    }
    if (desc.contains('bleed') ||
        desc.contains('cardiac') ||
        desc.contains('unconscious') ||
        desc.contains('injur') ||
        desc.contains('burn') ||
        desc.contains('fracture') ||
        desc.contains('medic') ||
        desc.contains('doctor') ||
        desc.contains('hospital')) {
      return EmergencyCategory.medical;
    }
    return EmergencyCategory.other;
  }

  /// Formats geographic coordinates into human-readable notation.
  static String formatCoordinates(double lat, double lng) {
    final latDir = lat >= 0 ? 'N' : 'S';
    final lngDir = lng >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(4)}° $latDir, ${lng.abs().toStringAsFixed(4)}° $lngDir';
  }

  /// Formats a [DateTime] into a friendly local timestamp string.
  static String formatTimestamp(DateTime dt) {
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

  /// Returns a compact relative time string.
  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  /// Returns a clean shortened identifier for display.
  static String shortId(String fullId) {
    final clean = fullId.replaceAll('-', '');
    if (clean.length > 8) {
      return clean.substring(0, 8).toUpperCase();
    }
    return fullId.toUpperCase();
  }
}
