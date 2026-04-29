import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../models/contact_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class AlertProvider extends ChangeNotifier {
  List<AlertModel> _alerts = [];
  bool _isLoading = false;

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

  Future<void> loadAlerts() async {
    _isLoading = true;
    notifyListeners();

    _alerts = await DatabaseService.instance.getAllAlerts();
    _alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

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

    await DatabaseService.instance.insertAlert(alert);
    await NotificationService.instance.showAlertNotification(alert);
    
    // Simulate sending to emergency contacts
    if (emergencyContacts != null && emergencyContacts.isNotEmpty) {
      for (var contact in emergencyContacts) {
        // In real implementation, this would send SMS/call
        debugPrint('Alert sent to: ${contact.name} - ${contact.phoneNumber}');
      }
    }

    await loadAlerts();
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

    await DatabaseService.instance.insertAlert(alert);
    await NotificationService.instance.showAlertNotification(alert);
    
    // Send to emergency contacts
    if (emergencyContacts != null && emergencyContacts.isNotEmpty) {
      for (var contact in emergencyContacts) {
        debugPrint('EMERGENCY Alert sent to: ${contact.name} - ${contact.phoneNumber}');
      }
    }

    await loadAlerts();
  }

  Future<void> updateAlertStatus(String alertId, AlertStatus status) async {
    final alert = _alerts.firstWhere((a) => a.id == alertId);
    final updatedAlert = alert.copyWith(
      status: status,
      resolvedAt: status == AlertStatus.resolved ? DateTime.now() : null,
    );

    await DatabaseService.instance.updateAlert(updatedAlert);
    await loadAlerts();
  }

  Future<void> deleteAlert(String alertId) async {
    await DatabaseService.instance.deleteAlert(alertId);
    await loadAlerts();
  }

  Future<void> clearAllAlerts() async {
    for (var alert in _alerts) {
      await DatabaseService.instance.deleteAlert(alert.id);
    }
    await loadAlerts();
  }
}
