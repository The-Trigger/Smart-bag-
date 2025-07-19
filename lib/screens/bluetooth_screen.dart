import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../providers/bluetooth_provider.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
    bluetoothProvider.startScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Devices'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Consumer<BluetoothProvider>(
            builder: (context, bluetoothProvider, child) {
              return IconButton(
                icon: Icon(
                  bluetoothProvider.isScanning ? Icons.stop : Icons.refresh,
                ),
                onPressed: () {
                  if (bluetoothProvider.isScanning) {
                    bluetoothProvider.stopScan();
                  } else {
                    _startScan();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<BluetoothProvider>(
        builder: (context, bluetoothProvider, child) {
          return Column(
            children: [
              // Connection Status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: bluetoothProvider.isConnected ? Colors.green : Colors.red,
                child: Row(
                  children: [
                    Icon(
                      bluetoothProvider.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      bluetoothProvider.isConnected ? 'Connected to Smart Bag' : 'Not Connected',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Scan Results
              Expanded(
                child: bluetoothProvider.isScanning
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Scanning for devices...'),
                          ],
                        ),
                      )
                    : bluetoothProvider.scanResults.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bluetooth_disabled,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No devices found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Make sure your Smart Bag is turned on and nearby',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: bluetoothProvider.scanResults.length,
                            itemBuilder: (context, index) {
                              final result = bluetoothProvider.scanResults[index];
                              final device = result.device;
                              
                              return ListTile(
                                leading: const Icon(Icons.bluetooth),
                                title: Text(device.platformName.isNotEmpty 
                                    ? device.platformName 
                                    : 'Unknown Device'),
                                subtitle: Text(device.remoteId.toString()),
                                trailing: bluetoothProvider.isConnected
                                    ? const Icon(Icons.check_circle, color: Colors.green)
                                    : ElevatedButton(
                                        onPressed: () => _connectToDevice(device),
                                        child: const Text('Connect'),
                                      ),
                                onTap: () => _connectToDevice(device),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Connecting...'),
          ],
        ),
      ),
    );

    try {
      bool success = await bluetoothProvider.connectToDevice(device);
      Navigator.of(context).pop(); // Close loading dialog
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connected to Smart Bag'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Close Bluetooth screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to connect'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}