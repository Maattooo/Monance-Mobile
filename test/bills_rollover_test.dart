import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:monance_mobile/core/database/app_database.dart';
import 'package:monance_mobile/models/monthly_bill_model.dart';
import 'package:monance_mobile/providers/bills_provider.dart';
import 'package:monance_mobile/providers/database_provider.dart';
import 'package:monance_mobile/providers/settings_provider.dart';

void main() {
  group('test/bills_rollover_test.dart (Rollover & Short-Month Clamping)', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );
      await container.read(settingsProvider.notifier).loadSettings();
      await container.read(billsProvider.notifier).loadBills();
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('Automatic monthly rollover (specification.md §6.5.1)', () async {
      final settingsNotifier = container.read(settingsProvider.notifier);
      final billsNotifier = container.read(billsProvider.notifier);

      // Seed 2 bills with isPaid = true
      final bill1 = await billsNotifier.addBill(title: 'Internet Fiber', amount: 169900, dueDay: 15);
      final bill2 = await billsNotifier.addBill(title: 'Electricity', amount: 350000, dueDay: 20);
      await billsNotifier.toggleBillPaid(bill1.id, true);
      await billsNotifier.toggleBillPaid(bill2.id, true);

      // Set lastBillsMonth = '2026-09'
      await settingsNotifier.updateLastBillsMonth('2026-09');

      // Verify bills are paid in September
      expect(container.read(billsProvider).every((b) => b.isPaid), isTrue);
      expect(container.read(settingsProvider).lastBillsMonth, equals('2026-09'));

      // Trigger rollover check for October 2026
      final rolledOver = await billsNotifier.checkAndRolloverBills(DateTime(2026, 10, 1));
      expect(rolledOver, isTrue);

      // All bills reset to isPaid = false, lastBillsMonth updated to '2026-10'
      final billsOct = container.read(billsProvider);
      expect(billsOct.every((b) => !b.isPaid), isTrue);
      expect(container.read(settingsProvider).lastBillsMonth, equals('2026-10'));

      // Pay bill1 in October
      await billsNotifier.toggleBillPaid(bill1.id, true);
      expect(container.read(billsProvider).firstWhere((b) => b.id == bill1.id).isPaid, isTrue);

      // Re-running check within October leaves newly paid bills untouched
      final rolledOverAgain = await billsNotifier.checkAndRolloverBills(DateTime(2026, 10, 15));
      expect(rolledOverAgain, isFalse);
      expect(container.read(billsProvider).firstWhere((b) => b.id == bill1.id).isPaid, isTrue);
    });

    test('Short-month effective due day clamping (Trap #8 Fix)', () {
      const billDue31 = MonthlyBillModel(
        id: 'bill-31',
        title: 'Subscription',
        amount: 29900,
        dueDay: 31,
        isPaid: false,
      );

      // 1. Non-leap year February (2026-02-28):
      // effectiveDueDay = min(31, 28) = 28 -> on Feb 28, it evaluates to 'Due Today!'
      final statusFebNonLeap = BillsNotifier.getBillStatus(billDue31, DateTime(2026, 2, 28));
      expect(statusFebNonLeap, equals('Due Today!'));

      // 2. Leap year February (2024-02-29):
      // effectiveDueDay = min(31, 29) = 29 -> on Feb 29, it evaluates to 'Due Today!'
      final statusFebLeap = BillsNotifier.getBillStatus(billDue31, DateTime(2024, 2, 29));
      expect(statusFebLeap, equals('Due Today!'));

      // 3. 30-day month April (2026-04-30):
      // effectiveDueDay = min(31, 30) = 30 -> on Apr 30, it evaluates to 'Due Today!'
      final statusApr = BillsNotifier.getBillStatus(billDue31, DateTime(2026, 4, 30));
      expect(statusApr, equals('Due Today!'));

      // 4. Test on 2026-02-27 (day 27 of 28):
      // effectiveDueDay = 28, diff = 28 - 27 = 1 -> 'Due in 1 day (Day 31)'
      final statusFebEve = BillsNotifier.getBillStatus(billDue31, DateTime(2026, 2, 27));
      expect(statusFebEve, equals('Due in 1 day (Day 31)'));

      // 5. Test on 2026-02-26 (day 26 of 28):
      // effectiveDueDay = 28, diff = 28 - 26 = 2 -> 'Due in 2 days (Day 31)'
      final statusFeb26 = BillsNotifier.getBillStatus(billDue31, DateTime(2026, 2, 26));
      expect(statusFeb26, equals('Due in 2 days (Day 31)'));

      // 6. Overdue test: on March 1st (dueDay 28 of February is past, or check inside same month):
      // In February on Feb 28 with dueDay = 15:
      const billDue15 = MonthlyBillModel(
        id: 'bill-15',
        title: 'Gym',
        amount: 150000,
        dueDay: 15,
        isPaid: false,
      );
      final statusOverdue = BillsNotifier.getBillStatus(billDue15, DateTime(2026, 2, 20));
      expect(statusOverdue, equals('Overdue (Due Day 15)'));

      // 7. Paid test:
      const billPaid = MonthlyBillModel(
        id: 'bill-paid',
        title: 'Water',
        amount: 50000,
        dueDay: 10,
        isPaid: true,
      );
      expect(BillsNotifier.getBillStatus(billPaid, DateTime(2026, 2, 20)), equals('Paid'));
    });
  });
}

