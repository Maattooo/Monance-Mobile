import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/daily_record_model.dart';
import '../models/expense_model.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';
import 'storage_provider.dart';
import 'settings_provider.dart';

class RecordsNotifier extends StateNotifier<Map<String, DailyRecordModel>> {
  final StorageService _storageService;
  final SyncService _syncService;
  final Ref _ref;
  bool isSyncing = false;

  RecordsNotifier(this._storageService, this._syncService, this._ref)
      : super(_storageService.getCachedRecords());

  static String getTodayKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  /// Gets existing record for a date or initializes it with default allowance
  DailyRecordModel getOrCreateRecord(String date) {
    if (state.containsKey(date) && !state[date]!.isDeleted) {
      return state[date]!;
    }
    final defaultAllowance = _ref.read(settingsProvider).defaultAllowance;
    final newRecord = DailyRecordModel(
      date: date,
      title: 'school',
      startingMoney: defaultAllowance,
      expenses: [],
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    return newRecord;
  }

  Future<void> addExpense({
    required String date,
    required int amount,
    required String title,
    required String category,
    required String deductionType, // 'daily' or 'wallet'
  }) async {
    final existing = getOrCreateRecord(date);
    final expense = ExpenseModel(
      id: 'exp_${DateTime.now().millisecondsSinceEpoch}_${(amount % 1000)}',
      amount: amount,
      title: title.trim(),
      category: category,
      deductionType: deductionType,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    final updatedExpenses = List<ExpenseModel>.from(existing.expenses)..insert(0, expense);
    final updatedRecord = existing.copyWith(
      expenses: updatedExpenses,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );


    final updatedMap = Map<String, DailyRecordModel>.from(state)..[date] = updatedRecord;
    state = updatedMap;

    await _storageService.setCachedRecords(updatedMap);
    await _storageService.addToSyncQueue(updatedRecord);
    triggerSync();
  }

  Future<void> deleteExpense(String date, String expenseId) async {
    final record = state[date];
    if (record == null) return;

    final targetExpense = record.expenses.firstWhere(
      (e) => e.id == expenseId,
      orElse: () => ExpenseModel(id: '', amount: 0, title: '', category: '', deductionType: '', timestamp: 0),
    );

    if (targetExpense.id.isEmpty) return;


    final updatedExpenses = record.expenses.where((e) => e.id != expenseId).toList();
    final updatedRecord = record.copyWith(
      expenses: updatedExpenses,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    final updatedMap = Map<String, DailyRecordModel>.from(state)..[date] = updatedRecord;
    state = updatedMap;

    await _storageService.setCachedRecords(updatedMap);
    await _storageService.addToSyncQueue(updatedRecord);
    triggerSync();
  }

  Future<void> updateStartingMoney(String date, int startingMoneyCents) async {
    final record = getOrCreateRecord(date);
    final updatedRecord = record.copyWith(
      startingMoney: startingMoneyCents,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    final updatedMap = Map<String, DailyRecordModel>.from(state)..[date] = updatedRecord;
    state = updatedMap;

    await _storageService.setCachedRecords(updatedMap);
    await _storageService.addToSyncQueue(updatedRecord);
    triggerSync();
  }

  Future<void> markRestDay(String date) async {
    final existing = getOrCreateRecord(date);
    final updatedRecord = existing.copyWith(
      title: 'rest day',
      startingMoney: 0,
      expenses: [],
      isDeleted: true,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    final updatedMap = Map<String, DailyRecordModel>.from(state)..[date] = updatedRecord;
    state = updatedMap;

    await _storageService.setCachedRecords(updatedMap);
    await _storageService.addToSyncQueue(updatedRecord);
    triggerSync();
  }

  Future<void> triggerSync({bool fullSync = false}) async {
    if (isSyncing) return;
    isSyncing = true;
    try {
      final res = await _syncService.performSync(fullSync: fullSync);
      if (res.success && res.updatedRecords != null) {
        state = res.updatedRecords!;
      }
    } finally {
      isSyncing = false;
    }
  }

  /// Clears local sync cursor and pulls all historical records from MongoDB
  Future<void> forceResyncFromCloud() async {
    await _storageService.resetLastSyncTime();
    await triggerSync(fullSync: true);
  }
}

final recordsProvider = StateNotifierProvider<RecordsNotifier, Map<String, DailyRecordModel>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final syncService = ref.watch(syncServiceProvider);
  return RecordsNotifier(storage, syncService, ref);
});

/// Calculates the dynamic derived wallet balance:
/// derivedBalance = settings.currentBalance - totalBalanceDeductions
/// across all non-deleted daily records (mirroring GoalWidget.js).
final derivedWalletBalanceProvider = Provider<int>((ref) {
  final settings = ref.watch(settingsProvider);
  final records = ref.watch(recordsProvider);

  int totalBalanceDeductions = 0;
  for (final record in records.values) {
    if (record.isDeleted) continue;
    final isAllowanceDay = record.startingMoney > 0;
    if (isAllowanceDay) {
      totalBalanceDeductions += record.expenses
          .where((e) => e.deductionType == 'wallet')
          .fold(0, (sum, e) => sum + e.amount);
    } else {
      totalBalanceDeductions += record.expenses
          .fold(0, (sum, e) => sum + e.amount);
    }
  }

  return settings.currentBalance - totalBalanceDeductions;
});

final walletBalanceProvider = derivedWalletBalanceProvider;

