import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/alert_provider.dart';
import '../../providers/contact_provider.dart';
import '../../utils/app_localization.dart';
import '../../models/alert_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class DashboardTab extends StatelessWidget {
  final VoidCallback? onViewAll;
  const DashboardTab({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final alertProvider = Provider.of<AlertProvider>(context);
    final contactProvider = Provider.of<ContactProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization?.translate('dashboard') ?? 'Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (authProvider.currentUser != null) {
                alertProvider.loadAlerts();
                contactProvider.loadContacts(authProvider.currentUser!.id);
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (authProvider.currentUser != null) {
            await alertProvider.loadAlerts();
            await contactProvider.loadContacts(authProvider.currentUser!.id);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          authProvider.currentUser?.fullName[0].toUpperCase() ??
                              'U',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localization?.translate('welcome_back') ??
                                  'Welcome Back',
                              style: theme.textTheme.bodyLarge,
                            ),
                            Text(
                              authProvider.currentUser?.fullName ?? '',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.notifications_active,
                      title: localization?.translate('todays_alerts') ??
                          "Today's Alerts",
                      value: alertProvider.totalAlertsToday.toString(),
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.people,
                      title: localization?.translate('emergency_contacts') ??
                          'Emergency Contacts',
                      value: contactProvider.emergencyContacts.length.toString(),
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              // Recent Alerts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localization?.translate('recent_alerts') ??
                        'Recent Alerts',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: onViewAll,
                    child: Text(
                      localization?.translate('view_all') ?? 'View All',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (alertProvider.recentAlerts.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          localization?.translate('no_alerts') ??
                              'No alerts yet',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...alertProvider.recentAlerts.take(5).map(
                      (alert) => _AlertCard(alert: alert),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AlertModel alert;

  const _AlertCard({required this.alert});

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
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getStatusColor().withOpacity(0.2),
          child: Icon(
            getAlertIcon(),
            color: getStatusColor(),
          ),
        ),
        title: Text(
          alert.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.message),
            const SizedBox(height: 4),
            Text(
              timeago.format(alert.timestamp),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        isThreeLine: true,
      ),
    );
  }
}
