import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/bluetooth_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/status_card.dart';
import '../widgets/control_button.dart';
import 'bluetooth_screen.dart';
import 'settings_screen.dart';
import 'admin_screen.dart';

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
    _initializeBluetooth();
  }

  Future<void> _initializeBluetooth() async {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    if (settingsProvider.autoConnect && settingsProvider.lastConnectedDevice.isNotEmpty) {
      // Auto-connect logic would go here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Bag Control'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Consumer<BluetoothProvider>(
            builder: (context, bluetoothProvider, child) {
              return IconButton(
                icon: Icon(
                  bluetoothProvider.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                  color: bluetoothProvider.isConnected ? Colors.green : Colors.red,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const BluetoothScreen()),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardTab(),
          _buildControlsTab(),
          _buildSettingsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.control_camera),
            label: 'Controls',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Smart Bag Status',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Status Cards
          Consumer<BluetoothProvider>(
            builder: (context, bluetoothProvider, child) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatusCard(
                          title: 'Battery',
                          value: '${bluetoothProvider.batteryLevel}%',
                          icon: Icons.battery_full,
                          color: _getBatteryColor(bluetoothProvider.batteryLevel),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatusCard(
                          title: 'Temperature',
                          value: '${bluetoothProvider.temperature.toStringAsFixed(1)}°C',
                          icon: Icons.thermostat,
                          color: _getTemperatureColor(bluetoothProvider.temperature),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StatusCard(
                          title: 'Rain Level',
                          value: '${bluetoothProvider.rainLevel}%',
                          icon: Icons.water_drop,
                          color: _getRainColor(bluetoothProvider.rainLevel),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatusCard(
                          title: 'Umbrella',
                          value: bluetoothProvider.umbrellaOpen ? 'Open' : 'Closed',
                          icon: bluetoothProvider.umbrellaOpen ? Icons.umbrella : Icons.umbrella_outlined,
                          color: bluetoothProvider.umbrellaOpen ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 30),
          
          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Consumer<BluetoothProvider>(
            builder: (context, bluetoothProvider, child) {
              return Column(
                children: [
                  ControlButton(
                    title: bluetoothProvider.umbrellaOpen ? 'Close Umbrella' : 'Open Umbrella',
                    icon: bluetoothProvider.umbrellaOpen ? Icons.umbrella : Icons.umbrella_outlined,
                    onPressed: () async {
                      bool success = await bluetoothProvider.toggleUmbrella();
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              bluetoothProvider.umbrellaOpen ? 'Umbrella opened' : 'Umbrella closed'
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to control umbrella'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  ControlButton(
                    title: 'Refresh Data',
                    icon: Icons.refresh,
                    onPressed: () async {
                      bool success = await bluetoothProvider.requestData();
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Data refreshed'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to refresh data'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bag Controls',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          Consumer<BluetoothProvider>(
            builder: (context, bluetoothProvider, child) {
              return Column(
                children: [
                  ControlButton(
                    title: 'Open Umbrella',
                    icon: Icons.umbrella,
                    onPressed: bluetoothProvider.umbrellaOpen ? null : () async {
                      bool success = await bluetoothProvider.sendCommand('OPEN_UMBRELLA');
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Umbrella opened'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  ControlButton(
                    title: 'Close Umbrella',
                    icon: Icons.umbrella_outlined,
                    onPressed: !bluetoothProvider.umbrellaOpen ? null : () async {
                      bool success = await bluetoothProvider.sendCommand('CLOSE_UMBRELLA');
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Umbrella closed'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  ControlButton(
                    title: 'Emergency Open',
                    icon: Icons.emergency,
                    onPressed: () async {
                      bool success = await bluetoothProvider.sendCommand('EMERGENCY_OPEN');
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Emergency mode activated'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 30),
          
          const Text(
            'Admin Functions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ControlButton(
            title: 'Admin Settings',
            icon: Icons.admin_panel_settings,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AdminScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return const SettingsScreen();
  }

  Color _getBatteryColor(int level) {
    if (level > 50) return Colors.green;
    if (level > 20) return Colors.orange;
    return Colors.red;
  }

  Color _getTemperatureColor(double temp) {
    if (temp < 10) return Colors.blue;
    if (temp > 30) return Colors.red;
    return Colors.green;
  }

  Color _getRainColor(int level) {
    if (level < 30) return Colors.green;
    if (level < 70) return Colors.orange;
    return Colors.red;
  }
}