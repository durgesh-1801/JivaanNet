import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jivaan_net_client/jivaan_net_client.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock/sample_data.dart';
import '../../main.dart' show client;
import '../../models/emergency_contact.dart';
import '../../services/emergency_contact_service.dart';
import '../../services/emergency_sms_preview_service.dart';
import '../../services/sos_service.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_badge.dart';
import '../contacts/emergency_contacts_screen.dart';
import '../requests/request_details_screen.dart';

/// 3. Confirm SOS Screen: Pre-submission review screen showing incident details,
/// offline-mesh explanation, primary Send SOS action, and safe test SMS preview.
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
  final SosService? sosService;
  final EmergencyContactService? contactService;

  const ConfirmSosScreen({
    super.key,
    this.category = EmergencyCategory.medical,
    this.description = 'Need immediate medical assistance. 2 people injured after building collapse.',
    this.sosService,
    this.contactService,
  });

  @override
  State<ConfirmSosScreen> createState() => _ConfirmSosScreenState();
}

class _ConfirmSosScreenState extends State<ConfirmSosScreen> {
  bool _isSubmitting = false;
  bool _isPreviewingSms = false;
  bool _isLoadingContact = true;

  // UUID and timestamp are generated once per incident, preserved across retries.
  String? _incidentId;
  DateTime? _createdAt;

  late final SosService _sosService = widget.sosService ?? SosService(client);
  late final EmergencyContactService _contactService =
      widget.contactService ?? EmergencyContactService();
  EmergencyContact? _primaryContact;

  @override
  void initState() {
    super.initState();
    _loadPrimaryContact();
  }

  Future<void> _loadPrimaryContact() async {
    final contact = await _contactService.getPrimaryContact();
    if (mounted) {
      setState(() {
        _primaryContact = contact;
        _isLoadingContact = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _isSubmitting
              ? null
              : () => Navigator.of(context).maybePop(),
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

                    // Emergency Contacts Test Preview Card
                    const SectionHeader(
                      title: 'Emergency Contacts (Test Mode)',
                    ),
                    const SizedBox(height: 10),
                    _buildTestSmsPreviewCard(context),
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
                    onPressed: _isSubmitting
                        ? null
                        : () => _handleSendSos(context),
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
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).maybePop(),
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

          // Category Row
          _buildDetailRow(
            icon: widget.category.icon,
            iconBg: widget.category.bgTint,
            iconColor: widget.category.accentColor,
            title: 'Type',
            content: widget.category.fullTitle,
          ),
          const Divider(height: 24, color: AppColors.border),

          // Details Row
          _buildDetailRow(
            icon: Icons.description_outlined,
            iconBg: const Color(0x228B9CB5),
            iconColor: const Color(0xFF8B9CB5),
            title: 'Details',
            content: widget.description,
          ),
          const Divider(height: 24, color: AppColors.border),

          // Location Row — real GPS is fetched on send
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: Center(
                  child: Icon(
                    Icons.location_on_rounded,
                    color: AppColors.sosRed,
                    size: 20,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Current Location (GPS acquired on send)',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
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

  Widget _buildTestSmsPreviewCard(BuildContext context) {
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
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.cyanAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sms_outlined,
                  color: AppColors.cyanAccent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Primary Contact SMS Alert',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_primaryContact != null) StatusBadge.primary(),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingContact) ...[
            const Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.cyanAccent,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Checking primary contact...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ] else if (_primaryContact != null) ...[
            Text(
              'Primary Recipient: ${_primaryContact!.name} (${_primaryContact!.phone})',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Opens your device SMS composer with a pre-filled test drill message. '
              'You review and send manually — nothing is sent automatically.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ] else ...[
            const Text(
              'No primary emergency contact configured.',
              style: TextStyle(
                color: AppColors.pendingOrange,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Configure a primary contact in Emergency Contacts to preview test alerts.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isPreviewingSms || _isSubmitting
                  ? null
                  : () => _handlePreviewEmergencySms(context),
              icon: _isPreviewingSms
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.cyanAccent,
                      ),
                    )
                  : const Icon(Icons.sms_rounded, size: 18),
              label: const Text('Preview Emergency SMS (Test Mode)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.cyanAccent,
                side: const BorderSide(color: AppColors.cyanAccent),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePreviewEmergencySms(BuildContext context) async {
    // 1. Ensure primary contact is configured
    final primary =
        _primaryContact ?? await _contactService.getPrimaryContact();
    if (primary == null) {
      if (!context.mounted) return;
      _showNoPrimaryContactDialog(context);
      return;
    }

    setState(() => _isPreviewingSms = true);

    double? lat;
    double? lng;

    // 2. Obtain current GPS coordinates where available
    try {
      final pos = await _sosService.getCurrentLocation();
      lat = pos.latitude;
      lng = pos.longitude;
    } catch (e) {
      debugPrint('ConfirmSosScreen: Location unavailable for SMS preview: $e');
    }

    // 3. Generate test drill message
    final message = EmergencySmsPreviewService.buildTestEmergencyMessage(
      incidentId: _incidentId,
      latitude: lat,
      longitude: lng,
      categoryLabel: widget.category.label,
      description: widget.description,
    );

    // 4. Open native SMS composer (does not send automatically)
    final launched = await EmergencySmsPreviewService.openSmsComposer(
      phoneNumber: primary.phone,
      messageBody: message,
    );

    if (!context.mounted) return;
    setState(() => _isPreviewingSms = false);

    // 5. Fallback dialog if system composer could not be launched
    if (!launched) {
      _showSmsFallbackDialog(context, primary, message);
    }
  }

  void _showNoPrimaryContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
        icon: const Icon(
          Icons.contact_phone_outlined,
          color: AppColors.pendingOrange,
          size: 40,
        ),
        title: const Text(
          'No Primary Contact',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'You have not designated a primary emergency contact yet. '
          'Please configure a primary contact in Emergency Contacts before previewing test alerts.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EmergencyContactsScreen(),
                ),
              );
              _loadPrimaryContact();
            },
            child: const Text('Configure Contacts'),
          ),
        ],
      ),
    );
  }

  void _showSmsFallbackDialog(
    BuildContext context,
    EmergencyContact contact,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Emergency SMS Preview',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Could not open the native SMS composer automatically. Below is the test drill message prepared for ${contact.name} (${contact.phone}):',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: SelectableText(
                message,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy Message'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: message));
              Navigator.of(dialogCtx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Test emergency message copied to clipboard.'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
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

  void _showSuccessDialog(
    BuildContext context,
    SosSubmissionResponse response,
  ) {
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
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
