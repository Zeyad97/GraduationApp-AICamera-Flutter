import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/message_model.dart';
import '../../models/contact_model.dart';
import '../../services/database_service.dart';
import '../../utils/app_localization.dart';
import 'package:intl/intl.dart';

class ChatProvider extends ChangeNotifier {
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _currentChatUserId;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get currentChatUserId => _currentChatUserId;

  Future<void> loadMessages(String userId, String otherUserId) async {
    _isLoading = true;
    _currentChatUserId = otherUserId;
    notifyListeners();

    _messages = await DatabaseService.instance.getMessagesBetweenUsers(
      userId,
      otherUserId,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
    String? attachmentUrl,
  }) async {
    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      timestamp: DateTime.now(),
      isRead: false,
      attachmentUrl: attachmentUrl,
    );

    await DatabaseService.instance.insertMessage(newMessage);
    await loadMessages(senderId, receiverId);
  }

  Future<void> markAsRead(String messageId) async {
    final message = _messages.firstWhere((m) => m.id == messageId);
    final updatedMessage = message.copyWith(isRead: true);
    await DatabaseService.instance.updateMessage(updatedMessage);
    
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _messages[index] = updatedMessage;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getLastMessageForContact(
    String userId,
    String contactId,
  ) async {
    final messages = await DatabaseService.instance.getMessagesBetweenUsers(
      userId,
      contactId,
    );

    if (messages.isEmpty) {
      return {
        'message': 'No messages yet',
        'timestamp': null,
        'unreadCount': 0,
      };
    }

    final lastMessage = messages.last;
    final unreadCount = messages.where(
      (m) => m.receiverId == userId && !m.isRead,
    ).length;

    return {
      'message': lastMessage.message,
      'timestamp': lastMessage.timestamp,
      'unreadCount': unreadCount,
    };
  }

  void clearCurrentChat() {
    _currentChatUserId = null;
    _messages = [];
    notifyListeners();
  }
}
