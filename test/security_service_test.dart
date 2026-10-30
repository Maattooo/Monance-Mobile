import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:monance_mobile/services/security_service.dart';
import 'package:monance_mobile/providers/security_provider.dart';

class FakeLocalAuthentication extends LocalAuthentication {
  final bool shouldThrow;
  final bool canAuthenticate;
  final bool authSuccess;

  FakeLocalAuthentication({
    this.shouldThrow = false,
    this.canAuthenticate = true,
    this.authSuccess = true,
  });

  @override
  Future<bool> get canCheckBiometrics async {
    if (shouldThrow) throw Exception('Hardware biometric error');
    return canAuthenticate;
  }

  @override
  Future<bool> isDeviceSupported() async {
    if (shouldThrow) throw Exception('Device unsupported error');
    return canAuthenticate;
  }

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<dynamic>? authMessages,
    AuthenticationOptions? options,
  }) async {
    if (shouldThrow) throw Exception('Biometric authentication crashed');
    return authSuccess;
  }
}

void main() {
  group('test/security_service_test.dart (Offline Security & Biometrics)', () {
    late InMemorySecureStorage storage;

    setUp(() {
      storage = InMemorySecureStorage();
    });

    test('Default disabled state: Fresh SecurityService / securityProvider', () async {
      final service = SecurityService(storage: storage);
      final container = ProviderContainer(
        overrides: [
          securityServiceProvider.overrideWithValue(service),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(securityProvider.notifier);
      await notifier.init();

      final state = container.read(securityProvider);
      expect(state.isPinEnabled, isFalse);
      expect(state.isBiometricsEnabled, isFalse);
      expect(state.isLocked, isFalse);
    });

    test('PIN validation & cryptographic hashing', () async {
      final service = SecurityService(storage: storage);

      // Rejects invalid PINs
      expect(SecurityService.isValidPin('123'), isFalse);
      expect(SecurityService.isValidPin('1234567'), isFalse);
      expect(SecurityService.isValidPin('12a4'), isFalse);
      expect(SecurityService.isValidPin('abcd'), isFalse);
      expect(SecurityService.isValidPin(''), isFalse);
      expect(() => service.setupPin('123'), throwsArgumentError);
      expect(() => service.setupPin('1234567'), throwsArgumentError);
      expect(() => service.setupPin('12a4'), throwsArgumentError);

      // Accepts 4-digit PIN ('1234')
      final setup4 = await service.setupPin('1234');
      expect(setup4, isTrue);

      final allData = await storage.readAll();
      expect(allData[SecurityService.keyPinEnabled], equals('true'));

      final salt = allData[SecurityService.keyPinSalt];
      expect(salt, isNotNull);
      expect(salt!.length, equals(32)); // 16 bytes = 32 hex chars
      expect(RegExp(r'^[0-9a-f]{32}$').hasMatch(salt), isTrue);

      final hash = allData[SecurityService.keyPinHash];
      expect(hash, isNotNull);
      expect(hash!.isNotEmpty, isTrue);
      expect(hash, isNot(equals('1234')));

      // Accepts 6-digit PIN ('654321')
      final setup6 = await service.setupPin('654321');
      expect(setup6, isTrue);
      final hash6 = await storage.read(key: SecurityService.keyPinHash);
      expect(hash6, isNotNull);
      expect(hash6, isNot(equals(hash)));
      expect(hash6, isNot(equals('654321')));
    });

    test('Cold-start lock & verification', () async {
      // 1. Setup PIN '1234'
      final service1 = SecurityService(storage: storage);
      await service1.setupPin('1234');

      // 2. Re-initialize provider simulating cold start
      final service2 = SecurityService(storage: storage);
      final container = ProviderContainer(
        overrides: [
          securityServiceProvider.overrideWithValue(service2),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(securityProvider.notifier);
      await notifier.init();

      // State must gate app (isLocked == true)
      expect(container.read(securityProvider).isLocked, isTrue);
      expect(container.read(securityProvider).isPinEnabled, isTrue);

      // Verifying incorrect PIN '9999' returns false and leaves app locked
      final wrongVerify = await notifier.verifyPin('9999');
      expect(wrongVerify, isFalse);
      expect(container.read(securityProvider).isLocked, isTrue);

      // Verifying correct PIN '1234' returns true and unlocks app
      final correctVerify = await notifier.verifyPin('1234');
      expect(correctVerify, isTrue);
      expect(container.read(securityProvider).isLocked, isFalse);
    });

    test('Disable PIN & biometric fallback resilience', () async {
      final fakeAuth = FakeLocalAuthentication(shouldThrow: true);
      final service = SecurityService(
        storage: storage,
        localAuth: fakeAuth,
      );

      final container = ProviderContainer(
        overrides: [
          securityServiceProvider.overrideWithValue(service),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(securityProvider.notifier);
      await notifier.setupPin('1234');
      await notifier.toggleBiometrics(true);

      expect(container.read(securityProvider).isPinEnabled, isTrue);
      expect(container.read(securityProvider).isBiometricsEnabled, isTrue);

      // Disable PIN clears credentials and resets lock
      await notifier.disablePin();

      final state = container.read(securityProvider);
      expect(state.isPinEnabled, isFalse);
      expect(state.isBiometricsEnabled, isFalse);
      expect(state.isLocked, isFalse);

      final raw = await storage.readAll();
      expect(raw[SecurityService.keyPinEnabled], equals('false'));
      expect(raw[SecurityService.keyBiometricsEnabled], equals('false'));
      expect(raw[SecurityService.keyPinSalt], isNull);
      expect(raw[SecurityService.keyPinHash], isNull);

      // Simulated biometric failure / exception returns false gracefully without throwing
      final bioSuccess = await notifier.authenticateWithBiometrics();
      expect(bioSuccess, isFalse);
    });

    test('Adversarial: Constant-time comparison & corrupted storage resilience', () async {
      final service = SecurityService(storage: storage);

      // Constant time equality checks
      expect(SecurityService.constantTimeEquals('abcdef', 'abcdef'), isTrue);
      expect(SecurityService.constantTimeEquals('abcdef', 'abcdeg'), isFalse);
      expect(SecurityService.constantTimeEquals('abcdef', 'abcde'), isFalse);
      expect(SecurityService.constantTimeEquals('', ''), isTrue);

      // Corrupted storage: salt present, hash missing
      await storage.write(key: SecurityService.keyPinSalt, value: 'abcd1234abcd1234abcd1234abcd1234');
      await storage.write(key: SecurityService.keyPinHash, value: null);
      expect(await service.verifyPin('1234'), isFalse);

      // Lock app behavior
      final container = ProviderContainer(
        overrides: [
          securityServiceProvider.overrideWithValue(service),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(securityProvider.notifier);
      // When PIN is disabled, lockApp does nothing
      notifier.lockApp();
      expect(container.read(securityProvider).isLocked, isFalse);

      // When PIN is enabled, lockApp locks
      await notifier.setupPin('1234');
      notifier.lockApp();
      expect(container.read(securityProvider).isLocked, isTrue);
    });
  });
}
