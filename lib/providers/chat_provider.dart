import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/database_service.dart';
import '../services/firestore_service.dart';
import 'dart:async';

class ChatProvider extends ChangeNotifier {
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _currentChatUserId;
  StreamSubscription? _messagesStreamSubscription;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get currentChatUserId => _currentChatUserId;

  // Setup real-time message listener
  void _setupMessagesListener(String userId, String otherUserId) {
    // Cancel previous subscription
    _messagesStreamSubscription?.cancel();

    try {
      _messagesStreamSubscription = 
        FirestoreService.instance.getMessagesStream(userId, otherUserId).listen(
          (messages) {
            _messages = messages;
            notifyListeners();
          },
          onError: (error) {
            print('Error listening to messages: $error');
            // Fallback to local database
            loadMessages(userId, otherUserId);
          },
        );
    } catch (e) {
      print('Error setting up messages listener: $e');
    }
  }

  Future<void> loadMessages(String userId, String otherUserId) async {
    _isLoading = true;
    _currentChatUserId = otherUserId;
    notifyListeners();

    try {
      // Load from Firestore
      _messages = await FirestoreService.instance.getMessagesBetweenUsers(
        userId,
        otherUserId,
      );
      
      // Cache in local database
      for (var message in _messages) {
        await DatabaseService.instance.insertMessage(message);
      }

      // Setup real-time listener
      _setupMessagesListener(userId, otherUserId);
    } catch (e) {
      print('Error loading messages from Firestore: $e');
      // Fallback to local database
      _messages = await DatabaseService.instance.getMessagesBetweenUsers(
        userId,
        otherUserId,
      );
    }

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

    try {
      // Save to Firestore
      await FirestoreService.instance.saveMessage(newMessage);
    } catch (e) {
      print('Error saving message to Firestore: $e');
    }

    // Always save to local database
    await DatabaseService.instance.insertMessage(newMessage);
  }

  Future<void> markAsRead(String userId, String messageId) async {
    final message = _messages.firstWhere((m) => m.id == messageId);
    final updatedMessage = message.copyWith(isRead: true);
    
    try {
      // Update in Firestore
      await FirestoreService.instance.markMessageAsRead(userId, messageId);
    } catch (e) {
      print('Error marking message as read in Firestore: $e');
    }

    // Update in local database
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
    try {
      final messages = await FirestoreService.instance.getMessagesBetweenUsers(
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
    } catch (e) {
      print('Error getting last message: $e');
      // Fallback to local database
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
  }

  void clearCurrentChat() {
    _currentChatUserId = null;
    _messages = [];
    _messagesStreamSubscription?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _messagesStreamSubscription?.cancel();
    super.dispose();
  }
}
