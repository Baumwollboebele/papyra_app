import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

/// Device biometric / passcode gate. Abstracted so the UI and controllers can
/// be tested without a real device.
abstract interface class AppLockService {
  /// Whether the device can perform any local authentication.
  Future<bool> isAvailable();

  /// Prompts for Face ID / fingerprint / device passcode.
  /// Returns true on success, false on failure or cancellation.
  Future<bool> authenticate(String localizedReason);
}

class LocalAuthAppLockService implements AppLockService {
  LocalAuthAppLockService([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      return await _auth.canCheckBiometrics || supported;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String localizedReason) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}

/// Always-available, always-succeeds fake for tests and previews.
class FakeAppLockService implements AppLockService {
  FakeAppLockService({this.available = true, this.succeeds = true});
  final bool available;
  final bool succeeds;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate(String localizedReason) async => succeeds;
}

final appLockServiceProvider = Provider<AppLockService>(
  (ref) => LocalAuthAppLockService(),
);
