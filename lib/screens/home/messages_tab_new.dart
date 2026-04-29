import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contact_provider.dart';
import '../../providers/chat_provider.dart';
import '../../utils/app_localization.dart';
import '../../models/contact_model.dart';
import '../chat/chat_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessagesTab extends StatefulWidget {
  const MessagesTab({super.key});

  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
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
              onRefresh: () => _loadData(),
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
    final chatProvider = Provider.of<ChatProvider>(context);
    final theme = Theme.of(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: chatProvider.getLastMessageForContact(userId, contact.id),
      builder: (context, snapshot) {
        final lastMessageData = snapshot.data ?? {
          'message': 'No messages yet',
          'timestamp': null,
          'unreadCount': 0,
        };

        final unreadCount = lastMessageData['unreadCount'] as int;
        final lastMessage = lastMessageData['message'] as String;
        final timestamp = lastMessageData['timestamp'] as DateTime?;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  child: Text(
                    contact.name[0].toUpperCase(),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              contact.name,
              style: TextStyle(
                fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (timestamp != null)
                  Text(
                    timeago.format(timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: unreadCount > 0
                          ? theme.colorScheme.primary
                          : Colors.grey[600],
                    ),
                  ),
                if (contact.isEmergencyContact)
                  const Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.red,
                  ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
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
      },
    );
  }
}
