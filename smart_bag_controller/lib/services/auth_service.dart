import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/services.dart';

class AuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  // Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (e) {
      print('Error checking biometric availability: $e');
      return false;
    }
  }
  
  // Get available biometrics
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }
  
  // Authenticate with fingerprint
  Future<bool> authenticateWithFingerprint({String? reason}) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason ?? 'Please authenticate to access smart bag controls',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      
      return didAuthenticate;
    } on PlatformException catch (e) {
      print('Error during fingerprint authentication: $e');
      
      switch (e.code) {
        case auth_error.notAvailable:
          print('Biometric authentication not available');
          break;
        case auth_error.notEnrolled:
          print('No biometrics enrolled');
          break;
        case auth_error.passcodeNotSet:
          print('No passcode set');
          break;
        case auth_error.permanentlyLocked:
          print('Biometric authentication permanently locked');
          break;
        case auth_error.lockedOut:
          print('Biometric authentication temporarily locked');
          break;
        default:
          print('Unknown authentication error: ${e.code}');
      }
      
      return false;
    }
  }
  
  // Check if fingerprint is enrolled
  Future<bool> isFingerprintEnrolled() async {
    try {
      final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.contains(BiometricType.fingerprint);
    } on PlatformException catch (e) {
      print('Error checking fingerprint enrollment: $e');
      return false;
    }
  }
  
  // Authenticate for bag unlock
  Future<bool> authenticateForBagUnlock() async {
    return await authenticateWithFingerprint(
      reason: 'Authenticate to unlock your smart bag'
    );
  }
  
  // Authenticate for admin access
  Future<bool> authenticateForAdminAccess() async {
    return await authenticateWithFingerprint(
      reason: 'Authenticate for admin access'
    );
  }
  
  // Authenticate for umbrella control
  Future<bool> authenticateForUmbrellaControl() async {
    return await authenticateWithFingerprint(
      reason: 'Authenticate to control umbrella'
    );
  }
  
  // Check if device has fingerprint hardware
  Future<bool> hasFingerprintHardware() async {
    try {
      final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.contains(BiometricType.fingerprint);
    } on PlatformException catch (e) {
      print('Error checking fingerprint hardware: $e');
      return false;
    }
  }
  
  // Get authentication status
  Future<Map<String, bool>> getAuthenticationStatus() async {
    return {
      'biometricAvailable': await isBiometricAvailable(),
      'fingerprintEnrolled': await isFingerprintEnrolled(),
      'hasFingerprintHardware': await hasFingerprintHardware(),
    };
  }
}