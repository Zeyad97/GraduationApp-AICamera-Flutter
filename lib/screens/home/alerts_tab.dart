import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/alert_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_localization.dart';
import '../../models/alert_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../alert/alert_detail_screen.dart';

class AlertsTab extends StatelessWidget {
  const AlertsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final alertProvider = Provider.of<AlertProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization?.translate('alerts') ?? 'Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearAlertsDialog(context),
          ),
        ],
      ),
      body: alertProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : alertProvider.alerts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localization?.translate('no_alerts') ?? 'No alerts yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => alertProvider.loadAlerts(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: alertProvider.alerts.length,
                    itemBuilder: (context, index) {
                      final alert = alertProvider.alerts[index];
                      return _AlertListItem(alert: alert);
                    },
                  ),
                ),
    );
  }

  void _showClearAlertsDialog(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final alertProvider = Provider.of<AlertProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization?.translate('clear_all') ?? 'Clear All'),
        content: Text(
          localization?.translate('clear_all_alerts_desc') ??
              'Are you sure you want to clear all alerts?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localization?.translate('cancel') ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await alertProvider.clearAllAlerts();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(localization?.translate('delete') ?? 'Delete'),
          ),
        ],
      ),
    );
  }
}

class _AlertListItem extends StatelessWidget {
  final AlertModel alert;

  const _AlertListItem({required this.alert});

  @override
  Widget build(BuildContext context) {
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlertDetailScreen(alert: alert),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: getStatusColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  getAlertIcon(),
                  color: getStatusColor(),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            alert.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: getStatusColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            alert.statusString,
                            style: TextStyle(
                              color: getStatusColor(),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.message,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeago.format(alert.timestamp),
                          style: theme.textTheme.bodySmall,
                        ),
                        if (alert.location != null) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              alert.location!,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
