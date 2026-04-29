import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/alert_provider.dart';
import '../../providers/contact_provider.dart';
import '../../utils/app_localization.dart';
import 'dashboard_tab.dart';
import 'alerts_tab.dart';
import 'contacts_tab.dart';
import 'messages_tab_new.dart';
import 'settings_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final alertProvider = Provider.of<AlertProvider>(context, listen: false);
    final contactProvider = Provider.of<ContactProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await alertProvider.loadAlerts();
      await contactProvider.loadContacts(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    final List<Widget> tabs = [
      const DashboardTab(),
      const AlertsTab(),
      const ContactsTab(),
      const MessagesTab(),
      const SettingsTab(),
    ];

    final List<BottomNavigationBarItem> navItems = [
      BottomNavigationBarItem(
        icon: const Icon(Icons.dashboard),
        label: localization?.translate('dashboard') ?? 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.notifications_active),
        label: localization?.translate('alerts') ?? 'Alerts',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.contacts),
        label: localization?.translate('contacts') ?? 'Contacts',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.message),
        label: localization?.translate('messages') ?? 'Messages',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.settings),
        label: localization?.translate('settings') ?? 'Settings',
      ),
    ];

    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: navItems.map((item) {
          return NavigationDestination(
            icon: item.icon,
            label: item.label!,
          );
        }).toList(),
      ),
    );
  }
}
