enum AlertType {
  test,
  fall,
  immobility,
  emergencyGesture,
  abnormalActivity,
  medicalEmergency,
  manual,
}

enum AlertStatus {
  pending,
  active,
  acknowledged,
  resolved,
  falseAlarm,
}

class AlertModel {
  final String id;
  final String userId;
  final AlertType alertType;
  final String title;
  final String message;
  final String? location;
  final DateTime timestamp;
  final AlertStatus status;
  final DateTime? acknowledgedAt;
  final DateTime? resolvedAt;
  final double? confidence;

  AlertModel({
    required this.id,
    required this.userId,
    required this.alertType,
    required this.title,
    required this.message,
    this.location,
    required this.timestamp,
    required this.status,
    this.acknowledgedAt,
    this.resolvedAt,
    this.confidence,
  });

  String get alertTypeString {
    switch (alertType) {
      case AlertType.test:
        return 'Test Alert';
      case AlertType.fall:
        return 'Fall Detected';
      case AlertType.immobility:
        return 'Prolonged Immobility';
      case AlertType.emergencyGesture:
        return 'Emergency Gesture';
      case AlertType.abnormalActivity:
        return 'Abnormal Activity';
      case AlertType.medicalEmergency:
        return 'Medical Emergency';
      case AlertType.manual:
        return 'Manual Alert';
    }
  }

  String get statusString {
    switch (status) {
      case AlertStatus.pending:
        return 'Pending';
      case AlertStatus.active:
        return 'Active';
      case AlertStatus.acknowledged:
        return 'Acknowledged';
      case AlertStatus.resolved:
        return 'Resolved';
      case AlertStatus.falseAlarm:
        return 'False Alarm';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'alertType': alertType.index,
      'title': title,
      'message': message,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
      'status': status.index,
      'acknowledgedAt': acknowledgedAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'confidence': confidence,
    };
  }

  factory AlertModel.fromMap(Map<String, dynamic> map) {
    return AlertModel(
      id: map['id'],
      userId: map['userId'],
      alertType: AlertType.values[map['alertType']],
      title: map['title'],
      message: map['message'],
      location: map['location'],
      timestamp: DateTime.parse(map['timestamp']),
      status: AlertStatus.values[map['status']],
      acknowledgedAt: map['acknowledgedAt'] != null
          ? DateTime.parse(map['acknowledgedAt'])
          : null,
      resolvedAt: map['resolvedAt'] != null
          ? DateTime.parse(map['resolvedAt'])
          : null,
      confidence: map['confidence'],
    );
  }

  AlertModel copyWith({
    AlertStatus? status,
    DateTime? acknowledgedAt,
    DateTime? resolvedAt,
  }) {
    return AlertModel(
      id: id,
      userId: userId,
      alertType: alertType,
      title: title,
      message: message,
      location: location,
      timestamp: timestamp,
      status: status ?? this.status,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      confidence: confidence,
    );
  }
}
