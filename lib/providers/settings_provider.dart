import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _autoConnect = false;
  String _lastConnectedDevice = '';
  bool _notificationsEnabled = true;
  int _refreshInterval = 5; // seconds

  bool get isDarkMode => _isDarkMode;
  bool get autoConnect => _autoConnect;
  String get lastConnectedDevice => _lastConnectedDevice;
  bool get notificationsEnabled => _notificationsEnabled;
  int get refreshInterval => _refreshInterval;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _autoConnect = prefs.getBool('auto_connect') ?? false;
      _lastConnectedDevice = prefs.getString('last_device') ?? '';
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _refreshInterval = prefs.getInt('refresh_interval') ?? 5;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    notifyListeners();
  }

  Future<void> setAutoConnect(bool value) async {
    _autoConnect = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_connect', value);
    notifyListeners();
  }

  Future<void> setLastConnectedDevice(String deviceId) async {
    _lastConnectedDevice = deviceId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_device', deviceId);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
    notifyListeners();
  }

  Future<void> setRefreshInterval(int seconds) async {
    _refreshInterval = seconds;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('refresh_interval', seconds);
    notifyListeners();
  }

  Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _loadSettings();
  }
}