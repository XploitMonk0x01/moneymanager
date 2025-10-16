import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException {
      return false;
    }
  }

  /// Get available biometric types (fingerprint, face, iris)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Authenticate user with biometrics
  /// Returns true if authentication was successful, false otherwise
  Future<bool> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final bool canAuthenticate = await isBiometricAvailable();

      if (!canAuthenticate) {
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: false, // Allow PIN/Pattern as fallback
        ),
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      // Handle specific errors
      if (e.code == 'NotAvailable') {
        // Biometric not available on device
        return false;
      } else if (e.code == 'NotEnrolled') {
        // User hasn't enrolled biometrics
        return false;
      } else if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        // Too many failed attempts
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Authenticate before editing a record
  Future<bool> authenticateForEdit() async {
    return await authenticate(
      reason: 'Authenticate to edit this record',
    );
  }

  /// Authenticate before deleting a record
  Future<bool> authenticateForDelete() async {
    return await authenticate(
      reason: 'Authenticate to delete this record',
    );
  }

  /// Authenticate before performing critical actions
  Future<bool> authenticateForCriticalAction(String action) async {
    return await authenticate(
      reason: 'Authenticate to $action',
    );
  }

  /// Get biometric status message for UI
  Future<String> getBiometricStatusMessage() async {
    try {
      final bool canAuthenticate = await isBiometricAvailable();

      if (!canAuthenticate) {
        return 'Biometric authentication not available';
      }

      final List<BiometricType> availableBiometrics =
          await getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        return 'No biometric enrolled';
      }

      if (availableBiometrics.contains(BiometricType.face)) {
        return 'Face ID available';
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return 'Fingerprint available';
      } else if (availableBiometrics.contains(BiometricType.iris)) {
        return 'Iris scan available';
      } else {
        return 'Biometric available';
      }
    } catch (e) {
      return 'Biometric status unknown';
    }
  }
}
