import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock/sample_data.dart';
import '../../shared/widgets/emergency_category_tile.dart';
import '../../shared/widgets/section_header.dart';
import 'confirm_sos_screen.dart';

/// 2. Create SOS Screen: Multi-step emergency reporting with category selector,
/// incident details entry, and GPS location preview.
class CreateSosScreen extends StatefulWidget {
  final EmergencyCategory initialCategory;

  const CreateSosScreen({
    super.key,
    this.initialCategory = EmergencyCategory.medical,
  });

  @override
  State<CreateSosScreen> createState() => _CreateSosScreenState();
}

class _CreateSosScreenState extends State<CreateSosScreen> {
  late EmergencyCategory _selectedCategory;
  late final TextEditingController _detailsController;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _detailsController = TextEditingController(
      text: 'Need immediate medical assistance. 2 people injured after building collapse.',
    );
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Create SOS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Offline SOS Information',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.card,
                  title: const Text(
                    'Offline SOS Mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: const Text(
                    'Requests created offline will be securely queued in local storage and relayed to nearby devices via peer-to-peer mesh until network connectivity is restored.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Horizontal 4-step progress indicator
                    _buildStepIndicator(),
                    const SizedBox(height: 20),

                    // Section 1: Emergency Type Selection
                    const SectionHeader(title: '1. Select Emergency Type'),
                    const SizedBox(height: 8),
                    _buildCategoryGrid(),
                    const SizedBox(height: 20),

                    // Section 2: Details Description Input
                    const SectionHeader(title: '2. Add Details'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _detailsController,
                      maxLines: 4,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Describe your emergency situation...\n(e.g. injuries, people trapped, supplies needed)',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section 3: GPS Location
                    const SectionHeader(title: '3. Location'),
                    const SizedBox(height: 8),
                    _buildLocationCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Action: Next Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ConfirmSosScreen(
                        category: _selectedCategory,
                        description: _detailsController.text.trim().isEmpty
                            ? 'No description provided.'
                            : _detailsController.text.trim(),
                        location: MockDataProvider.mockCurrentLocation,
                        coordinates: MockDataProvider.mockCoordinates,
                      ),
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Next'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Type', 'Details', 'Location', 'Confirm'];
    const activeStep = 0; // "Type" is active at this stage

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              color: index ~/ 2 < activeStep
                  ? AppColors.sosRed
                  : AppColors.border,
            ),
          );
        }
        final stepIndex = index ~/ 2;
        final isActive = stepIndex == activeStep;
        final isPast = stepIndex < activeStep;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive || isPast ? AppColors.sosRed : AppColors.card,
                border: Border.all(
                  color: isActive || isPast
                      ? AppColors.sosRed
                      : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '${stepIndex + 1}',
                  style: TextStyle(
                    color: isActive || isPast
                        ? Colors.white
                        : AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              steps[stepIndex],
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textMuted,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = EmergencyCategory.values;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) {
        final cat = categories[index];
        return EmergencyCategoryTile(
          category: cat,
          isSelected: _selectedCategory == cat,
          onTap: () {
            setState(() {
              _selectedCategory = cat;
            });
          },
        );
      },
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0x2430D158),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.my_location_rounded,
              color: AppColors.successGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Location (GPS)',
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
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '• Location Available',
                  style: TextStyle(
                    color: AppColors.successGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Simulated GPS coordinates refreshed.'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(
              Icons.gps_fixed_rounded,
              color: AppColors.cyanAccent,
              size: 20,
            ),
            tooltip: 'Refresh Location',
          ),
        ],
      ),
    );
  }
}
