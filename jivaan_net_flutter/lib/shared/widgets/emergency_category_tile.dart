import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock/sample_data.dart';

/// Interactive tile representing an emergency category (Medical, Rescue, Food & Water, Other).
class EmergencyCategoryTile extends StatelessWidget {
  final EmergencyCategory category;
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;

  const EmergencyCategoryTile({
    super.key,
    required this.category,
    this.isSelected = false,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? AppColors.sosRed : AppColors.border;
    final backgroundColor = isSelected
        ? AppColors.sosRed.withValues(alpha: 0.12)
        : AppColors.card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 16,
            vertical: compact ? 12 : 16,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.sosRed.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: compact ? 38 : 46,
                height: compact ? 38 : 46,
                decoration: BoxDecoration(
                  color: isSelected
                      ? category.accentColor.withValues(alpha: 0.22)
                      : category.bgTint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  color: category.accentColor,
                  size: compact ? 20 : 24,
                ),
              ),
              SizedBox(height: compact ? 8 : 10),
              Text(
                category.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontSize: compact ? 12 : 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
