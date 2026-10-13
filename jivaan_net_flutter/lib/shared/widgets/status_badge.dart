import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock/sample_data.dart';

/// Reusable badge for displaying status indicators across screens.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color foregroundColor;
  final Color backgroundColor;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const StatusBadge({
    super.key,
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
    this.icon,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.borderRadius = 20,
  });

  /// Factory from standard [SosRequestStatus].
  factory StatusBadge.fromStatus(SosRequestStatus status) {
    return StatusBadge(
      label: status.label,
      foregroundColor: status.foreground,
      backgroundColor: status.background,
    );
  }

  /// Factory for Serverpod [SosIncident] lifecycle status.
  factory StatusBadge.fromIncidentStatus(String rawStatus) {
    final status = rawStatus.toLowerCase().trim();
    switch (status) {
      case 'pending':
        return const StatusBadge(
          label: 'Pending',
          foregroundColor: AppColors.pendingOrange,
          backgroundColor: AppColors.pendingBadgeBg,
          icon: Icons.hourglass_top_rounded,
        );
      case 'acknowledged':
        return const StatusBadge(
          label: 'Acknowledged',
          foregroundColor: AppColors.blueAccent,
          backgroundColor: Color(0x33388AF6),
          icon: Icons.check_circle_outline_rounded,
        );
      case 'dispatched':
        return const StatusBadge(
          label: 'Dispatched',
          foregroundColor: AppColors.cyanAccent,
          backgroundColor: Color(0x3300D2FF),
          icon: Icons.local_shipping_rounded,
        );
      case 'resolved':
        return const StatusBadge(
          label: 'Resolved',
          foregroundColor: AppColors.successGreen,
          backgroundColor: AppColors.successBadgeBg,
          icon: Icons.task_alt_rounded,
        );
      case 'failed':
        return const StatusBadge(
          label: 'Failed',
          foregroundColor: AppColors.errorRed,
          backgroundColor: AppColors.failedBadgeBg,
          icon: Icons.error_outline_rounded,
        );
      default:
        final formatted = status.isNotEmpty
            ? '${status[0].toUpperCase()}${status.substring(1)}'
            : 'Unknown';
        return StatusBadge(
          label: formatted,
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.surfaceElevated,
        );
    }
  }

  /// Factory for incident triage severity level.
  factory StatusBadge.fromSeverity(String rawSeverity) {
    final severity = rawSeverity.toLowerCase().trim();
    Color fg;
    Color bg;
    switch (severity) {
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
    return StatusBadge(
      label: formatted,
      foregroundColor: fg,
      backgroundColor: bg,
      fontSize: 10,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    );
  }

  /// Preset for connectivity status "Offline".
  factory StatusBadge.offline({String label = 'Offline'}) {
    return StatusBadge(
      label: label,
      foregroundColor: AppColors.errorRed,
      backgroundColor: AppColors.failedBadgeBg,
      icon: Icons.wifi_off_rounded,
      fontSize: 11,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }

  /// Preset for connectivity status "Online".
  factory StatusBadge.online({String label = 'Online'}) {
    return StatusBadge(
      label: label,
      foregroundColor: AppColors.successGreen,
      backgroundColor: AppColors.successBadgeBg,
      icon: Icons.wifi_rounded,
      fontSize: 11,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }

  /// Preset for network available but server unreachable.
  factory StatusBadge.serverUnreachable({String label = 'Server Offline'}) {
    return StatusBadge(
      label: label,
      foregroundColor: AppColors.pendingOrange,
      backgroundColor: AppColors.pendingBadgeBg,
      icon: Icons.cloud_off_rounded,
      fontSize: 11,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }

  /// Preset for "Primary" emergency contact.
  factory StatusBadge.primary() {
    return const StatusBadge(
      label: 'Primary',
      foregroundColor: AppColors.blueAccent,
      backgroundColor: Color(0x33388AF6),
      fontSize: 11,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }

  /// Preset for "Open" relief shelter/facility.
  factory StatusBadge.open() {
    return const StatusBadge(
      label: 'Open',
      foregroundColor: AppColors.successGreen,
      backgroundColor: AppColors.successBadgeBg,
      fontSize: 12,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: foregroundColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: foregroundColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
