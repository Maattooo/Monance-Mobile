import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_model.dart';
import '../models/category_model.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';
import 'storage_provider.dart';

class SettingsNotifier extends StateNotifier<SettingsModel> {
  final StorageService _storageService;
  final SyncService _syncService;

  SettingsNotifier(this._storageService, this._syncService)
      : super(_storageService.getCachedSettings());

  void loadSettings(SettingsModel settings) {
    state = settings;
    _storageService.setCachedSettings(settings);
  }

  Future<void> updateAllowance(int centavos) async {
    state = state.copyWith(defaultAllowance: centavos);
    await _storageService.setCachedSettings(state);
    _syncService.saveSettingsToServer(defaultAllowance: centavos);
  }

  Future<void> updateGoalAmount(int centavos) async {
    state = state.copyWith(goalAmount: centavos);
    await _storageService.setCachedSettings(state);
    _syncService.saveSettingsToServer(goalAmount: centavos);
  }

  Future<void> updateCurrentBalance(int centavos) async {
    state = state.copyWith(currentBalance: centavos);
    await _storageService.setCachedSettings(state);
    _syncService.saveSettingsToServer(currentBalance: centavos);
  }

  /// Deprecated: Routine expense deductions must not directly mutate base settings balance.
  /// Use [derivedWalletBalanceProvider] from `records_provider.dart` instead.
  @Deprecated('Use derivedWalletBalanceProvider from records_provider.dart instead. Routine expense operations must not mutate base currentBalance.')
  Future<void> deductFromWallet(int centavos) async {
    final newBal = (state.currentBalance - centavos).clamp(0, 9999999900);
    state = state.copyWith(currentBalance: newBal);
    await _storageService.setCachedSettings(state);
    _syncService.saveSettingsToServer(currentBalance: newBal);
  }

  /// Deprecated: Routine expense deductions must not directly mutate base settings balance.
  /// Use [derivedWalletBalanceProvider] from `records_provider.dart` instead.
  @Deprecated('Use derivedWalletBalanceProvider from records_provider.dart instead. Routine expense operations must not mutate base currentBalance.')
  Future<void> addToWallet(int centavos) async {
    final newBal = state.currentBalance + centavos;
    state = state.copyWith(currentBalance: newBal);
    await _storageService.setCachedSettings(state);
    _syncService.saveSettingsToServer(currentBalance: newBal);
  }


  Future<void> addCategory(String name, String hexColor) async {
    final updated = List<CategoryModel>.from(state.categories)
      ..add(CategoryModel(name: name, colorHex: hexColor));
    state = state.copyWith(categories: updated);
    await _storageService.setCachedSettings(state);
    _syncService.saveSettingsToServer(
      categories: updated.map((c) => c.toJson()).toList(),
    );
  }

  Future<void> deleteCategory(String name) async {
    final updated = state.categories.where((c) => c.name != name).toList();
    state = state.copyWith(categories: updated);
    await _storageService.setCachedSettings(state);
    _syncService.saveSettingsToServer(
      categories: updated.map((c) => c.toJson()).toList(),
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsModel>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final syncService = ref.watch(syncServiceProvider);
  return SettingsNotifier(storage, syncService);
});
