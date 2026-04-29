import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/alert_model.dart';
import '../../providers/alert_provider.dart';
import '../../utils/app_localization.dart';
import 'package:intl/intl.dart';

class AlertDetailScreen extends StatelessWidget {
  final AlertModel alert;

  const AlertDetailScreen({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final alertProvider = Provider.of<AlertProvider>(context);
    final theme = Theme.of(context);

    Color getStatusColor() {
      switch (alert.status) {
        case AlertStatus.active:
          return Colors.red;
        case AlertStatus.pending:
          return Colors.orange;
        case AlertStatus.acknowledged:
          return Colors.blue;
        case AlertStatus.resolved:
          return Colors.green;
        case AlertStatus.falseAlarm:
          return Colors.grey;
      }
    }

    IconData getAlertIcon() {
      switch (alert.alertType) {
        case AlertType.fall:
          return Icons.person_off;
        case AlertType.emergencyGesture:
          return Icons.front_hand;
        case AlertType.immobility:
          return Icons.accessibility_new;
        case AlertType.abnormalActivity:
          return Icons.warning;
        case AlertType.medicalEmergency:
          return Icons.medical_services;
        default:
          return Icons.notification_important;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localization?.translate('alert_details') ?? 'Alert Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alert Icon and Status
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: getStatusColor().withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      getAlertIcon(),
                      size: 64,
                      color: getStatusColor(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      alert.statusString,
                      style: TextStyle(
                        color: getStatusColor(),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Alert Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      alert.message,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.category,
                      label: 'Type',
                      value: alert.alertTypeString,
                    ),
                    _DetailRow(
                      icon: Icons.access_time,
                      label: 'Time',
                      value: DateFormat('dd MMM yyyy, hh:mm a')
                          .format(alert.timestamp),
                    ),
                    if (alert.location != null)
                      _DetailRow(
                        icon: Icons.location_on,
                        label: 'Location',
                        value: alert.location!,
                      ),
                    if (alert.confidence != null)
                      _DetailRow(
                        icon: Icons.speed,
                        label: 'Confidence',
                        value: '${(alert.confidence! * 100).toStringAsFixed(1)}%',
                      ),
                    if (alert.acknowledgedAt != null)
                      _DetailRow(
                        icon: Icons.check_circle,
                        label: 'Acknowledged At',
                        value: DateFormat('dd MMM yyyy, hh:mm a')
                            .format(alert.acknowledgedAt!),
                      ),
                    if (alert.resolvedAt != null)
                      _DetailRow(
                        icon: Icons.done_all,
                        label: 'Resolved At',
                        value: DateFormat('dd MMM yyyy, hh:mm a')
                            .format(alert.resolvedAt!),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            if (alert.status == AlertStatus.pending ||
                alert.status == AlertStatus.active) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await alertProvider.updateAlertStatus(
                      alert.id,
                      AlertStatus.acknowledged,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Alert acknowledged'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: Text(
                    localization?.translate('acknowledge') ?? 'Acknowledge',
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (alert.status != AlertStatus.resolved &&
                alert.status != AlertStatus.falseAlarm) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await alertProvider.updateAlertStatus(
                      alert.id,
                      AlertStatus.resolved,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.done_all),
                  label: Text(
                    localization?.translate('resolve') ?? 'Resolve',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await alertProvider.updateAlertStatus(
                      alert.id,
                      AlertStatus.falseAlarm,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.cancel),
                  label: Text(
                    localization?.translate('false_alarm') ?? 'False Alarm',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        localization?.translate('delete_alert') ??
                            'Delete Alert',
                      ),
                      content: const Text(
                        'Are you sure you want to delete this alert?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            localization?.translate('cancel') ?? 'Cancel',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text(
                            localization?.translate('delete') ?? 'Delete',
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await alertProvider.deleteAlert(alert.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                label: Text(
                  localization?.translate('delete') ?? 'Delete',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
