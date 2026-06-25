import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/alert_model.dart';
import '../models/contact_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/firestore_service.dart';

class AlertProvider extends ChangeNotifier {
  List<AlertModel> _alerts = [];
  bool _isLoading = false;
  String? _currentUserId;
  StreamSubscription<List<AlertModel>>? _alertsSubscription;
  bool _isFirstLoad = true;
  Set<String> _notifiedAlertIds = {};

  List<AlertModel> get alerts => _alerts;
  bool get isLoading => _isLoading;
  
  List<AlertModel> get recentAlerts => _alerts.take(10).toList();
  
  int get totalAlertsToday {
    final today = DateTime.now();
    return _alerts.where((alert) {
      return alert.timestamp.year == today.year &&
          alert.timestamp.month == today.month &&
          alert.timestamp.day == today.day;
    }).length;
  }

  // Initialize real-time listener for a user
  void initializeUser(String userId) {
    _currentUserId = userId;
    _notifiedAlertIds.clear();
    _isFirstLoad = true;
    _setupAlertsListener(userId);
  }

  // Setup real-time stream listener for alerts from the root `alerts`
  // collection (where the camera/AI system writes alerts).
  void _setupAlertsListener(String userId) {
    _alertsSubscription?.cancel();
    try {
      _alertsSubscription =
          FirestoreService.instance.getRootAlertsStream(userId).listen((alerts) {
        final previousIds = _alerts.map((a) => a.id).toSet();

        _alerts = alerts;
        _alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        // Skip notification on the very first load so existing alerts
        // don't trigger a flood of notifications when the app starts.
        // Only genuinely new alerts arriving AFTER the first load fire.
        if (_isFirstLoad) {
          _isFirstLoad = false;
          for (var a in alerts) {
            _notifiedAlertIds.add(a.id);
          }
          notifyListeners();
          return;
        }

        // Detect brand-new alerts that arrived from Firestore
        final newAlerts = alerts.where((a) {
          final isNew = !previousIds.contains(a.id) &&
              !_notifiedAlertIds.contains(a.id);
          if (isNew) {
            _notifiedAlertIds.add(a.id);
          }
          return isNew;
        }).toList();

        notifyListeners();

        // Fire notification + vibration for each new alert
        if (newAlerts.isNotEmpty) {
          _handleNewAlerts(newAlerts);
        }
      }, onError: (error) {
        print('Error listening to alerts: $error');
        // Fallback to local database on error
        loadAlerts();
      });
    } catch (e) {
      print('Error setting up alerts listener: $e');
    }
  }

  // Trigger notification and haptic feedback when new alerts arrive
  void _handleNewAlerts(List<AlertModel> newAlerts) {
    for (final alert in newAlerts) {
      NotificationService.instance.showAlertNotification(alert);
    }
    // Strong haptic feedback to grab attention
    HapticFeedback.heavyImpact();
    HapticFeedback.vibrate();
  }

  void disposeListener() {
    _alertsSubscription?.cancel();
    _alertsSubscription = null;
  }

  Future<void> loadAlerts() async {
    if (_currentUserId == null) {
      // Load from local database as fallback
      _alerts = await DatabaseService.instance.getAllAlerts();
      _alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Load from root `alerts` collection (camera/AI alerts)
      _alerts = await FirestoreService.instance.getAllRootAlerts(_currentUserId!);
      _alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Cache in local database
      for (var alert in _alerts) {
        await DatabaseService.instance.insertAlert(alert);
      }
    } catch (e) {
      print('Error loading alerts from Firestore: $e');
      // Fallback to local database
      _alerts = await DatabaseService.instance.getAllAlerts();
      _alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createTestAlert({
    required String userId,
    List<ContactModel>? emergencyContacts,
  }) async {
    final alert = AlertModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      alertType: AlertType.test,
      title: 'Test Alert',
      message: 'This is a test emergency alert',
      timestamp: DateTime.now(),
      status: AlertStatus.pending,
    );

    try {
      // Save to Firestore
      await FirestoreService.instance.saveAlert(alert);
    } catch (e) {
      print('Error saving test alert to Firestore: $e');
    }

    // Always save to local database for offline support
    await DatabaseService.instance.insertAlert(alert);
    await NotificationService.instance.showAlertNotification(alert);
    
    // Simulate sending to emergency contacts
    if (emergencyContacts != null && emergencyContacts.isNotEmpty) {
      for (var contact in emergencyContacts) {
        debugPrint('Alert sent to: ${contact.name} - ${contact.phoneNumber}');
      }
    }
  }

  Future<void> createEmergencyAlert({
    required String userId,
    required AlertType type,
    required String title,
    required String message,
    String? location,
    List<ContactModel>? emergencyContacts,
  }) async {
    final alert = AlertModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      alertType: type,
      title: title,
      message: message,
      location: location,
      timestamp: DateTime.now(),
      status: AlertStatus.active,
    );

    try {
      // Save to Firestore
      await FirestoreService.instance.saveAlert(alert);
    } catch (e) {
      print('Error saving emergency alert to Firestore: $e');
    }

    // Always save to local database for offline support
    await DatabaseService.instance.insertAlert(alert);
    await NotificationService.instance.showAlertNotification(alert);
    
    // Send to emergency contacts
    if (emergencyContacts != null && emergencyContacts.isNotEmpty) {
      for (var contact in emergencyContacts) {
        debugPrint('EMERGENCY Alert sent to: ${contact.name} - ${contact.phoneNumber}');
      }
    }
  }

  Future<void> updateAlertStatus(String alertId, AlertStatus status) async {
    final alert = _alerts.firstWhere((a) => a.id == alertId);
    final now = DateTime.now();
    final updatedAlert = alert.copyWith(
      status: status,
      acknowledgedAt: status == AlertStatus.acknowledged ? now : null,
      resolvedAt: status == AlertStatus.resolved ? now : null,
    );

    try {
      // Update in Firestore (root alerts collection)
      await FirestoreService.instance.updateRootAlert(updatedAlert);
    } catch (e) {
      print('Error updating alert in Firestore: $e');
    }

    // Update local database
    await DatabaseService.instance.updateAlert(updatedAlert);
  }

  Future<void> deleteAlert(String alertId) async {
    try {
      // Delete from Firestore (root alerts collection)
      await FirestoreService.instance.deleteRootAlert(alertId);
    } catch (e) {
      print('Error deleting alert from Firestore: $e');
    }

    // Delete from local database
    await DatabaseService.instance.deleteAlert(alertId);
  }

  Future<void> clearAllAlerts() async {
    for (var alert in _alerts) {
      try {
        // Delete from Firestore (root alerts collection)
        await FirestoreService.instance.deleteRootAlert(alert.id);
      } catch (e) {
        print('Error deleting alert from Firestore: $e');
      }

      // Delete from local database
      await DatabaseService.instance.deleteAlert(alert.id);
    }
  }
}
