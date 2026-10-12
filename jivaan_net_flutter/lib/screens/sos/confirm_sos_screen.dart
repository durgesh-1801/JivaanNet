import 'package:flutter/material.dart';
import 'package:jivaan_net_client/jivaan_net_client.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock/sample_data.dart';
import '../../main.dart' show client;
import '../../services/sos_service.dart';
import '../../shared/widgets/section_header.dart';
import '../requests/request_details_screen.dart';

/// 3. Confirm SOS Screen: Pre-submission review screen showing incident details,
/// offline-mesh explanation, and primary Send SOS action.
///
/// On "Send SOS":
///   1. Acquires real GPS coordinates via Geolocator.
///   2. Generates a UUID and timestamp once per new submission.
///   3. Submits the payload to the Serverpod backend via [SosService].
///   4. Shows the actual server response message on success.
///   5. Shows a descriptive error dialog on failure — never falsely reports success.
class ConfirmSosScreen extends StatefulWidget {
  final EmergencyCategory category;
  final String description;

  const ConfirmSosScreen({
    super.key,
    this.category = EmergencyCategory.medical,
    this.description =
        'Need immediate medical assistance. 2 people injured after building collapse.',
  });

  @override
  State<ConfirmSosScreen> createState() => _ConfirmSosScreenState();
}

class _ConfirmSosScreenState extends State<ConfirmSosScreen> {
  bool _isSubmitting = false;

  // UUID and timestamp are generated once per incident, preserved across retries.
  String? _incidentId;
  DateTime? _createdAt;

  late final SosService _sosService = SosService(client);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _isSubmitting ? null : () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Confirm & Send SOS'),
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
                    // Emergency Details Card with Edit action
                    _buildDetailsCard(context),
                    const SizedBox(height: 24),

                    // "What happens next?" Explanation
                    const SectionHeader(title: 'What happens next?'),
                    const SizedBox(height: 10),
                    _buildWhatHappensNextCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Buttons: Send SOS & Cancel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _handleSendSos(context),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send_rounded, size: 20),
                              SizedBox(width: 8),
                              Text('Send SOS'),
                            ],
                          ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).maybePop(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Emergency Details',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              InkWell(
                onTap: _isSubmitting ? null : () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      color: AppColors.sosRed,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Type
          _buildDetailRow(
            icon: widget.category.icon,
            iconColor: widget.category.accentColor,
            iconBg: widget.category.bgTint,
            title: 'Type',
            content: widget.category.fullTitle,
          ),
          const Divider(height: 24, color: AppColors.border),

          // Description
          _buildDetailRow(
            icon: Icons.notes_rounded,
            iconColor: AppColors.pendingOrange,
            iconBg: const Color(0x2BFF9F0A),
            title: 'Description',
            content: widget.description,
          ),
          const Divider(height: 24, color: AppColors.border),

          // Location
          _buildDetailRow(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.sosRed,
            iconBg: const Color(0x22E53935),
            title: 'Location',
            content: 'GPS coordinates will be captured on submission.',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                content,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWhatHappensNextCard() {
    final steps = [
      (
        number: '1',
        title: 'Sent to JivaanNet server',
        subtitle: 'Delivered directly when connected to Internet',
      ),
      (
        number: '2',
        title: 'Will be shared via nearby devices',
        subtitle: 'When other JivaanNet users are nearby',
      ),
      (
        number: '3',
        title: 'Forwarded to relief coordinators',
        subtitle: 'Authorities and NGOs are notified automatically',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: steps.map((item) {
          final isLast = item == steps.last;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.sosRed,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      item.number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _handleSendSos(BuildContext context) async {
    // Generate incident ID and timestamp once per new submission.
    // These are preserved if the user retries without navigating away.
    _incidentId ??= _sosService.createIncidentId();
    _createdAt ??= DateTime.now().toUtc();

    setState(() => _isSubmitting = true);

    try {
      // 1. Acquire real GPS — throws a descriptive Exception on failure.
      final position = await _sosService.getCurrentLocation();

      // 2. Submit to Serverpod backend.
      final response = await _sosService.submitSos(
        incidentId: _incidentId!,
        latitude: position.latitude,
        longitude: position.longitude,
        createdAt: _createdAt!,
        description: widget.description,
        relayCount: 0,
      );

      if (!context.mounted) return;
      setState(() => _isSubmitting = false);

      // 3. Show actual server message on success.
      _showSuccessDialog(context, response);
    } on Exception catch (e) {
      if (!context.mounted) return;
      setState(() => _isSubmitting = false);

      // Surface the error without falsely reporting success.
      _showErrorDialog(context, e.toString());
    }
  }

  void _showSuccessDialog(BuildContext context, SosSubmissionResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
        icon: Icon(
          response.isNew
              ? Icons.check_circle_rounded
              : Icons.info_outline_rounded,
          color: AppColors.successGreen,
          size: 48,
        ),
        title: Text(
          response.isNew ? 'SOS Submitted' : 'Already Received',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          response.message,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close dialog
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => RequestDetailsScreen.fromIncident(
                    incident: response.incident,
                    category: widget.category,
                  ),
                ),
              );
            },
            child: const Text('View Request Details'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    // Strip the leading "Exception: " prefix for cleaner display.
    final displayMessage = message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
        icon: const Icon(
          Icons.error_outline_rounded,
          color: AppColors.errorRed,
          size: 48,
        ),
        title: const Text(
          'Submission Failed',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          displayMessage,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
