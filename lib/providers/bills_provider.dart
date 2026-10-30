import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../core/database/app_database.dart';
import '../core/utils/date_utils_ext.dart';
import '../models/monthly_bill_model.dart';
import '../services/local_notification_service.dart';
import 'database_provider.dart';
import 'settings_provider.dart';

class BillsNotifier extends StateNotifier<List<MonthlyBillModel>> {
  final AppDatabase _db;
  final Ref _ref;
  static const _uuid = Uuid();

  BillsNotifier(this._db, this._ref) : super([]) {
    loadBills();
  }

  Future<void> loadBills() async {
    final rows = await (_db.select(_db.monthlyBillsTable)
          ..orderBy([
            (t) => drift.OrderingTerm(expression: t.sortOrder),
            (t) => drift.OrderingTerm(expression: t.dueDay),
          ]))
        .get();
    state = rows.map(MonthlyBillModel.fromDrift).toList();
  }

  Future<void> _rescheduleNotifications() async {
    try {
      final settings = _ref.read(settingsProvider);
      final notifService = _ref.read(localNotificationServiceProvider);
      await notifService.rescheduleBillNotifications(
        state,
        enabled: settings.billNotificationsEnabled,
      );
    } catch (_) {
      // Notification rescheduling must never crash or block bill CRUD
    }
  }

  /// Implements specification.md §6.5.1: Automatic Monthly Rollover
  Future<bool> checkAndRolloverBills(DateTime now) async {
    final currentMonth = DateUtilsExt.formatIsoMonth(now);
    final settings = _ref.read(settingsProvider);
    final lastBillsMonth = settings.lastBillsMonth;

    if (lastBillsMonth != null && lastBillsMonth != currentMonth) {
      // New month detected: reset all bills to isPaid = false
      await _db.transaction(() async {
        await (_db.update(_db.monthlyBillsTable))
            .write(const MonthlyBillsTableCompanion(isPaid: drift.Value(false)));
      });
      await _ref.read(settingsProvider.notifier).updateLastBillsMonth(currentMonth);
      await loadBills();
      await _rescheduleNotifications();
      return true;
    } else if (lastBillsMonth == null) {
      // First run: initialize lastBillsMonth without resetting bills
      await _ref.read(settingsProvider.notifier).updateLastBillsMonth(currentMonth);
      return false;
    }

    return false; // Already up to date for current month
  }

  Future<MonthlyBillModel> addBill({
    required String title,
    required int amount,
    required int dueDay,
    int? sortOrder,
  }) async {
    final id = _uuid.v4();
    final sort = sortOrder ?? state.length;
    final bill = MonthlyBillModel(
      id: id,
      title: title.trim(),
      amount: amount,
      dueDay: dueDay.clamp(1, 31),
      isPaid: false,
      sortOrder: sort,
    );

    await _db.into(_db.monthlyBillsTable).insert(bill.toCompanion());
    await loadBills();
    await _rescheduleNotifications();
    return bill;
  }

  Future<void> updateBill(MonthlyBillModel bill) async {
    await (_db.update(_db.monthlyBillsTable)..where((t) => t.id.equals(bill.id))).write(
      bill.toCompanion(),
    );
    await loadBills();
    await _rescheduleNotifications();
  }

  Future<void> deleteBill(String id) async {
    await (_db.delete(_db.monthlyBillsTable)..where((t) => t.id.equals(id))).go();
    state = state.where((b) => b.id != id).toList();
    await _rescheduleNotifications();
  }

  Future<void> toggleBillPaid(String id, [bool? isPaid]) async {
    final index = state.indexWhere((b) => b.id == id);
    if (index == -1) return; // Safely guarded against non-existent id

    final target = state[index];
    final updatedPaid = isPaid ?? !target.isPaid;
    await (_db.update(_db.monthlyBillsTable)..where((t) => t.id.equals(id))).write(
      MonthlyBillsTableCompanion(isPaid: drift.Value(updatedPaid)),
    );
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) state[i].copyWith(isPaid: updatedPaid) else state[i]
    ];
    await _rescheduleNotifications();
  }

  Future<void> resetAllBills() async {
    await (_db.update(_db.monthlyBillsTable))
        .write(const MonthlyBillsTableCompanion(isPaid: drift.Value(false)));
    await loadBills();
    await _rescheduleNotifications();
  }

  /// specification.md §6.5.2: Short-Month Effective Due Day Clamping
  static String getBillStatus(MonthlyBillModel bill, DateTime today) {
    if (bill.isPaid) return 'Paid';

    final days = DateUtilsExt.daysInMonth(today.year, today.month);
    final effectiveDueDay = min(bill.dueDay, days);

    if (effectiveDueDay < today.day) {
      return 'Overdue (Due Day ${bill.dueDay})';
    } else if (effectiveDueDay == today.day) {
      return 'Due Today!';
    } else {
      final diff = effectiveDueDay - today.day;
      return 'Due in $diff day${diff > 1 ? "s" : ""} (Day ${bill.dueDay})';
    }
  }
}

final billsProvider = StateNotifierProvider<BillsNotifier, List<MonthlyBillModel>>((ref) {
  final db = ref.watch(databaseProvider);
  return BillsNotifier(db, ref);
});
