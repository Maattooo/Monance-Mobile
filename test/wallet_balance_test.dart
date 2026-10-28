import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monance_mobile/models/daily_record_model.dart';
import 'package:monance_mobile/models/settings_model.dart';
import 'package:monance_mobile/models/user_model.dart';
import 'package:monance_mobile/providers/records_provider.dart';
import 'package:monance_mobile/providers/settings_provider.dart';
import 'package:monance_mobile/providers/storage_provider.dart';
import 'package:monance_mobile/services/storage_service.dart';
import 'package:monance_mobile/services/sync_service.dart';

class FakeStorageService implements StorageService {
  SettingsModel cachedSettings;
  Map<String, DailyRecordModel> cachedRecords;
  final List<DailyRecordModel> syncQueue = [];

  FakeStorageService({
    SettingsModel? settings,
    Map<String, DailyRecordModel>? records,
  })  : cachedSettings = settings ?? SettingsModel(),
        cachedRecords = records ?? {};

  @override
  SettingsModel getCachedSettings() => cachedSettings;

  @override
  Future<void> setCachedSettings(SettingsModel settings) async {
    cachedSettings = settings;
  }

  @override
  Map<String, DailyRecordModel> getCachedRecords() => cachedRecords;

  @override
  Future<void> setCachedRecords(Map<String, DailyRecordModel> records) async {
    cachedRecords = records;
  }

  @override
  Future<void> addToSyncQueue(DailyRecordModel record) async {
    syncQueue.add(record);
  }

  @override
  List<DailyRecordModel> getPendingSyncQueue() => syncQueue;

  @override
  Future<void> clearSyncQueue() async {
    syncQueue.clear();
  }

  @override
  int getLastSyncTime() => 0;

  @override
  Future<void> setLastSyncTime(int timestamp) async {}

  @override
  Future<void> resetLastSyncTime() async {}

  @override
  UserModel? getCachedUser() => null;

  @override
  Future<void> setCachedUser(UserModel user) async {}

  @override
  Future<void> clearCachedUser() async {}

  @override
  Future<String?> getToken() async => null;

  @override
  Future<void> setToken(String token) async {}

  @override
  Future<void> deleteToken() async {}

  @override
  String getServerUrl() => 'http://localhost';

  @override
  Future<void> setServerUrl(String url) async {}

  @override
  String getThemeMode() => 'dark';

  @override
  Future<void> setThemeMode(String mode) async {}

  @override
  Future<void> clearAllSessionData() async {}
}

class FakeSyncService implements SyncService {
  final List<int?> savedCurrentBalances = [];

  @override
  Future<SyncResult> performSync({bool fullSync = false}) async {
    return SyncResult(success: true);
  }

  @override
  Future<bool> saveSettingsToServer({
    int? defaultAllowance,
    int? goalAmount,
    int? currentBalance,
    String? goalStartDate,
    List<Map<String, dynamic>>? categories,
  }) async {
    if (currentBalance != null) {
      savedCurrentBalances.add(currentBalance);
    }
    return true;
  }
}

void main() {
  group('AUDIT-001: Double Balance Deduction and Derived Balance Verification', () {
    late FakeStorageService fakeStorage;
    late FakeSyncService fakeSync;
    late ProviderContainer container;

    setUp(() {
      fakeStorage = FakeStorageService(
        settings: SettingsModel(
          currentBalance: 10000,
          defaultAllowance: 5000,
        ),
        records: {},
      );
      fakeSync = FakeSyncService();

      container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(fakeStorage),
          syncServiceProvider.overrideWithValue(fakeSync),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('verifies state immutability of settingsProvider and correctness of derived balance', () async {
      final recordsNotifier = container.read(recordsProvider.notifier);

      // 1. Initialize settings with currentBalance = 10000 (100.00 PHP) and an empty records map.
      expect(container.read(settingsProvider).currentBalance, 10000);
      expect(container.read(derivedWalletBalanceProvider), 10000);

      // 2. Add a wallet deduction expense of 2500 (25.00 PHP).
      const testDate = '2026-09-06';
      await recordsNotifier.addExpense(
        date: testDate,
        amount: 2500,
        title: 'Lunch',
        category: 'Food',
        deductionType: 'wallet',
      );

      // - Verify settingsProvider.state.currentBalance is STILL 10000 (not 7500).
      expect(
        container.read(settingsProvider).currentBalance,
        10000,
        reason: 'settingsProvider.state.currentBalance must NOT be mutated when logging wallet expenses',
      );

      // - Verify server sync was NOT called with currentBalance
      expect(
        fakeSync.savedCurrentBalances,
        isEmpty,
        reason: '_syncService.saveSettingsToServer should not be called with currentBalance on expense logging',
      );

      // - Verify the derived wallet balance equals 7500.
      expect(
        container.read(derivedWalletBalanceProvider),
        7500,
        reason: 'derivedWalletBalanceProvider should dynamically calculate 10000 - 2500 = 7500',
      );

      // 3. Delete the wallet expense.
      final record = container.read(recordsProvider)[testDate]!;
      final expenseId = record.expenses.first.id;
      await recordsNotifier.deleteExpense(testDate, expenseId);

      // - Verify settingsProvider.state.currentBalance is STILL 10000.
      expect(
        container.read(settingsProvider).currentBalance,
        10000,
        reason: 'settingsProvider.state.currentBalance must remain 10000 after deleting expense',
      );

      // - Verify the derived wallet balance returns to 10000.
      expect(
        container.read(derivedWalletBalanceProvider),
        10000,
        reason: 'derivedWalletBalanceProvider should return to 10000 after deleting expense',
      );

      // 4. Mark a day with wallet expenses as a rest day.
      await recordsNotifier.addExpense(
        date: '2026-09-07',
        amount: 2500,
        title: 'Books',
        category: 'School',
        deductionType: 'wallet',
      );
      expect(container.read(derivedWalletBalanceProvider), 7500);

      await recordsNotifier.markRestDay('2026-09-07');

      // - Verify settingsProvider.state.currentBalance is STILL 10000.
      expect(
        container.read(settingsProvider).currentBalance,
        10000,
        reason: 'settingsProvider.state.currentBalance must remain 10000 after marking rest day',
      );

      // - Verify derived balance returns to 10000 since rest day is deleted / zeroed
      expect(
        container.read(derivedWalletBalanceProvider),
        10000,
        reason: 'derivedWalletBalanceProvider should be 10000 because rest day has no active expenses',
      );
    });

    test('verifies non-allowance day (startingMoney: 0) derived balance deduction', () async {
      final recordsNotifier = container.read(recordsProvider.notifier);

      // Initial state: settings.currentBalance = 10000 (100.00 PHP)
      expect(container.read(settingsProvider).currentBalance, 10000);
      expect(container.read(derivedWalletBalanceProvider), 10000);

      // Initialize a non-allowance day with startingMoney: 0
      const nonAllowanceDate = '2026-09-08';
      await recordsNotifier.updateStartingMoney(nonAllowanceDate, 0);

      final recordBeforeExpense = container.read(recordsProvider)[nonAllowanceDate]!;
      expect(recordBeforeExpense.startingMoney, 0);

      // Add an expense of 1500 (15.00 PHP)
      await recordsNotifier.addExpense(
        date: nonAllowanceDate,
        amount: 1500,
        title: 'Snack',
        category: 'Food',
        deductionType: 'daily',
      );

      // - Verify settingsProvider.state.currentBalance is STILL 10000
      expect(
        container.read(settingsProvider).currentBalance,
        10000,
        reason: 'settingsProvider.state.currentBalance must remain unmodified on non-allowance day expense',
      );

      // - Verify server sync was NOT called with currentBalance
      expect(
        fakeSync.savedCurrentBalances,
        isEmpty,
        reason: '_syncService.saveSettingsToServer should not be called with currentBalance',
      );

      // - Verify derived balance evaluates to 8500 (10000 - 1500)
      expect(
        container.read(derivedWalletBalanceProvider),
        8500,
        reason: 'derivedWalletBalanceProvider should evaluate to 8500 cents (10000 - 1500) on non-allowance day',
      );

      // Verify that a wallet-type expense on non-allowance day also behaves correctly
      await recordsNotifier.addExpense(
        date: nonAllowanceDate,
        amount: 1000,
        title: 'Coffee',
        category: 'Food',
        deductionType: 'wallet',
      );

      expect(container.read(settingsProvider).currentBalance, 10000);
      expect(container.read(derivedWalletBalanceProvider), 7500);
    });
  });
}

