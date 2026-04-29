import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/contact_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_localization.dart';
import '../../models/contact_model.dart';
import '../contact/add_contact_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactsTab extends StatelessWidget {
  const ContactsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final contactProvider = Provider.of<ContactProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization?.translate('contacts') ?? 'Contacts'),
      ),
      body: contactProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : contactProvider.contacts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.contacts_outlined,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localization?.translate('no_contacts') ??
                            'No contacts yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _navigateToAddContact(
                          context,
                          authProvider.currentUser!.id,
                        ),
                        icon: const Icon(Icons.add),
                        label: Text(
                          localization?.translate('add_contact') ??
                              'Add Contact',
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => contactProvider.loadContacts(
                    authProvider.currentUser!.id,
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: contactProvider.contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contactProvider.contacts[index];
                      return _ContactListItem(contact: contact);
                    },
                  ),
                ),
      floatingActionButton: contactProvider.contacts.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _navigateToAddContact(
                context,
                authProvider.currentUser!.id,
              ),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _navigateToAddContact(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddContactScreen(userId: userId),
      ),
    );
  }
}

class _ContactListItem extends StatelessWidget {
  final ContactModel contact;

  const _ContactListItem({required this.contact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contactProvider = Provider.of<ContactProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: contact.isEmergencyContact
              ? Colors.red.withOpacity(0.2)
              : theme.colorScheme.primary.withOpacity(0.2),
          child: Text(
            contact.name[0].toUpperCase(),
            style: TextStyle(
              color: contact.isEmergencyContact
                  ? Colors.red
                  : theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                contact.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (contact.isEmergencyContact)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star, size: 12, color: Colors.red),
                    SizedBox(width: 4),
                    Text(
                      'Emergency',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contact.phoneNumber),
            Text(
              contact.relationshipString,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Call'),
                contentPadding: EdgeInsets.zero,
              ),
              onTap: () => _makePhoneCall(contact.phoneNumber),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: Icon(
                  contact.isEmergencyContact ? Icons.star : Icons.star_border,
                ),
                title: Text(
                  contact.isEmergencyContact
                      ? 'Remove from Emergency'
                      : 'Mark as Emergency',
                ),
                contentPadding: EdgeInsets.zero,
              ),
              onTap: () {
                contactProvider.toggleEmergencyContact(
                  contact.id,
                  contact.userId,
                );
              },
            ),
            PopupMenuItem(
              child: const ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
              onTap: () {
                contactProvider.deleteContact(contact.id, contact.userId);
              },
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}
