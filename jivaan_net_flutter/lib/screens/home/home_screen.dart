import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock/sample_data.dart';
import '../../shared/widgets/emergency_category_tile.dart';
import '../../shared/widgets/primary_sos_button.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/sos_request_card.dart';
import '../../shared/widgets/status_badge.dart';
import '../requests/my_sos_requests_screen.dart';
import '../requests/request_details_screen.dart';
import '../sos/create_sos_screen.dart';

/// 1. Home Screen: Main emergency dashboard with hero SOS button,
/// connectivity indicator, category quick actions, and recent activity.
class HomeScreen extends StatelessWidget {
  final ValueChanged<int>? onSwitchTab;

  const HomeScreen({super.key, this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final recentRequest = MockDataProvider.requests.first;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Header: Logo, Title, Subtitle, Notifications
              _buildTopBar(context),
              const SizedBox(height: 16),

              // Location & Connectivity Bar
              _buildLocationBanner(context),
              const SizedBox(height: 24),

              // Hero SOS Button
              Center(
                child: PrimarySosButton(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CreateSosScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Emergency Categories
              SectionHeader(
                title: 'Emergency Categories',
                actionText: 'See all',
                onAction: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CreateSosScreen()),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildCategoriesRow(context),
              const SizedBox(height: 18),

              // Pending SOS Requests Banner
              _buildPendingBanner(context),
              const SizedBox(height: 20),

              // Recent Activity Section
              const SectionHeader(title: 'Recent Activity'),
              const SizedBox(height: 8),
              SosRequestCard(
                request: recentRequest,
                compact: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          RequestDetailsScreen(request: recentRequest),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // App Shield Logo
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.sosRed,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.sosRed.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.shield_rounded, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(width: 12),

        // Title and Subtitle
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'JivaanNet',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                'When towers fall, humanity connects',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Notification Bell
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No new alerts. Mesh monitoring is passive.'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          icon: const Badge(
            smallSize: 8,
            backgroundColor: AppColors.pendingOrange,
            child: Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0x22E53935),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.sosRed,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MockDataProvider.mockCurrentLocation,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  MockDataProvider.mockCoordinates,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge.offline(),
        ],
      ),
    );
  }

  Widget _buildCategoriesRow(BuildContext context) {
    return Row(
      children: EmergencyCategory.values.map((category) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: EmergencyCategoryTile(
              category: category,
              compact: true,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateSosScreen(initialCategory: category),
                  ),
                );
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPendingBanner(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (onSwitchTab != null) {
            onSwitchTab!(1); // Switch to Requests Tab
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MySosRequestsScreen()),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0x2BFF9F0A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.pendingOrange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending SOS Requests',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Waiting for connectivity',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: AppColors.pendingOrange,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
