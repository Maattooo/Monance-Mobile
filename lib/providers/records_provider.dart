import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../core/database/app_database.dart';
import '../models/daily_record_model.dart';
import '../models/expense_model.dart';
import 'database_provider.dart';
import 'settings_provider.dart';

class RecordsNotifier extends StateNotifier<Map<String, DailyRecordModel>> {
  final AppDatabase _db;
  final Ref _ref;
  static const _uuid = Uuid();

  RecordsNotifier(this._db, this._ref) : super({}) {
    loadRecords();
  }

  Future<void> loadRecords() async {
    final recordRows = await _db.select(_db.dailyRecordsTable).get();
    final expenseRows = await _db.select(_db.expensesTable).get();

    final Map<String, List<ExpenseModel>> expensesByDate = {};
    for (final expRow in expenseRows) {
      final model = ExpenseModel.fromDrift(expRow);
      expensesByDate.putIfAbsent(model.date, () => []).add(model);
    }

    final Map<String, DailyRecordModel> recordsMap = {};
    for (final recRow in recordRows) {
      final expenses = expensesByDate[recRow.date] ?? [];
      recordsMap[recRow.date] = DailyRecordModel.fromDrift(recRow, expenses);
    }

    state = recordsMap;
  }

  DailyRecordModel getOrCreateRecord(String date) {
    if (state.containsKey(date) && !state[date]!.isDeleted) {
      return state[date]!;
    }
    final defaultAllowance = _ref.read(settingsProvider).defaultAllowance;
    final now = DateTime.now().millisecondsSinceEpoch;
    return DailyRecordModel(
      date: date,
      title: 'school',
      startingMoney: defaultAllowance,
      expenses: const [],
      isDeleted: false,
      updatedAt: now,
    );
  }

  Future<void> setRecord(DailyRecordModel record) async {
    await _db.transaction(() async {
      await _db.into(_db.dailyRecordsTable).insert(
            record.toCompanion(),
            mode: drift.InsertMode.insertOrReplace,
          );
      // Clean existing expenses for this date then insert new ones
      await (_db.delete(_db.expensesTable)..where((t) => t.date.equals(record.date))).go();
      for (final exp in record.expenses) {
        final expWithDate = exp.date.isEmpty ? exp.copyWith(date: record.date) : exp;
        await _db.into(_db.expensesTable).insert(
              expWithDate.toCompanion(),
              mode: drift.InsertMode.insertOrReplace,
            );
      }
    });

    final updated = Map<String, DailyRecordModel>.from(state)..[record.date] = record;
    state = updated;
  }

  Future<void> addExpense({
    required String date,
    required int amount,
    required String title,
    required String category,
    required String deductFrom, // 'allowance' | 'balance'
  }) async {
    final existing = getOrCreateRecord(date);
    final now = DateTime.now().millisecondsSinceEpoch;
    final expenseId = _uuid.v4();

    // Standardize deductFrom mapping
    final normalizedDeduct = (deductFrom == 'wallet' || deductFrom == 'balance') ? 'balance' : 'allowance';

    final expense = ExpenseModel(
      id: expenseId,
      date: date,
      title: title.trim(),
      amount: amount,
      category: category,
      deductFrom: normalizedDeduct,
      timestamp: now,
    );

    await _db.transaction(() async {
      // Ensure daily record exists in DB
      await _db.into(_db.dailyRecordsTable).insert(
            existing.toCompanion(),
            mode: drift.InsertMode.insertOrIgnore,
          );
      await _db.into(_db.expensesTable).insert(expense.toCompanion());
    });

    final updatedExpenses = List<ExpenseModel>.from(existing.expenses)..insert(0, expense);
    final updatedRecord = existing.copyWith(
      expenses: updatedExpenses,
      updatedAt: now,
      isDeleted: false,
    );

    state = Map<String, DailyRecordModel>.from(state)..[date] = updatedRecord;
  }

  Future<void> updateExpense({
    required String date,
    required ExpenseModel expense,
  }) async {
    final existing = state[date];
    if (existing == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final expWithDate = expense.date.isEmpty ? expense.copyWith(date: date) : expense;

    await (_db.update(_db.expensesTable)..where((t) => t.id.equals(expense.id))).write(
      expWithDate.toCompanion(),
    );

    final updatedExpenses = existing.expenses.map((e) => e.id == expense.id ? expWithDate : e).toList();
    final updatedRecord = existing.copyWith(expenses: updatedExpenses, updatedAt: now);
    state = Map<String, DailyRecordModel>.from(state)..[date] = updatedRecord;
  }

  Future<void> deleteExpense(String date, String expenseId) async {
    final record = state[date];
    if (record == null) return;

    await (_db.delete(_db.expensesTable)..where((t) => t.id.equals(expenseId))).go();

    final updatedExpenses = record.expenses.where((e) => e.id != expenseId).toList();
    final now = DateTime.now().millisecondsSinceEpoch;
    final updatedRecord = record.copyWith(
      expenses: updatedExpenses,
      updatedAt: now,
    );

    state = Map<String, DailyRecordModel>.from(state)..[date] = updatedRecord;
  }

  Future<void> updateStartingMoney(String date, int startingMoneyCents) async {
    final record = getOrCreateRecord(date);
    final now = DateTime.now().millisecondsSinceEpoch;
    final updatedRecord = record.copyWith(
      startingMoney: startingMoneyCents,
      updatedAt: now,
      isDeleted: false,
    );

    await _db.into(_db.dailyRecordsTable).insert(
          updatedRecord.toCompanion(),
          mode: drift.InsertMode.insertOrReplace,
        );

    state = Map<String, DailyRecordModel>.from(state)..[date] = updatedRecord;
  }

  Future<void> clearDay(String date) async {
    final record = state[date];
    if (record == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final updatedRecord = record.copyWith(
      isDeleted: true,
      updatedAt: now,
    );

    await (_db.update(_db.dailyRecordsTable)..where((t) => t.date.equals(date))).write(
      DailyRecordsTableCompanion(
        isDeleted: const drift.Value(true),
        updatedAt: drift.Value(now),
      ),
    );

    state = Map<String, DailyRecordModel>.from(state)..[date] = updatedRecord;
  }

  Future<void> markRestDay(String date) async {
    await updateStartingMoney(date, 0);
  }
}

final recordsProvider = StateNotifierProvider<RecordsNotifier, Map<String, DailyRecordModel>>((ref) {
  final db = ref.watch(databaseProvider);
  return RecordsNotifier(db, ref);
});

/// Critical Derived Wallet Balance Provider (§6.1)
/// Invariant: Routine expense operations NEVER mutate settings.currentBalance.
/// Live balance is derived dynamically across all non-deleted daily records.
final derivedWalletBalanceProvider = Provider<int>((ref) {
  final settings = ref.watch(settingsProvider);
  final recordsMap = ref.watch(recordsProvider);

  int totalBalanceDeductions = 0;
  for (final record in recordsMap.values) {
    if (record.isDeleted) continue;

    if (record.startingMoney > 0) {
      // Allowance Day (record.startingMoney > 0):
      // Only expenses with deductFrom == 'balance' are added to totalBalanceDeductions
      totalBalanceDeductions += record.balanceExpensesSum;
    } else {
      // Non-Allowance / Rest Day (record.startingMoney <= 0):
      // All expenses on that day are added to totalBalanceDeductions
      totalBalanceDeductions += record.totalExpenses;
    }
  }

  return settings.currentBalance - totalBalanceDeductions;
});
