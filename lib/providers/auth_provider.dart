import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'storage_provider.dart';
import 'settings_provider.dart';
import 'records_provider.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final StorageService _storageService;
  final Ref _ref;

  AuthNotifier(this._authService, this._storageService, this._ref)
      : super(const AuthState()) {
    // Configure 401 callback from ApiClient
    _ref.read(apiClientProvider).onUnauthorized = () {
      logout();
    };
    checkSession();
  }

  /// Checks existing stored JWT and user on app launch
  Future<void> checkSession() async {
    state = state.copyWith(status: AuthStatus.loading);
    final token = await _storageService.getToken();
    final cachedUser = _storageService.getCachedUser();

    if (token == null || token.isEmpty) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    if (cachedUser != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: cachedUser,
      );
    }

    // Verify session with server in background
    try {
      final res = await _authService.fetchMe();
      if (res.success && res.user != null) {
        await _storageService.setCachedUser(res.user!);
        if (res.settings != null) {
          _ref.read(settingsProvider.notifier).loadSettings(res.settings!);
        }
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: res.user,
        );
        // Pull existing data from MongoDB
        final lastSync = _storageService.getLastSyncTime();
        if (lastSync == 0 || _storageService.getCachedRecords().isEmpty) {
          await _ref.read(recordsProvider.notifier).forceResyncFromCloud();
        } else {
          await _ref.read(recordsProvider.notifier).triggerSync();
        }
      } else {
        // Token expired or invalid
        await _storageService.deleteToken();
        await _storageService.clearCachedUser();
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      // Offline fallback: If we had a cached user and token, allow offline access
      if (cachedUser != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: cachedUser);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final res = await _authService.login(email: email, password: password);

    if (res.success && res.token != null && res.user != null) {
      await _storageService.setToken(res.token!);
      await _storageService.setCachedUser(res.user!);
      await _storageService.resetLastSyncTime(); // Fresh login pulls full cloud data
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: res.user,
      );
      // Fetch full settings and records
      await checkSession();
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: res.errorMessage ?? 'Login failed',
      );
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final res = await _authService.register(email: email, password: password);

    if (res.success && res.token != null && res.user != null) {
      await _storageService.setToken(res.token!);
      await _storageService.setCachedUser(res.user!);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: res.user,
      );
      await checkSession();
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: res.errorMessage ?? 'Registration failed',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _storageService.clearAllSessionData();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthNotifier(authService, storageService, ref);
});
