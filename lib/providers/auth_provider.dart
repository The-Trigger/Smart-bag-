import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _isFingerprintAvailable = false;
  String _adminPin = '';
  bool _isPinSet = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isFingerprintAvailable => _isFingerprintAvailable;
  bool get isPinSet => _isPinSet;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      _isFingerprintAvailable = await _localAuth.canCheckBiometrics;
      await _loadAdminPin();
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    }
  }

  Future<void> _loadAdminPin() async {
    final prefs = await SharedPreferences.getInstance();
    _adminPin = prefs.getString('admin_pin') ?? '';
    _isPinSet = _adminPin.isNotEmpty;
  }

  Future<bool> authenticateWithFingerprint() async {
    try {
      if (!_isFingerprintAvailable) {
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access Smart Bag Control',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      _isAuthenticated = didAuthenticate;
      notifyListeners();
      return didAuthenticate;
    } catch (e) {
      debugPrint('Fingerprint authentication error: $e');
      return false;
    }
  }

  Future<bool> authenticateWithPin(String pin) async {
    if (_adminPin.isEmpty) {
      return false;
    }
    
    _isAuthenticated = pin == _adminPin;
    notifyListeners();
    return _isAuthenticated;
  }

  Future<bool> setAdminPin(String newPin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_pin', newPin);
      _adminPin = newPin;
      _isPinSet = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error setting admin PIN: $e');
      return false;
    }
  }

  Future<bool> changeAdminPin(String currentPin, String newPin) async {
    if (currentPin != _adminPin) {
      return false;
    }
    
    return await setAdminPin(newPin);
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }
}