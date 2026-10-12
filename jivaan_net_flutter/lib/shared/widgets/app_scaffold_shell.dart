import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/mesh/mesh_network_screen.dart';
import '../../screens/nearby/nearby_help_screen.dart';
import '../../screens/profile/profile_settings_screen.dart';
import '../../screens/requests/my_sos_requests_screen.dart';

/// 5-Tab Persistent Navigation Shell for JivaanNet:
/// Home, Requests, Mesh, Map, and Profile.
class AppScaffoldShell extends StatefulWidget {
  final int initialIndex;

  const AppScaffoldShell({super.key, this.initialIndex = 0});

  @override
  State<AppScaffoldShell> createState() => _AppScaffoldShellState();
}

class _AppScaffoldShellState extends State<AppScaffoldShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeScreen(onSwitchTab: _onTabTapped),
      const MySosRequestsScreen(showBackButton: false),
      const MeshNetworkScreen(showBackButton: false),
      const NearbyHelpScreen(showBackButton: false),
      const ProfileSettingsScreen(showBackButton: false),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.sosRed,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded, color: AppColors.sosRed),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(
                Icons.assignment_rounded,
                color: AppColors.sosRed,
              ),
              label: 'Requests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.hub_outlined),
              activeIcon: Icon(Icons.hub_rounded, color: AppColors.sosRed),
              label: 'Mesh',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map_rounded, color: AppColors.sosRed),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded, color: AppColors.sosRed),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
