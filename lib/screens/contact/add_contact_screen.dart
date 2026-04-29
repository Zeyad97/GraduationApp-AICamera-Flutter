import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/contact_model.dart';
import '../../providers/contact_provider.dart';
import '../../utils/app_localization.dart';

class AddContactScreen extends StatefulWidget {
  final String userId;
  final ContactModel? contact;

  const AddContactScreen({
    super.key,
    required this.userId,
    this.contact,
  });

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  ContactRelationship _relationship = ContactRelationship.family;
  bool _isEmergencyContact = false;

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _nameController.text = widget.contact!.name;
      _phoneController.text = widget.contact!.phoneNumber;
      _emailController.text = widget.contact!.email ?? '';
      _relationship = widget.contact!.relationship;
      _isEmergencyContact = widget.contact!.isEmergencyContact;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    final contactProvider = Provider.of<ContactProvider>(context, listen: false);
    
    if (widget.contact == null) {
      final contact = ContactModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: widget.userId,
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        relationship: _relationship,
        isEmergencyContact: _isEmergencyContact,
        createdAt: DateTime.now(),
      );
      await contactProvider.addContact(contact);
    } else {
      final updatedContact = widget.contact!.copyWith(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        relationship: _relationship,
        isEmergencyContact: _isEmergencyContact,
      );
      await contactProvider.updateContact(updatedContact);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isEdit = widget.contact != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? (localization?.translate('edit_contact') ?? 'Edit Contact')
              : (localization?.translate('add_contact') ?? 'Add Contact'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Avatar
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.colorScheme.primary,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText:
                      localization?.translate('contact_name') ?? 'Contact Name',
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localization?.translate('field_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText:
                      localization?.translate('phone_number') ?? 'Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localization?.translate('field_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: localization?.translate('email') ?? 'Email',
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),

              // Relationship Dropdown
              DropdownButtonFormField<ContactRelationship>(
                value: _relationship,
                decoration: InputDecoration(
                  labelText:
                      localization?.translate('relationship') ?? 'Relationship',
                  prefixIcon: const Icon(Icons.people),
                ),
                items: ContactRelationship.values.map((relationship) {
                  return DropdownMenuItem(
                    value: relationship,
                    child: Text(_getRelationshipString(relationship)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _relationship = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),

              // Emergency Contact Switch
              Card(
                child: SwitchListTile(
                  title: Text(
                    localization?.translate('is_emergency_contact') ??
                        'Emergency Contact',
                  ),
                  subtitle: const Text(
                    'This contact will be notified during emergencies',
                  ),
                  value: _isEmergencyContact,
                  onChanged: (value) {
                    setState(() {
                      _isEmergencyContact = value;
                    });
                  },
                  secondary: Icon(
                    _isEmergencyContact ? Icons.star : Icons.star_border,
                    color: _isEmergencyContact ? Colors.red : null,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveContact,
                  child: Text(
                    localization?.translate('save') ?? 'Save',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRelationshipString(ContactRelationship relationship) {
    final localization = AppLocalizations.of(context);
    switch (relationship) {
      case ContactRelationship.family:
        return localization?.translate('family') ?? 'Family';
      case ContactRelationship.friend:
        return localization?.translate('friend') ?? 'Friend';
      case ContactRelationship.caregiver:
        return localization?.translate('caregiver') ?? 'Caregiver';
      case ContactRelationship.doctor:
        return localization?.translate('doctor') ?? 'Doctor';
      case ContactRelationship.nurse:
        return localization?.translate('nurse') ?? 'Nurse';
      case ContactRelationship.other:
        return localization?.translate('other') ?? 'Other';
    }
  }
}
