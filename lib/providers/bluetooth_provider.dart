import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';

class BluetoothProvider extends ChangeNotifier {
  FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _controlCharacteristic;
  BluetoothCharacteristic? _dataCharacteristic;
  
  bool _isScanning = false;
  bool _isConnected = false;
  List<ScanResult> _scanResults = [];
  
  // Smart bag data
  int _batteryLevel = 0;
  double _temperature = 0.0;
  int _rainLevel = 0;
  bool _umbrellaOpen = false;
  String _smsNumber = '';
  String _adminPin = '';

  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  List<ScanResult> get scanResults => _scanResults;
  int get batteryLevel => _batteryLevel;
  double get temperature => _temperature;
  int get rainLevel => _rainLevel;
  bool get umbrellaOpen => _umbrellaOpen;
  String get smsNumber => _smsNumber;
  String get adminPin => _adminPin;

  BluetoothProvider() {
    _initializeBluetooth();
  }

  void _initializeBluetooth() {
    _flutterBlue.isScanning.listen((scanning) {
      _isScanning = scanning;
      notifyListeners();
    });
  }

  Future<void> startScan() async {
    try {
      _scanResults.clear();
      notifyListeners();
      
      await _flutterBlue.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: true,
      );
    } catch (e) {
      debugPrint('Error starting scan: $e');
    }
  }

  Future<void> stopScan() async {
    try {
      await _flutterBlue.stopScan();
    } catch (e) {
      debugPrint('Error stopping scan: $e');
    }
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 10));
      _connectedDevice = device;
      _isConnected = true;
      
      // Discover services
      List<BluetoothService> services = await device.discoverServices();
      
      for (BluetoothService service in services) {
        if (service.uuid.toString().toUpperCase().contains('FFE0')) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toUpperCase().contains('FFE1')) {
              _controlCharacteristic = characteristic;
              _dataCharacteristic = characteristic;
              
              // Subscribe to notifications
              await characteristic.setNotifyValue(true);
              characteristic.value.listen((value) {
                _handleReceivedData(value);
              });
              
              break;
            }
          }
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error connecting to device: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
      }
      _connectedDevice = null;
      _isConnected = false;
      _controlCharacteristic = null;
      _dataCharacteristic = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error disconnecting: $e');
    }
  }

  void _handleReceivedData(List<int> data) {
    try {
      String message = utf8.decode(data);
      Map<String, dynamic> jsonData = json.decode(message);
      
      if (jsonData.containsKey('battery')) {
        _batteryLevel = jsonData['battery'];
      }
      if (jsonData.containsKey('temperature')) {
        _temperature = jsonData['temperature'].toDouble();
      }
      if (jsonData.containsKey('rain')) {
        _rainLevel = jsonData['rain'];
      }
      if (jsonData.containsKey('umbrella')) {
        _umbrellaOpen = jsonData['umbrella'];
      }
      if (jsonData.containsKey('sms')) {
        _smsNumber = jsonData['sms'];
      }
      if (jsonData.containsKey('pin')) {
        _adminPin = jsonData['pin'];
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error parsing received data: $e');
    }
  }

  Future<bool> sendCommand(String command) async {
    if (_controlCharacteristic == null || !_isConnected) {
      return false;
    }
    
    try {
      List<int> data = utf8.encode(command);
      await _controlCharacteristic!.write(data);
      return true;
    } catch (e) {
      debugPrint('Error sending command: $e');
      return false;
    }
  }

  Future<bool> toggleUmbrella() async {
    String command = _umbrellaOpen ? 'CLOSE_UMBRELLA' : 'OPEN_UMBRELLA';
    bool success = await sendCommand(command);
    if (success) {
      _umbrellaOpen = !_umbrellaOpen;
      notifyListeners();
    }
    return success;
  }

  Future<bool> updateAdminPin(String newPin) async {
    String command = 'SET_PIN:$newPin';
    return await sendCommand(command);
  }

  Future<bool> updateSmsNumber(String newNumber) async {
    String command = 'SET_SMS:$newNumber';
    return await sendCommand(command);
  }

  Future<bool> requestData() async {
    return await sendCommand('GET_DATA');
  }

  void updateScanResults(List<ScanResult> results) {
    _scanResults = results;
    notifyListeners();
  }
}