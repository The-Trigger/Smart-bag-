import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';

class BluetoothService {
  static const String _serviceUuid = "0000ffe0-0000-1000-8000-00805f9b34fb";
  static const String _characteristicUuid = "0000ffe1-0000-1000-8000-00805f9b34fb";
  
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _readCharacteristic;
  
  bool _isConnected = false;
  bool _isScanning = false;
  List<BluetoothDevice> _discoveredDevices = [];
  
  // Getters
  bool get isConnected => _isConnected;
  bool get isScanning => _isScanning;
  List<BluetoothDevice> get discoveredDevices => _discoveredDevices;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  
  // Stream controllers for real-time updates
  final StreamController<Map<String, dynamic>> _dataStreamController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  Stream<Map<String, dynamic>> get dataStream => _dataStreamController.stream;
  
  // Initialize Bluetooth
  Future<void> initialize() async {
    try {
      // Check if Bluetooth is available
      if (await FlutterBluePlus.isSupported == false) {
        throw Exception('Bluetooth not supported');
      }
      
      // Listen to Bluetooth state changes
      FlutterBluePlus.adapterState.listen((state) {
        if (state == BluetoothAdapterState.on) {
          print('Bluetooth is on');
        } else {
          print('Bluetooth is off');
          _isConnected = false;
        }
      });
      
    } catch (e) {
      print('Error initializing Bluetooth: $e');
      rethrow;
    }
  }
  
  // Scan for devices
  Future<List<BluetoothDevice>> scanForDevices() async {
    try {
      _isScanning = true;
      _discoveredDevices.clear();
      
      // Start scanning
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
      
      // Listen for discovered devices
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (!_discoveredDevices.contains(result.device)) {
            _discoveredDevices.add(result.device);
          }
        }
      });
      
      await Future.delayed(Duration(seconds: 10));
      await FlutterBluePlus.stopScan();
      _isScanning = false;
      
      return _discoveredDevices;
    } catch (e) {
      _isScanning = false;
      print('Error scanning for devices: $e');
      rethrow;
    }
  }
  
  // Connect to device
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      _connectedDevice = device;
      
      // Connect to device
      await device.connect(timeout: Duration(seconds: 10));
      
      // Discover services
      List<BluetoothService> services = await device.discoverServices();
      
      for (BluetoothService service in services) {
        if (service.uuid.toString().toUpperCase() == _serviceUuid.toUpperCase()) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toUpperCase() == _characteristicUuid.toUpperCase()) {
              _writeCharacteristic = characteristic;
              _readCharacteristic = characteristic;
              
              // Enable notifications
              await characteristic.setNotifyValue(true);
              
              // Listen for data
              characteristic.onValueReceived.listen((value) {
                _handleReceivedData(value);
              });
              
              _isConnected = true;
              return true;
            }
          }
        }
      }
      
      throw Exception('Required service or characteristic not found');
    } catch (e) {
      print('Error connecting to device: $e');
      _isConnected = false;
      return false;
    }
  }
  
  // Disconnect from device
  Future<void> disconnect() async {
    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
      }
      _isConnected = false;
      _connectedDevice = null;
      _writeCharacteristic = null;
      _readCharacteristic = null;
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }
  
  // Send command to Arduino
  Future<bool> sendCommand(String command) async {
    try {
      if (!_isConnected || _writeCharacteristic == null) {
        throw Exception('Not connected to device');
      }
      
      List<int> bytes = utf8.encode(command + '\n');
      await _writeCharacteristic!.write(bytes);
      return true;
    } catch (e) {
      print('Error sending command: $e');
      return false;
    }
  }
  
  // Handle received data from Arduino
  void _handleReceivedData(Uint8List data) {
    try {
      String receivedString = utf8.decode(data);
      print('Received: $receivedString');
      
      // Parse the received data
      Map<String, dynamic> parsedData = _parseReceivedData(receivedString);
      _dataStreamController.add(parsedData);
    } catch (e) {
      print('Error parsing received data: $e');
    }
  }
  
  // Parse received data from Arduino
  Map<String, dynamic> _parseReceivedData(String data) {
    Map<String, dynamic> result = {};
    
    try {
      // Remove any whitespace and newlines
      data = data.trim();
      
      // Parse different data formats
      if (data.startsWith('BAT:')) {
        result['type'] = 'battery';
        result['value'] = double.tryParse(data.substring(4)) ?? 0.0;
      } else if (data.startsWith('TEMP:')) {
        result['type'] = 'temperature';
        result['value'] = double.tryParse(data.substring(5)) ?? 0.0;
      } else if (data.startsWith('RAIN:')) {
        result['type'] = 'rain';
        result['value'] = double.tryParse(data.substring(5)) ?? 0.0;
      } else if (data.startsWith('UMBRELLA:')) {
        result['type'] = 'umbrella';
        result['value'] = data.substring(9).toLowerCase() == 'open';
      } else if (data.startsWith('LOCK:')) {
        result['type'] = 'lock';
        result['value'] = data.substring(5).toLowerCase() == 'locked';
      } else if (data.startsWith('STATUS:')) {
        result['type'] = 'status';
        result['value'] = data.substring(7);
      }
    } catch (e) {
      print('Error parsing data: $e');
    }
    
    return result;
  }
  
  // Send specific commands
  Future<bool> openUmbrella() async {
    return await sendCommand('UMBRELLA_OPEN');
  }
  
  Future<bool> closeUmbrella() async {
    return await sendCommand('UMBRELLA_CLOSE');
  }
  
  Future<bool> lockBag() async {
    return await sendCommand('LOCK_BAG');
  }
  
  Future<bool> unlockBag() async {
    return await sendCommand('UNLOCK_BAG');
  }
  
  Future<bool> getBatteryLevel() async {
    return await sendCommand('GET_BATTERY');
  }
  
  Future<bool> getTemperature() async {
    return await sendCommand('GET_TEMP');
  }
  
  Future<bool> getRainLevel() async {
    return await sendCommand('GET_RAIN');
  }
  
  Future<bool> setAdminPin(String pin) async {
    return await sendCommand('SET_ADMIN_PIN:$pin');
  }
  
  Future<bool> setSmsNumber(String number) async {
    return await sendCommand('SET_SMS:$number');
  }
  
  Future<bool> getStatus() async {
    return await sendCommand('GET_STATUS');
  }
  
  // Dispose resources
  void dispose() {
    disconnect();
    _dataStreamController.close();
  }
}