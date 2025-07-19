import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/bag_state_provider.dart';
import '../services/bag_controller_service.dart';
import '../widgets/connection_widget.dart';
import '../widgets/sensor_widget.dart';
import '../widgets/control_widget.dart';
import '../widgets/admin_widget.dart';
import 'device_scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late BagControllerService _bagControllerService;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  @override
  void initState() {
    super.initState();
    _bagControllerService = BagControllerService();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }
  
  Future<void> _initializeApp() async {
    await _bagControllerService.initialize(context);
    _fadeController.forward();
    _slideController.forward();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _bagControllerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'Smart Bag Controller',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
        actions: [
          Consumer<BagStateProvider>(
            builder: (context, bagState, child) {
              return IconButton(
                icon: Icon(
                  bagState.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                  color: bagState.isConnected ? Colors.green : Colors.grey,
                ),
                onPressed: () {
                  if (!bagState.isConnected) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DeviceScanScreen(),
                      ),
                    );
                  } else {
                    _showDisconnectDialog();
                  }
                },
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'admin':
                  _showAdminPanel();
                  break;
                case 'settings':
                  _showSettings();
                  break;
                case 'help':
                  _showHelp();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'admin',
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings),
                    SizedBox(width: 8),
                    Text('Admin Panel'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help),
                    SizedBox(width: 8),
                    Text('Help'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(_slideController),
          child: Consumer<BagStateProvider>(
            builder: (context, bagState, child) {
              return RefreshIndicator(
                onRefresh: () async {
                  await _bagControllerService.refreshSensorData();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Connection Status
                      ConnectionWidget(
                        isConnected: bagState.isConnected,
                        isConnecting: bagState.isConnecting,
                        connectionStatus: bagState.connectionStatus,
                        onConnect: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DeviceScanScreen(),
                            ),
                          );
                        },
                        onDisconnect: () => _showDisconnectDialog(),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Sensor Data
                      if (bagState.isConnected) ...[
                        SensorWidget(
                          batteryLevel: bagState.batteryLevel,
                          temperature: bagState.temperature,
                          rainLevel: bagState.rainLevel,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Control Buttons
                        ControlWidget(
                          umbrellaOpen: bagState.umbrellaOpen,
                          bagLocked: bagState.bagLocked,
                          onUmbrellaToggle: () async {
                            await _bagControllerService.controlUmbrella(
                              context,
                              !bagState.umbrellaOpen,
                            );
                          },
                          onBagLockToggle: () async {
                            await _bagControllerService.controlBagLock(
                              context,
                              !bagState.bagLocked,
                            );
                          },
                        ),
                      ] else ...[
                        // Not connected state
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.bluetooth_disabled,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Not Connected',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Connect to your smart bag to start controlling it',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const DeviceScanScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.bluetooth_searching),
                                label: const Text('Connect to Bag'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  void _showDisconnectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect'),
        content: const Text('Are you sure you want to disconnect from the smart bag?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _bagControllerService.disconnectFromBag(context);
            },
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
  
  void _showAdminPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AdminWidget(),
    );
  }
  
  void _showSettings() {
    // TODO: Implement settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings coming soon!')),
    );
  }
  
  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Smart Bag Controller Help:'),
            SizedBox(height: 8),
            Text('• Use fingerprint to unlock bag and control umbrella'),
            Text('• Monitor battery, temperature, and rain levels'),
            Text('• Admin panel for PIN and SMS settings'),
            Text('• Bluetooth connection to Arduino Mega'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}