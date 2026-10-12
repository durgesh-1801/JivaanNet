import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock/sample_data.dart';
import '../../shared/widgets/status_badge.dart';

/// 8. Emergency Contacts Screen: Trusted contact directory with fast SMS/call simulation
/// and primary SOS recipient designation.
class EmergencyContactsScreen extends StatefulWidget {
  final bool showBackButton;

  const EmergencyContactsScreen({super.key, this.showBackButton = true});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final List<SampleEmergencyContact> _contacts = List.from(
    MockDataProvider.contacts,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: const Text('Emergency Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Contact',
            onPressed: () => _showAddContactDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          // User Avatar Circle
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceElevated,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person_rounded,
                                color: AppColors.textSecondary,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Contact Information
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        contact.name,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (contact.isPrimary) ...[
                                      const SizedBox(width: 8),
                                      StatusBadge.primary(),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  contact.phone,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Action Buttons: Call, SMS, More
                          IconButton(
                            icon: const Icon(Icons.phone_outlined, size: 20),
                            color: AppColors.textSecondary,
                            tooltip: 'Call',
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Simulation: Dialing ${contact.name} (${contact.phone})...',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 20,
                            ),
                            color: AppColors.textSecondary,
                            tooltip: 'SMS Alert',
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Simulation: Preparing emergency SMS to ${contact.name}...',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert_rounded,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            color: AppColors.surfaceElevated,
                            onSelected: (val) {
                              if (val == 'delete') {
                                setState(() {
                                  _contacts.removeAt(index);
                                });
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'primary',
                                child: Text('Set as Primary'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Remove Contact',
                                  style: TextStyle(color: AppColors.errorRed),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddContactDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text(
          'Add Emergency Contact',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Contact Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40)),
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  _contacts.add(
                    SampleEmergencyContact(
                      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim().isEmpty
                          ? '+91 99999 00000'
                          : phoneController.text.trim(),
                    ),
                  );
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
