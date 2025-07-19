import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bluetooth_service.dart';
import 'auth_service.dart';
import '../providers/bag_state_provider.dart';

class BagControllerService {
  final BluetoothService _bluetoothService;
  final AuthService _authService;
  Timer? _statusUpdateTimer;
  
  BagControllerService()
      : _bluetoothService = BluetoothService(),
        _authService = AuthService();
  
  // Initialize the service
  Future<void> initialize(BuildContext context) async {
    try {
      // Initialize Bluetooth
      await _bluetoothService.initialize();
      
      // Listen to Bluetooth data stream
      _bluetoothService.dataStream.listen((data) {
        _handleReceivedData(context, data);
      });
      
      // Start periodic status updates
      _startStatusUpdates(context);
      
    } catch (e) {
      print('Error initializing bag controller service: $e');
    }
  }
  
  // Handle received data from Bluetooth
  void _handleReceivedData(BuildContext context, Map<String, dynamic> data) {
    final bagState = Provider.of<BagStateProvider>(context, listen: false);
    
    switch (data['type']) {
      case 'battery':
        bagState.updateBatteryLevel(data['value']);
        break;
      case 'temperature':
        bagState.updateTemperature(data['value']);
        break;
      case 'rain':
        bagState.updateRainLevel(data['value']);
        break;
      case 'umbrella':
        bagState.setUmbrellaState(data['value']);
        break;
      case 'lock':
        bagState.setBagLockState(data['value']);
        break;
      case 'status':
        // Handle status updates
        break;
    }
  }
  
  // Start periodic status updates
  void _startStatusUpdates(BuildContext context) {
    _statusUpdateTimer?.cancel();
    _statusUpdateTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_bluetoothService.isConnected) {
        _bluetoothService.getBatteryLevel();
        _bluetoothService.getTemperature();
        _bluetoothService.getRainLevel();
        _bluetoothService.getStatus();
      }
    });
  }
  
  // Scan for smart bag devices
  Future<List<dynamic>> scanForDevices() async {
    try {
      return await _bluetoothService.scanForDevices();
    } catch (e) {
      print('Error scanning for devices: $e');
      return [];
    }
  }
  
  // Connect to smart bag
  Future<bool> connectToBag(dynamic device, BuildContext context) async {
    try {
      final bagState = Provider.of<BagStateProvider>(context, listen: false);
      bagState.setConnecting(true);
      
      final success = await _bluetoothService.connectToDevice(device);
      
      if (success) {
        bagState.setConnectionStatus(true, status: 'Connected to ${device.name}');
      } else {
        bagState.setConnectionStatus(false, status: 'Connection failed');
      }
      
      bagState.setConnecting(false);
      return success;
    } catch (e) {
      print('Error connecting to bag: $e');
      final bagState = Provider.of<BagStateProvider>(context, listen: false);
      bagState.setConnecting(false);
      bagState.setConnectionStatus(false, status: 'Connection error');
      return false;
    }
  }
  
  // Disconnect from smart bag
  Future<void> disconnectFromBag(BuildContext context) async {
    try {
      await _bluetoothService.disconnect();
      final bagState = Provider.of<BagStateProvider>(context, listen: false);
      bagState.setConnectionStatus(false, status: 'Disconnected');
    } catch (e) {
      print('Error disconnecting from bag: $e');
    }
  }
  
  // Control umbrella with authentication
  Future<bool> controlUmbrella(BuildContext context, bool open) async {
    try {
      // Authenticate first
      final authenticated = await _authService.authenticateForUmbrellaControl();
      
      if (!authenticated) {
        return false;
      }
      
      // Send command to Arduino
      bool success;
      if (open) {
        success = await _bluetoothService.openUmbrella();
      } else {
        success = await _bluetoothService.closeUmbrella();
      }
      
      if (success) {
        final bagState = Provider.of<BagStateProvider>(context, listen: false);
        bagState.setUmbrellaState(open);
      }
      
      return success;
    } catch (e) {
      print('Error controlling umbrella: $e');
      return false;
    }
  }
  
  // Lock/unlock bag with authentication
  Future<bool> controlBagLock(BuildContext context, bool lock) async {
    try {
      // Authenticate first
      final authenticated = await _authService.authenticateForBagUnlock();
      
      if (!authenticated) {
        return false;
      }
      
      // Send command to Arduino
      bool success;
      if (lock) {
        success = await _bluetoothService.lockBag();
      } else {
        success = await _bluetoothService.unlockBag();
      }
      
      if (success) {
        final bagState = Provider.of<BagStateProvider>(context, listen: false);
        bagState.setBagLockState(lock);
      }
      
      return success;
    } catch (e) {
      print('Error controlling bag lock: $e');
      return false;
    }
  }
  
  // Set admin PIN with authentication
  Future<bool> setAdminPin(BuildContext context, String pin) async {
    try {
      // Authenticate for admin access
      final authenticated = await _authService.authenticateForAdminAccess();
      
      if (!authenticated) {
        return false;
      }
      
      // Send command to Arduino
      final success = await _bluetoothService.setAdminPin(pin);
      
      if (success) {
        final bagState = Provider.of<BagStateProvider>(context, listen: false);
        bagState.setAdminPin(pin);
      }
      
      return success;
    } catch (e) {
      print('Error setting admin PIN: $e');
      return false;
    }
  }
  
  // Set SMS number with authentication
  Future<bool> setSmsNumber(BuildContext context, String number) async {
    try {
      // Authenticate for admin access
      final authenticated = await _authService.authenticateForAdminAccess();
      
      if (!authenticated) {
        return false;
      }
      
      // Send command to Arduino
      final success = await _bluetoothService.setSmsNumber(number);
      
      if (success) {
        final bagState = Provider.of<BagStateProvider>(context, listen: false);
        bagState.setSmsNumber(number);
      }
      
      return success;
    } catch (e) {
      print('Error setting SMS number: $e');
      return false;
    }
  }
  
  // Get current sensor readings
  Future<void> refreshSensorData() async {
    try {
      if (_bluetoothService.isConnected) {
        await _bluetoothService.getBatteryLevel();
        await _bluetoothService.getTemperature();
        await _bluetoothService.getRainLevel();
      }
    } catch (e) {
      print('Error refreshing sensor data: $e');
    }
  }
  
  // Check authentication status
  Future<Map<String, bool>> getAuthenticationStatus() async {
    return await _authService.getAuthenticationStatus();
  }
  
  // Dispose resources
  void dispose() {
    _statusUpdateTimer?.cancel();
    _bluetoothService.dispose();
  }
}