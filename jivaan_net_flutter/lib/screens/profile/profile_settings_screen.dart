import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock/sample_data.dart';
import '../contacts/emergency_contacts_screen.dart';
import '../home/home_screen.dart';
import '../mesh/mesh_network_screen.dart';
import '../nearby/nearby_help_screen.dart';
import '../requests/my_sos_requests_screen.dart';
import '../requests/request_details_screen.dart';
import '../sos/confirm_sos_screen.dart';
import '../sos/create_sos_screen.dart';

/// 9. Profile & Settings Screen: User identity card, emergency preferences,
/// navigation to Emergency Contacts, and developer preview launchers for all 9 screens.
class ProfileSettingsScreen extends StatelessWidget {
  final bool showBackButton;

  const ProfileSettingsScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: const Text('Profile & Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'JivaanNet v1.0.0 (Offline Architecture Ready)',
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Identity Profile Card
              _buildProfileHeaderCard(),
              const SizedBox(height: 16),

              // Settings Items List Card
              _buildSettingsList(context),
              const SizedBox(height: 20),

              // Development Quick Navigation Card (Task 5: every screen reachable)
              _buildDevQuickNavCard(context),
              const SizedBox(height: 16),

              // Backend / Architecture Handover Status Note
              _buildBackendStatusCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard() {
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.blueAccent.withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.blueAccent, width: 1.5),
            ),
            child: const Center(
              child: Text(
                'DS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Durgesh Sharma',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '+91 98765 43210',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.location_on_outlined,
            title: 'Location & Permissions',
            onTap: () => _showNotice(
              context,
              'Location permissions are active for offline GPS caching.',
            ),
          ),
          const Divider(height: 1, indent: 52, color: AppColors.border),
          _buildSettingsTile(
            icon: Icons.tune_rounded,
            title: 'App Settings',
            onTap: () => _showNotice(
              context,
              'P2P Bluetooth and Wi-Fi Direct background scanning: Enabled.',
            ),
          ),
          const Divider(height: 1, indent: 52, color: AppColors.border),
          _buildSettingsTile(
            icon: Icons.people_outline_rounded,
            title: 'Emergency Contacts',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EmergencyContactsScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 52, color: AppColors.border),
          _buildSettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'About JivaanNet',
            onTap: () => _showNotice(
              context,
              'JivaanNet: Resilient emergency response network when towers fail.',
            ),
          ),
          const Divider(height: 1, indent: 52, color: AppColors.border),
          _buildSettingsTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            onTap: () => _showNotice(
              context,
              'Disaster preparedness guides and emergency dispatch protocols.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
        size: 20,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }

  Widget _buildDevQuickNavCard(BuildContext context) {
    final screens = [
      ('1. Home Screen', const HomeScreen()),
      ('2. Create SOS', const CreateSosScreen()),
      ('3. Confirm SOS', const ConfirmSosScreen()),
      ('4. My SOS Requests', const MySosRequestsScreen()),
      (
        '5. Request Details',
        RequestDetailsScreen(request: MockDataProvider.requests.first),
      ),
      ('6. Mesh Network', const MeshNetworkScreen()),
      ('7. Nearby Help', const NearbyHelpScreen()),
      ('8. Emergency Contacts', const EmergencyContactsScreen()),
      ('9. Profile & Settings', const ProfileSettingsScreen()),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.developer_mode_rounded,
                color: AppColors.cyanAccent,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Development Quick Navigation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Direct access to all 9 screens for testing and UI review:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: screens.map((item) {
              return ActionChip(
                backgroundColor: AppColors.card,
                side: const BorderSide(color: AppColors.border),
                label: Text(
                  item.$1,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => item.$2));
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackendStatusCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_moon_outlined,
            color: AppColors.pendingOrange,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Backend Handover Ready',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Serverpod 4.0.4 backend exists in sibling folder ../jivaan_net. Frontend networking is intentionally unlinked in this foundation step.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
