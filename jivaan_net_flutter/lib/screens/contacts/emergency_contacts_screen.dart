import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/emergency_contact.dart';
import '../../services/emergency_contact_service.dart';
import '../../shared/widgets/status_badge.dart';

/// 8. Emergency Contacts Screen: Trusted contact directory backed by
/// persistent SQLite storage with primary contact selection and add/remove capabilities.
class EmergencyContactsScreen extends StatefulWidget {
  final bool showBackButton;
  final EmergencyContactService? contactService;

  const EmergencyContactsScreen({
    super.key,
    this.showBackButton = true,
    this.contactService,
  });

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  late final EmergencyContactService _contactService;
  List<EmergencyContact> _contacts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _contactService = widget.contactService ?? EmergencyContactService();
    _loadContacts();
  }

  /// Loads contacts from persistent SQLite storage.
  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final contacts = await _contactService.getContacts();
      if (mounted) {
        setState(() {
          _contacts = contacts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load emergency contacts: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleDeleteContact(EmergencyContact contact) async {
    await _contactService.deleteContact(contact.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${contact.name} removed from emergency contacts.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    await _loadContacts();
  }

  Future<void> _handleSetPrimary(EmergencyContact contact) async {
    await _contactService.setPrimaryContact(contact.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${contact.name} set as primary emergency contact.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    await _loadContacts();
  }

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
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.sosRed,
            ),
            SizedBox(height: 16),
            Text(
              'Loading emergency contacts...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.errorRed,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadContacts,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_contacts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.contact_phone_outlined,
                  color: AppColors.textMuted,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Emergency Contacts',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add trusted contacts who can be reached during an emergency situation.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _showAddContactDialog(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Contact'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sosRed,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

                // Action Buttons: Call, SMS, Options Menu
                IconButton(
                  icon: const Icon(Icons.phone_outlined, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Call',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Direct phone dialing to ${contact.name} (${contact.phone}) requires cellular connectivity.',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'SMS Alert',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Emergency SMS to ${contact.name} requires active cellular network.',
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
                    if (val == 'primary') {
                      _handleSetPrimary(contact);
                    } else if (val == 'delete') {
                      _handleDeleteContact(contact);
                    }
                  },
                  itemBuilder: (context) => [
                    if (!contact.isPrimary)
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
              autofocus: true,
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
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final phone = phoneController.text.trim().isEmpty
                    ? '+91 99999 00000'
                    : phoneController.text.trim();

                final newContact = EmergencyContact(
                  id: 'c_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  phone: phone,
                  isPrimary: _contacts.isEmpty,
                );

                await _contactService.addContact(newContact);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                await _loadContacts();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
