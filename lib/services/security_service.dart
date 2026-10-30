import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

abstract class SecureStorageInterface {
  Future<String?> read({required String key});
  Future<void> write({required String key, required String? value});
  Future<void> delete({required String key});
  Future<Map<String, String>> readAll();
  Future<void> deleteAll();
}

class FlutterSecureStorageWrapper implements SecureStorageInterface {
  final FlutterSecureStorage _storage;

  const FlutterSecureStorageWrapper([
    this._storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  ]);

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> write({required String key, required String? value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);

  @override
  Future<Map<String, String>> readAll() => _storage.readAll();

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}

class InMemorySecureStorage implements SecureStorageInterface {
  final Map<String, String> _data = {};

  InMemorySecureStorage([Map<String, String>? initialData]) {
    if (initialData != null) {
      _data.addAll(initialData);
    }
  }

  @override
  Future<String?> read({required String key}) async => _data[key];

  @override
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<void> delete({required String key}) async {
    _data.remove(key);
  }

  @override
  Future<Map<String, String>> readAll() async => Map.unmodifiable(_data);

  @override
  Future<void> deleteAll() async {
    _data.clear();
  }
}

class SecurityService {
  static const String keyPinEnabled = 'monance_pin_enabled';
  static const String keyPinSalt = 'monance_pin_salt';
  static const String keyPinHash = 'monance_pin_hash';
  static const String keyBiometricsEnabled = 'monance_biometrics_enabled';

  final SecureStorageInterface _storage;
  final LocalAuthentication _localAuth;

  SecurityService({
    SecureStorageInterface? storage,
    LocalAuthentication? localAuth,
  })  : _storage = storage ?? const FlutterSecureStorageWrapper(),
        _localAuth = localAuth ?? LocalAuthentication();

  /// Validates that PIN is strictly 4 to 6 numeric digits
  static bool isValidPin(String pin) {
    return RegExp(r'^\d{4,6}$').hasMatch(pin);
  }

  /// Generates a cryptographically random 16-byte (32-character hex) salt
  static String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
  }

  /// Computes a keyed HMAC-SHA256 digest of `salt + pin`
  static String hashPin(String salt, String pin) {
    final keyBytes = utf8.encode(salt);
    final messageBytes = utf8.encode(salt + pin);
    final hmac = Hmac(sha256, keyBytes);
    return hmac.convert(messageBytes).toString();
  }

  /// Constant-time byte comparison to protect against timing attacks
  static bool constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  Future<bool> isPinEnabled() async {
    final val = await _storage.read(key: keyPinEnabled);
    return val == 'true';
  }

  Future<bool> isBiometricsEnabled() async {
    final val = await _storage.read(key: keyBiometricsEnabled);
    return val == 'true';
  }

  Future<bool> setupPin(String pin) async {
    if (!isValidPin(pin)) {
      throw ArgumentError('PIN must be 4 to 6 numeric digits');
    }

    final salt = generateSalt();
    final digest = hashPin(salt, pin);

    await _storage.write(key: keyPinSalt, value: salt);
    await _storage.write(key: keyPinHash, value: digest);
    await _storage.write(key: keyPinEnabled, value: 'true');

    return true;
  }

  Future<bool> verifyPin(String pin) async {
    if (!isValidPin(pin)) return false;

    final salt = await _storage.read(key: keyPinSalt);
    final storedHash = await _storage.read(key: keyPinHash);

    if (salt == null || storedHash == null || salt.isEmpty || storedHash.isEmpty) {
      return false;
    }

    final computedHash = hashPin(salt, pin);
    return constantTimeEquals(storedHash, computedHash);
  }

  Future<void> disablePin() async {
    await _storage.write(key: keyPinEnabled, value: 'false');
    await _storage.write(key: keyBiometricsEnabled, value: 'false');
    await _storage.delete(key: keyPinSalt);
    await _storage.delete(key: keyPinHash);
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    await _storage.write(
      key: keyBiometricsEnabled,
      value: enabled ? 'true' : 'false',
    );
  }

  Future<bool> canAuthenticateWithBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics({
    String reason = 'Authenticate to access Monance',
  }) async {
    try {
      final canAuth = await canAuthenticateWithBiometrics();
      if (!canAuth) return false;

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}

