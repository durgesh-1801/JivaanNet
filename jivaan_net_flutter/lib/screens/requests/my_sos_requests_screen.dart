import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock/sample_data.dart';
import '../../shared/widgets/sos_request_card.dart';
import 'request_details_screen.dart';

/// 4. My SOS Requests Screen: Tabular and list view of all requests with
/// interactive status filters (All, Pending, Synced, Failed).
class MySosRequestsScreen extends StatefulWidget {
  final bool showBackButton;

  const MySosRequestsScreen({super.key, this.showBackButton = true});

  @override
  State<MySosRequestsScreen> createState() => _MySosRequestsScreenState();
}

class _MySosRequestsScreenState extends State<MySosRequestsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final allRequests = MockDataProvider.requests;
    final pendingCount = allRequests
        .where((r) => r.status == SosRequestStatus.pending)
        .length;
    final syncedCount = allRequests
        .where((r) => r.status == SosRequestStatus.synced)
        .length;
    final failedCount = allRequests
        .where((r) => r.status == SosRequestStatus.failed)
        .length;

    final filteredRequests = allRequests.where((r) {
      if (_selectedFilter == 'Pending') {
        return r.status == SosRequestStatus.pending;
      }
      if (_selectedFilter == 'Synced') {
        return r.status == SosRequestStatus.synced;
      }
      if (_selectedFilter == 'Failed') {
        return r.status == SosRequestStatus.failed;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: const Text('My SOS Requests'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildFilterChip('All', 'All (${allRequests.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Pending',
                    'Pending ($pendingCount)',
                    color: AppColors.pendingOrange,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Synced',
                    'Synced ($syncedCount)',
                    color: AppColors.successGreen,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Failed',
                    'Failed ($failedCount)',
                    color: AppColors.errorRed,
                  ),
                ],
              ),
            ),

            // Requests List
            Expanded(
              child: filteredRequests.isEmpty
                  ? const Center(
                      child: Text(
                        'No requests found for this status',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      itemCount: filteredRequests.length,
                      itemBuilder: (context, index) {
                        final req = filteredRequests[index];
                        return SosRequestCard(
                          request: req,
                          showChevron: true,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    RequestDetailsScreen(request: req),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label, {Color? color}) {
    final isSelected = _selectedFilter == filterKey;
    final activeColor = color ?? AppColors.sosRed;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color != null
                    ? activeColor.withValues(alpha: 0.25)
                    : AppColors.sosRed)
              : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
