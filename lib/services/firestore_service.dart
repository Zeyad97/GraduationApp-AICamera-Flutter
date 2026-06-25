import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/alert_model.dart';
import '../models/contact_model.dart';
import '../models/message_model.dart';

class FirestoreService {
  static final FirestoreService instance = FirestoreService._init();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreService._init();

  // ========== USER OPERATIONS ==========
  Future<void> saveUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set({
        'id': user.id,
        'fullName': user.fullName,
        'email': user.email,
        'phoneNumber': user.phoneNumber,
        'profileImage': user.profileImage,
        'createdAt': user.createdAt.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving user to Firestore: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel(
          id: doc['id'],
          fullName: doc['fullName'],
          email: doc['email'],
          password: '', // Not stored in Firestore
          phoneNumber: doc['phoneNumber'],
          profileImage: doc['profileImage'],
          createdAt: DateTime.parse(doc['createdAt']),
        );
      }
    } catch (e) {
      print('Error getting user from Firestore: $e');
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update({
        'fullName': user.fullName,
        'phoneNumber': user.phoneNumber,
        'profileImage': user.profileImage,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating user in Firestore: $e');
      rethrow;
    }
  }

  // ========== ALERT DIAGNOSTIC ==========
  /// Scans Firestore for alert documents in several common locations and
  /// logs what it finds. This helps discover where an external system
  /// (e.g. camera/AI) is writing alerts.
  Future<void> diagnoseAlertLocations(String userId) async {
    final locations = <String, Future<int> Function()>{
      'users/{userId}/alerts': () async {
        final s = await _firestore
            .collection('users')
            .doc(userId)
            .collection('alerts')
            .limit(50)
            .get();
        return s.docs.length;
      },
      'alerts (root, filtered by userId)': () async {
        final s = await _firestore
            .collection('alerts')
            .where('userId', isEqualTo: userId)
            .limit(50)
            .get();
        return s.docs.length;
      },
      'alerts (root, all)': () async {
        final s = await _firestore.collection('alerts').limit(50).get();
        return s.docs.length;
      },
      'emergencies (root, all)': () async {
        final s =
            await _firestore.collection('emergencies').limit(50).get();
        return s.docs.length;
      },
      'emergency_alerts (root, all)': () async {
        final s =
            await _firestore.collection('emergency_alerts').limit(50).get();
        return s.docs.length;
      },
    };

    debugPrint('=========== ALERT LOCATION DIAGNOSTIC ===========');
    debugPrint('Looking for alerts for userId: $userId');
    for (final entry in locations.entries) {
      try {
        final count = await entry.value();
        debugPrint('  ${entry.key}: $count document(s)');
        if (count > 0) {
          // Dump a sample document to inspect field names
          QuerySnapshot? sample;
          if (entry.key.startsWith('users/')) {
            sample = await _firestore
                .collection('users')
                .doc(userId)
                .collection('alerts')
                .limit(1)
                .get();
          } else if (entry.key.contains('filtered')) {
            sample = await _firestore
                .collection('alerts')
                .where('userId', isEqualTo: userId)
                .limit(1)
                .get();
          } else {
            final collName = entry.key.split(' ')[0];
            sample = await _firestore.collection(collName).limit(1).get();
          }
          if (sample != null && sample.docs.isNotEmpty) {
            final data = sample.docs.first.data() as Map<String, dynamic>;
            debugPrint('    Sample fields: ${data.keys.toList()}');
            debugPrint('    Sample doc id: ${sample.docs.first.id}');
            debugPrint('    Sample data: $data');
          }
        }
      } catch (e) {
        debugPrint('  ${entry.key}: ERROR - $e');
      }
    }
    debugPrint('==================================================');
  }

  // ========== ALERT OPERATIONS ==========
  Future<void> saveAlert(AlertModel alert) async {
    try {
      await _firestore
          .collection('users')
          .doc(alert.userId)
          .collection('alerts')
          .doc(alert.id)
          .set({
        'id': alert.id,
        'userId': alert.userId,
        'alertType': alert.alertType.index,
        'title': alert.title,
        'message': alert.message,
        'location': alert.location,
        'timestamp': alert.timestamp.toIso8601String(),
        'status': alert.status.index,
        'acknowledgedAt': alert.acknowledgedAt?.toIso8601String(),
        'resolvedAt': alert.resolvedAt?.toIso8601String(),
        'confidence': alert.confidence,
      });
    } catch (e) {
      print('Error saving alert to Firestore: $e');
      rethrow;
    }
  }

  Future<List<AlertModel>> getAlertsByUserId(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('alerts')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AlertModel(
                id: doc['id'],
                userId: doc['userId'],
                alertType: AlertType.values[doc['alertType']],
                title: doc['title'],
                message: doc['message'],
                location: doc['location'],
                timestamp: DateTime.parse(doc['timestamp']),
                status: AlertStatus.values[doc['status']],
                acknowledgedAt: doc['acknowledgedAt'] != null
                    ? DateTime.parse(doc['acknowledgedAt'])
                    : null,
                resolvedAt: doc['resolvedAt'] != null
                    ? DateTime.parse(doc['resolvedAt'])
                    : null,
                confidence: doc['confidence'],
              ))
          .toList();
    } catch (e) {
      print('Error getting alerts from Firestore: $e');
      return [];
    }
  }

  Future<void> updateAlert(AlertModel alert) async {
    try {
      await _firestore
          .collection('users')
          .doc(alert.userId)
          .collection('alerts')
          .doc(alert.id)
          .update({
        'status': alert.status.index,
        'acknowledgedAt': alert.acknowledgedAt?.toIso8601String(),
        'resolvedAt': alert.resolvedAt?.toIso8601String(),
      });
    } catch (e) {
      print('Error updating alert in Firestore: $e');
      rethrow;
    }
  }

  Future<void> deleteAlert(String userId, String alertId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('alerts')
          .doc(alertId)
          .delete();
    } catch (e) {
      print('Error deleting alert from Firestore: $e');
      rethrow;
    }
  }

  // ========== ROOT ALERTS (from camera/AI) ==========
  // The external camera/AI system writes alerts to a top-level `alerts`
  // collection with a different schema: { type, severity, timestamp }.
  // These methods read/write that collection without touching the existing
  // per-user alert logic above.

  AlertModel _mapRootAlertDoc(DocumentSnapshot doc, String userId) {
    final data = doc.data() as Map<String, dynamic>;
    final typeStr = (data['type'] ?? '') as String;
    final severity = (data['severity'] ?? '') as String;

    // Map the camera's `type` string to the app's AlertType enum
    AlertType alertType;
    String title;
    String message;
    switch (typeStr.toLowerCase()) {
      case 'no_movement':
      case 'immobility':
      case 'no_motion':
        alertType = AlertType.immobility;
        title = 'Prolonged Immobility';
        message = 'No movement detected for an extended period.'
            '${severity.isNotEmpty ? ' Severity: $severity.' : ''}';
        break;
      case 'fall':
        alertType = AlertType.fall;
        title = 'Fall Detected';
        message = 'A fall has been detected.'
            '${severity.isNotEmpty ? ' Severity: $severity.' : ''}';
        break;
      case 'emergency_gesture':
      case 'gesture':
        alertType = AlertType.emergencyGesture;
        title = 'Emergency Gesture';
        message = 'An emergency gesture was detected.'
            '${severity.isNotEmpty ? ' Severity: $severity.' : ''}';
        break;
      case 'abnormal_activity':
      case 'abnormal':
        alertType = AlertType.abnormalActivity;
        title = 'Abnormal Activity';
        message = 'Abnormal activity detected.'
            '${severity.isNotEmpty ? ' Severity: $severity.' : ''}';
        break;
      case 'medical_emergency':
      case 'medical':
        alertType = AlertType.medicalEmergency;
        title = 'Medical Emergency';
        message = 'A medical emergency was detected.'
            '${severity.isNotEmpty ? ' Severity: $severity.' : ''}';
        break;
      default:
        alertType = AlertType.manual;
        title = typeStr.isNotEmpty
            ? typeStr[0].toUpperCase() + typeStr.substring(1)
            : 'Alert';
        message = 'An alert was detected.'
            '${severity.isNotEmpty ? ' Severity: $severity.' : ''}';
    }

    // Parse timestamp (Firestore Timestamp or ISO8601 string)
    DateTime timestamp;
    final ts = data['timestamp'];
    if (ts is Timestamp) {
      timestamp = ts.toDate();
    } else if (ts is String) {
      timestamp = DateTime.tryParse(ts) ?? DateTime.now();
    } else {
      timestamp = DateTime.now();
    }

    // Status (may not exist on camera-written docs; default to active)
    AlertStatus status;
    final statusVal = data['status'];
    if (statusVal is int && statusVal >= 0 && statusVal < AlertStatus.values.length) {
      status = AlertStatus.values[statusVal];
    } else {
      status = AlertStatus.active;
    }

    return AlertModel(
      id: doc.id,
      userId: data['userId'] as String? ?? userId,
      alertType: alertType,
      title: title,
      message: message,
      location: data['location'] as String?,
      timestamp: timestamp,
      status: status,
      acknowledgedAt: data['acknowledgedAt'] != null
          ? (data['acknowledgedAt'] is Timestamp
              ? (data['acknowledgedAt'] as Timestamp).toDate()
              : DateTime.tryParse(data['acknowledgedAt'].toString()))
          : null,
      resolvedAt: data['resolvedAt'] != null
          ? (data['resolvedAt'] is Timestamp
              ? (data['resolvedAt'] as Timestamp).toDate()
              : DateTime.tryParse(data['resolvedAt'].toString()))
          : null,
      confidence: (data['confidence'] as num?)?.toDouble(),
    );
  }

  /// Real-time stream of ALL alerts in the root `alerts` collection,
  /// ordered by timestamp descending. Use this for the camera/AI alerts.
  Stream<List<AlertModel>> getRootAlertsStream(String userId) {
    return _firestore
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _mapRootAlertDoc(doc, userId))
            .toList());
  }

  /// One-time fetch of all alerts in the root `alerts` collection.
  Future<List<AlertModel>> getAllRootAlerts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('alerts')
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => _mapRootAlertDoc(doc, userId))
          .toList();
    } catch (e) {
      print('Error getting root alerts from Firestore: $e');
      return [];
    }
  }

  /// Updates the status / response fields of a root alert.
  Future<void> updateRootAlert(AlertModel alert) async {
    try {
      await _firestore.collection('alerts').doc(alert.id).update({
        'status': alert.status.index,
        'acknowledgedAt': alert.acknowledgedAt?.toIso8601String(),
        'resolvedAt': alert.resolvedAt?.toIso8601String(),
      });
    } catch (e) {
      print('Error updating root alert in Firestore: $e');
      rethrow;
    }
  }

  /// Deletes a root alert by its document id.
  Future<void> deleteRootAlert(String alertId) async {
    try {
      await _firestore.collection('alerts').doc(alertId).delete();
    } catch (e) {
      print('Error deleting root alert from Firestore: $e');
      rethrow;
    }
  }

  // ========== CONTACT OPERATIONS ==========
  Future<void> saveContact(ContactModel contact) async {
    try {
      await _firestore
          .collection('users')
          .doc(contact.userId)
          .collection('contacts')
          .doc(contact.id)
          .set({
        'id': contact.id,
        'userId': contact.userId,
        'name': contact.name,
        'phoneNumber': contact.phoneNumber,
        'email': contact.email,
        'relationship': contact.relationship.index,
        'isEmergencyContact': contact.isEmergencyContact,
        'profileImage': contact.profileImage,
        'createdAt': contact.createdAt.toIso8601String(),
      });
    } catch (e) {
      print('Error saving contact to Firestore: $e');
      rethrow;
    }
  }

  Future<List<ContactModel>> getContactsByUserId(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('contacts')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ContactModel(
                id: doc['id'],
                userId: doc['userId'],
                name: doc['name'],
                phoneNumber: doc['phoneNumber'],
                email: doc['email'],
                relationship: ContactRelationship.values[doc['relationship']],
                isEmergencyContact: doc['isEmergencyContact'],
                profileImage: doc['profileImage'],
                createdAt: DateTime.parse(doc['createdAt']),
              ))
          .toList();
    } catch (e) {
      print('Error getting contacts from Firestore: $e');
      return [];
    }
  }

  Future<void> updateContact(ContactModel contact) async {
    try {
      await _firestore
          .collection('users')
          .doc(contact.userId)
          .collection('contacts')
          .doc(contact.id)
          .update({
        'name': contact.name,
        'phoneNumber': contact.phoneNumber,
        'email': contact.email,
        'relationship': contact.relationship.index,
        'isEmergencyContact': contact.isEmergencyContact,
        'profileImage': contact.profileImage,
      });
    } catch (e) {
      print('Error updating contact in Firestore: $e');
      rethrow;
    }
  }

  Future<void> deleteContact(String userId, String contactId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('contacts')
          .doc(contactId)
          .delete();
    } catch (e) {
      print('Error deleting contact from Firestore: $e');
      rethrow;
    }
  }

  // ========== MESSAGE OPERATIONS ==========
  Future<void> saveMessage(MessageModel message) async {
    try {
      // Save to both users' conversation threads
      final conversationId =
          _getConversationId(message.senderId, message.receiverId);

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(message.id)
          .set({
        'id': message.id,
        'senderId': message.senderId,
        'receiverId': message.receiverId,
        'message': message.message,
        'timestamp': message.timestamp.toIso8601String(),
        'isRead': message.isRead,
        'attachmentUrl': message.attachmentUrl,
      });

      // Update conversation last message
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': message.message,
        'lastMessageTime': message.timestamp.toIso8601String(),
        'lastMessageSender': message.senderId,
      }).catchError((_) {
        // Create if doesn't exist
        return _firestore.collection('conversations').doc(conversationId).set({
          'id': conversationId,
          'users': [message.senderId, message.receiverId],
          'lastMessage': message.message,
          'lastMessageTime': message.timestamp.toIso8601String(),
          'lastMessageSender': message.senderId,
          'createdAt': DateTime.now().toIso8601String(),
        });
      });
    } catch (e) {
      print('Error saving message to Firestore: $e');
      rethrow;
    }
  }

  Future<List<MessageModel>> getMessagesBetweenUsers(
      String userId1, String userId2) async {
    try {
      final conversationId = _getConversationId(userId1, userId2);

      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => MessageModel(
                id: doc['id'],
                senderId: doc['senderId'],
                receiverId: doc['receiverId'],
                message: doc['message'],
                timestamp: DateTime.parse(doc['timestamp']),
                isRead: doc['isRead'],
                attachmentUrl: doc['attachmentUrl'],
              ))
          .toList();
    } catch (e) {
      print('Error getting messages from Firestore: $e');
      return [];
    }
  }

  Future<void> markMessageAsRead(String conversationId, String messageId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking message as read: $e');
      rethrow;
    }
  }

  // ========== HELPER METHODS ==========
  String _getConversationId(String userId1, String userId2) {
    return userId1.compareTo(userId2) < 0
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }

  // Real-time listeners
  Stream<List<AlertModel>> getAlertsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AlertModel(
                  id: doc['id'],
                  userId: doc['userId'],
                  alertType: AlertType.values[doc['alertType']],
                  title: doc['title'],
                  message: doc['message'],
                  location: doc['location'],
                  timestamp: DateTime.parse(doc['timestamp']),
                  status: AlertStatus.values[doc['status']],
                  acknowledgedAt: doc['acknowledgedAt'] != null
                      ? DateTime.parse(doc['acknowledgedAt'])
                      : null,
                  resolvedAt: doc['resolvedAt'] != null
                      ? DateTime.parse(doc['resolvedAt'])
                      : null,
                  confidence: doc['confidence'],
                ))
            .toList());
  }

  Stream<List<MessageModel>> getMessagesStream(String userId1, String userId2) {
    final conversationId = _getConversationId(userId1, userId2);
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel(
                  id: doc['id'],
                  senderId: doc['senderId'],
                  receiverId: doc['receiverId'],
                  message: doc['message'],
                  timestamp: DateTime.parse(doc['timestamp']),
                  isRead: doc['isRead'],
                  attachmentUrl: doc['attachmentUrl'],
                ))
            .toList());
  }
}
