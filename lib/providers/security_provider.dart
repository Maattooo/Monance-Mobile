import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/security_service.dart';

class SecurityState {
  final bool isPinEnabled;
  final bool isBiometricsEnabled;
  final bool isLocked;
  final bool isInitialized;

  const SecurityState({
    this.isPinEnabled = false,
    this.isBiometricsEnabled = false,
    this.isLocked = false,
    this.isInitialized = false,
  });

  SecurityState copyWith({
    bool? isPinEnabled,
    bool? isBiometricsEnabled,
    bool? isLocked,
    bool? isInitialized,
  }) {
    return SecurityState(
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
      isLocked: isLocked ?? this.isLocked,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class SecurityNotifier extends StateNotifier<SecurityState> {
  final SecurityService _securityService;

  SecurityNotifier(this._securityService) : super(const SecurityState()) {
    init();
  }

  Future<void> init() async {
    final pinEnabled = await _securityService.isPinEnabled();
    final bioEnabled = await _securityService.isBiometricsEnabled();
    state = state.copyWith(
      isPinEnabled: pinEnabled,
      isBiometricsEnabled: bioEnabled,
      isLocked: pinEnabled,
      isInitialized: true,
    );
  }

  Future<bool> setupPin(String pin) async {
    final success = await _securityService.setupPin(pin);
    if (success) {
      state = state.copyWith(
        isPinEnabled: true,
        isLocked: false,
      );
    }
    return success;
  }

  Future<bool> verifyPin(String pin) async {
    final matches = await _securityService.verifyPin(pin);
    if (matches) {
      state = state.copyWith(isLocked: false);
      return true;
    }
    return false;
  }

  Future<void> disablePin() async {
    await _securityService.disablePin();
    state = state.copyWith(
      isPinEnabled: false,
      isBiometricsEnabled: false,
      isLocked: false,
    );
  }

  Future<void> toggleBiometrics([bool? enabled]) async {
    final target = enabled ?? !state.isBiometricsEnabled;
    await _securityService.setBiometricsEnabled(target);
    state = state.copyWith(isBiometricsEnabled: target);
  }

  Future<bool> authenticateWithBiometrics({
    String reason = 'Authenticate to access Monance',
  }) async {
    final authenticated =
        await _securityService.authenticateWithBiometrics(reason: reason);
    if (authenticated) {
      state = state.copyWith(isLocked: false);
      return true;
    }
    return false;
  }

  void lockApp() {
    if (state.isPinEnabled) {
      state = state.copyWith(isLocked: true);
    }
  }
}

final securityServiceProvider = Provider<SecurityService>((ref) {
  return SecurityService();
});

final securityProvider =
    StateNotifierProvider<SecurityNotifier, SecurityState>((ref) {
  final service = ref.watch(securityServiceProvider);
  return SecurityNotifier(service);
});

