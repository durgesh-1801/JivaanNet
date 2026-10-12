import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock/sample_data.dart';
import 'status_badge.dart';

/// Card widget representing an SOS incident in list or recent activity views.
class SosRequestCard extends StatelessWidget {
  final SampleSosRequest request;
  final VoidCallback onTap;
  final bool showChevron;
  final bool compact;

  const SosRequestCard({
    super.key,
    required this.request,
    required this.onTap,
    this.showChevron = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: request.category.bgTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  request.category.icon,
                  color: request.category.accentColor,
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
                      request.title,
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
                        request.location,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else ...[
                      Text(
                        request.formattedTime,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        request.location,
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
                  StatusBadge.fromStatus(request.status),
                  if (compact) ...[
                    const SizedBox(height: 4),
                    Text(
                      request.timeAgo,
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
}
