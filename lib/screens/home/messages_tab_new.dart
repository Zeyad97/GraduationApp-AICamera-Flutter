import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contact_provider.dart';
import '../../utils/app_localization.dart';
import '../../models/contact_model.dart';
import '../chat/chat_screen.dart';

class MessagesTab extends StatefulWidget {
  const MessagesTab({super.key});

  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  @override
  void initState() {
    super.initState();
    // Data is already loaded by HomeScreen, no need to load again
  }

  Future<void> _refreshData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final contactProvider = Provider.of<ContactProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await contactProvider.loadContacts(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final contactProvider = Provider.of<ContactProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization?.translate('messages') ?? 'Messages'),
      ),
      body: contactProvider.contacts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.message_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localization?.translate('no_contacts') ?? 'No contacts yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add contacts to start messaging',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => _refreshData(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: contactProvider.contacts.length,
                itemBuilder: (context, index) {
                  final contact = contactProvider.contacts[index];
                  return _ContactChatTile(
                    contact: contact,
                    userId: authProvider.currentUser!.id,
                  );
                },
              ),
            ),
    );
  }
}

class _ContactChatTile extends StatelessWidget {
  final ContactModel contact;
  final String userId;

  const _ContactChatTile({
    required this.contact,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
          child: Text(
            contact.name[0].toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(contact.name),
        subtitle: Text(
          contact.relationshipString,
          style: TextStyle(fontSize: 12),
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                contact: contact,
                userId: userId,
              ),
            ),
          );
        },
      ),
    );
  }
}
