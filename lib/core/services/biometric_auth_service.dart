import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

import '../utils/app_logger.dart';

/// Service for handling hardware biometric authentication (Face ID / Touch ID / Fingerprint).
@lazySingleton
class BiometricAuthService {
  final LocalAuthentication _localAuth;

  BiometricAuthService([LocalAuthentication? localAuth])
      : _localAuth = localAuth ?? LocalAuthentication();

  /// Check whether biometrics hardware is available and biometrics are enrolled on this device.
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } on PlatformException catch (e) {
      AppLogger.e('Error checking biometric availability: ${e.message}', e);
      return false;
    } catch (e) {
      AppLogger.e('Unexpected error checking biometric availability', e);
      return false;
    }
  }

  /// Get list of available hardware biometric types enrolled on the device.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      AppLogger.e('Error getting available biometrics: ${e.message}', e);
      return <BiometricType>[];
    } catch (e) {
      AppLogger.e('Unexpected error getting available biometrics', e);
      return <BiometricType>[];
    }
  }

  /// Trigger biometric authentication prompt.
  ///
  /// Returns `true` if authentication succeeded, `false` otherwise.
  Future<bool> authenticate({
    required String localizedReason,
    bool useErrorDialogs = true,
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        AppLogger.w(
            'Biometrics authentication attempted but biometrics unavailable.');
        return false;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: useErrorDialogs,
        ),
      );

      AppLogger.i('Biometric authentication result: $didAuthenticate');
      return didAuthenticate;
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        AppLogger.w('Biometrics not available: ${e.message}');
      } else if (e.code == auth_error.notEnrolled) {
        AppLogger.w('No biometrics enrolled on device: ${e.message}');
      } else if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        AppLogger.w('Biometrics locked out: ${e.message}');
      } else {
        AppLogger.e(
            'PlatformException during biometric auth: ${e.code} - ${e.message}',
            e);
      }
      return false;
    } catch (e) {
      AppLogger.e('Unexpected error during biometric authentication', e);
      return false;
    }
  }
}
