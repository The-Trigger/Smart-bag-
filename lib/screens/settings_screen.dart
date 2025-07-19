import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // App Settings
          _buildSection(
            title: 'App Settings',
            children: [
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Use dark theme'),
                    value: settingsProvider.isDarkMode,
                    onChanged: (value) {
                      settingsProvider.setDarkMode(value);
                    },
                  );
                },
              ),
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return SwitchListTile(
                    title: const Text('Auto Connect'),
                    subtitle: const Text('Automatically connect to last device'),
                    value: settingsProvider.autoConnect,
                    onChanged: (value) {
                      settingsProvider.setAutoConnect(value);
                    },
                  );
                },
              ),
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return SwitchListTile(
                    title: const Text('Notifications'),
                    subtitle: const Text('Enable push notifications'),
                    value: settingsProvider.notificationsEnabled,
                    onChanged: (value) {
                      settingsProvider.setNotificationsEnabled(value);
                    },
                  );
                },
              ),
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return ListTile(
                    title: const Text('Refresh Interval'),
                    subtitle: Text('${settingsProvider.refreshInterval} seconds'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showRefreshIntervalDialog(context, settingsProvider),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Security Settings
          _buildSection(
            title: 'Security',
            children: [
              ListTile(
                title: const Text('Change Admin PIN'),
                subtitle: const Text('Update your admin PIN'),
                leading: const Icon(Icons.lock),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showChangePinDialog(context),
              ),
              ListTile(
                title: const Text('Fingerprint Settings'),
                subtitle: const Text('Manage biometric authentication'),
                leading: const Icon(Icons.fingerprint),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showFingerprintSettings(context),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // About
          _buildSection(
            title: 'About',
            children: [
              ListTile(
                title: const Text('App Version'),
                subtitle: const Text('1.0.0'),
                leading: const Icon(Icons.info),
              ),
              ListTile(
                title: const Text('Smart Bag Control'),
                subtitle: const Text('Control your smart bag with ease'),
                leading: const Icon(Icons.work_outline),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Actions
          _buildSection(
            title: 'Actions',
            children: [
              ListTile(
                title: const Text('Reset Settings'),
                subtitle: const Text('Reset all app settings to default'),
                leading: const Icon(Icons.restore),
                onTap: () => _showResetDialog(context),
              ),
              ListTile(
                title: const Text('Logout'),
                subtitle: const Text('Sign out of the app'),
                leading: const Icon(Icons.logout),
                onTap: () => _logout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  void _showRefreshIntervalDialog(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refresh Interval'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select how often to refresh data from the smart bag:'),
            const SizedBox(height: 16),
            DropdownButton<int>(
              value: settingsProvider.refreshInterval,
              isExpanded: true,
              items: [5, 10, 15, 30, 60].map((seconds) {
                return DropdownMenuItem(
                  value: seconds,
                  child: Text('$seconds seconds'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setRefreshInterval(value);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog(BuildContext context) {
    // This would open a PIN change dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PIN change feature coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showFingerprintSettings(BuildContext context) {
    // This would open fingerprint settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fingerprint settings coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to default?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
              settingsProvider.resetSettings();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              authProvider.logout();
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}