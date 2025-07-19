import 'package:flutter/material.dart';

class BagStateProvider extends ChangeNotifier {
  // Connection status
  bool _isConnected = false;
  bool _isConnecting = false;
  String _connectionStatus = 'Disconnected';
  
  // Bag status
  double _batteryLevel = 0.0;
  double _temperature = 0.0;
  double _rainLevel = 0.0;
  bool _umbrellaOpen = false;
  bool _bagLocked = true;
  
  // Admin settings
  String _adminPin = '';
  String _smsNumber = '';
  bool _isAdminMode = false;
  
  // Fingerprint status
  bool _fingerprintEnabled = false;
  bool _fingerprintAuthenticated = false;
  
  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String get connectionStatus => _connectionStatus;
  double get batteryLevel => _batteryLevel;
  double get temperature => _temperature;
  double get rainLevel => _rainLevel;
  bool get umbrellaOpen => _umbrellaOpen;
  bool get bagLocked => _bagLocked;
  String get adminPin => _adminPin;
  String get smsNumber => _smsNumber;
  bool get isAdminMode => _isAdminMode;
  bool get fingerprintEnabled => _fingerprintEnabled;
  bool get fingerprintAuthenticated => _fingerprintAuthenticated;
  
  // Setters
  void setConnectionStatus(bool connected, {String? status}) {
    _isConnected = connected;
    _connectionStatus = status ?? (connected ? 'Connected' : 'Disconnected');
    notifyListeners();
  }
  
  void setConnecting(bool connecting) {
    _isConnecting = connecting;
    notifyListeners();
  }
  
  void updateBatteryLevel(double level) {
    _batteryLevel = level;
    notifyListeners();
  }
  
  void updateTemperature(double temp) {
    _temperature = temp;
    notifyListeners();
  }
  
  void updateRainLevel(double level) {
    _rainLevel = level;
    notifyListeners();
  }
  
  void toggleUmbrella() {
    _umbrellaOpen = !_umbrellaOpen;
    notifyListeners();
  }
  
  void setUmbrellaState(bool open) {
    _umbrellaOpen = open;
    notifyListeners();
  }
  
  void toggleBagLock() {
    _bagLocked = !_bagLocked;
    notifyListeners();
  }
  
  void setBagLockState(bool locked) {
    _bagLocked = locked;
    notifyListeners();
  }
  
  void setAdminPin(String pin) {
    _adminPin = pin;
    notifyListeners();
  }
  
  void setSmsNumber(String number) {
    _smsNumber = number;
    notifyListeners();
  }
  
  void setAdminMode(bool adminMode) {
    _isAdminMode = adminMode;
    notifyListeners();
  }
  
  void setFingerprintEnabled(bool enabled) {
    _fingerprintEnabled = enabled;
    notifyListeners();
  }
  
  void setFingerprintAuthenticated(bool authenticated) {
    _fingerprintAuthenticated = authenticated;
    notifyListeners();
  }
  
  // Reset all states
  void reset() {
    _isConnected = false;
    _isConnecting = false;
    _connectionStatus = 'Disconnected';
    _batteryLevel = 0.0;
    _temperature = 0.0;
    _rainLevel = 0.0;
    _umbrellaOpen = false;
    _bagLocked = true;
    _isAdminMode = false;
    _fingerprintAuthenticated = false;
    notifyListeners();
  }
}