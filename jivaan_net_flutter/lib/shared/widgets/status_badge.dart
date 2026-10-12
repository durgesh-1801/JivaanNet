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

  /// Preset for connectivity status "Offline".
  factory StatusBadge.offline() {
    return const StatusBadge(
      label: 'Offline',
      foregroundColor: AppColors.errorRed,
      backgroundColor: AppColors.failedBadgeBg,
      fontSize: 11,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
