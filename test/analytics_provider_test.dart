import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:monance_mobile/core/database/app_database.dart';
import 'package:monance_mobile/models/daily_record_model.dart';
import 'package:monance_mobile/models/expense_model.dart';
import 'package:monance_mobile/providers/analytics_provider.dart';
import 'package:monance_mobile/providers/database_provider.dart';
import 'package:monance_mobile/providers/records_provider.dart';
import 'package:monance_mobile/providers/settings_provider.dart';

void main() {
  group('test/analytics_provider_test.dart (Analytics Engine & Relational Filtering)', () {
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
      await container.read(recordsProvider.notifier).loadRecords();
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('Category breakdown & deleted-category color fallback', () async {
      final settingsNotifier = container.read(settingsProvider.notifier);
      final recordsNotifier = container.read(recordsProvider.notifier);

      // Add a custom category 'Gaming' with color '#8B5CF6'
      await settingsNotifier.addCategory('Gaming', '#8B5CF6');

      // Seed daily records in 2026-09 and 2026-10
      const recSep = DailyRecordModel(
        date: '2026-09-15',
        title: 'school',
        startingMoney: 50000,
        isDeleted: false,
        updatedAt: 1726358400000,
        expenses: [
          ExpenseModel(
            id: 'e1',
            date: '2026-09-15',
            title: 'Lunch',
            amount: 6000, // 60.00
            category: 'Food',
            deductFrom: 'allowance',
            timestamp: 1726358400000,
          ),
          ExpenseModel(
            id: 'e2',
            date: '2026-09-15',
            title: 'Game Skin',
            amount: 4000, // 40.00
            category: 'Gaming',
            deductFrom: 'balance',
            timestamp: 1726358400000,
          ),
        ],
      );

      const recOct = DailyRecordModel(
        date: '2026-10-10',
        title: 'school',
        startingMoney: 50000,
        isDeleted: false,
        updatedAt: 1728518400000,
        expenses: [
          ExpenseModel(
            id: 'e3',
            date: '2026-10-10',
            title: 'Dinner',
            amount: 10000,
            category: 'Food',
            deductFrom: 'allowance',
            timestamp: 1728518400000,
          ),
          ExpenseModel(
            id: 'e4',
            date: '2026-10-10',
            title: 'Jeepney',
            amount: 2500,
            category: 'Transport',
            deductFrom: 'allowance',
            timestamp: 1728518400000,
          ),
        ],
      );

      // Seed a soft-deleted record that should be completely excluded (AUDIT-003)
      const recDeleted = DailyRecordModel(
        date: '2026-10-11',
        title: 'school',
        startingMoney: 50000,
        isDeleted: true,
        updatedAt: 1728604800000,
        expenses: [
          ExpenseModel(
            id: 'e-del',
            date: '2026-10-11',
            title: 'Phantom Expense',
            amount: 999999,
            category: 'Food',
            deductFrom: 'allowance',
            timestamp: 1728604800000,
          ),
        ],
      );

      await recordsNotifier.setRecord(recSep);
      await recordsNotifier.setRecord(recOct);
      await recordsNotifier.setRecord(recDeleted);

      // Now delete custom category 'Gaming' from CategoriesTable
      await settingsNotifier.deleteCategory('Gaming');
      expect(
        container.read(settingsProvider).categories.any((c) => c.name == 'Gaming'),
        isFalse,
      );

      // Read analytics for 2026-09
      container.read(selectedMonthFilterProvider.notifier).state = '2026-09';
      final analyticsSep = container.read(analyticsProvider);

      expect(analyticsSep.totalExpensesCents, equals(10000));
      expect(analyticsSep.categoryBreakdown.length, equals(2));

      // Sorted descending by spend: Food (6000), Gaming (4000)
      expect(analyticsSep.categoryBreakdown[0].category, equals('Food'));
      expect(analyticsSep.categoryBreakdown[0].amountCents, equals(6000));
      expect(analyticsSep.categoryBreakdown[0].percentage, equals(60.0));

      // Gaming should resolve to fallback color #64748B
      expect(analyticsSep.categoryBreakdown[1].category, equals('Gaming'));
      expect(analyticsSep.categoryBreakdown[1].amountCents, equals(4000));
      expect(analyticsSep.categoryBreakdown[1].percentage, equals(40.0));
      expect(analyticsSep.categoryBreakdown[1].colorHex, equals('#64748B'));

      // Percentages sum to 100.0
      final sumPct = analyticsSep.categoryBreakdown
          .map((e) => e.percentage)
          .reduce((a, b) => a + b);
      expect(sumPct, closeTo(100.0, 0.001));

      // Assert deleted record was excluded from October
      container.read(selectedMonthFilterProvider.notifier).state = '2026-10';
      final analyticsOct = container.read(analyticsProvider);
      expect(analyticsOct.totalExpensesCents, equals(12500)); // 10000 + 2500, not 999999
    });

    test('Month filter & Month-over-Month (MoM) calculation', () async {
      final recordsNotifier = container.read(recordsProvider.notifier);

      // 2026-09 total = 10000 cents
      const recSep = DailyRecordModel(
        date: '2026-09-20',
        title: 'school',
        startingMoney: 20000,
        isDeleted: false,
        updatedAt: 1726790400000,
        expenses: [
          ExpenseModel(
            id: 's1',
            date: '2026-09-20',
            title: 'Sep Supplies',
            amount: 10000,
            category: 'Other',
            deductFrom: 'allowance',
            timestamp: 1726790400000,
          ),
        ],
      );

      // 2026-10 total = 12500 cents
      const recOct = DailyRecordModel(
        date: '2026-10-05',
        title: 'school',
        startingMoney: 20000,
        isDeleted: false,
        updatedAt: 1728086400000,
        expenses: [
          ExpenseModel(
            id: 'o1',
            date: '2026-10-05',
            title: 'Oct Books',
            amount: 12500,
            category: 'Other',
            deductFrom: 'allowance',
            timestamp: 1728086400000,
          ),
        ],
      );

      await recordsNotifier.setRecord(recSep);
      await recordsNotifier.setRecord(recOct);

      // 1. Select '2026-10': reports +25.0% MoM increase
      container.read(selectedMonthFilterProvider.notifier).state = '2026-10';
      final octData = container.read(analyticsProvider);
      expect(octData.totalExpensesCents, equals(12500));
      expect(octData.momComparison.hasPreviousData, isTrue);
      expect(octData.momComparison.previousTotalCents, equals(10000));
      expect(octData.momComparison.percentageChange, closeTo(25.0, 0.001));

      // 2. Select '2026-09': where 2026-08 has 0 spend -> hasPreviousData == false
      container.read(selectedMonthFilterProvider.notifier).state = '2026-09';
      final sepData = container.read(analyticsProvider);
      expect(sepData.totalExpensesCents, equals(10000));
      expect(sepData.momComparison.hasPreviousData, isFalse);
      expect(sepData.momComparison.previousTotalCents, equals(0));

      // 3. Select 'ALL': sums both months (22500 cents)
      container.read(selectedMonthFilterProvider.notifier).state = 'ALL';
      final allData = container.read(analyticsProvider);
      expect(allData.totalExpensesCents, equals(22500));
      expect(allData.momComparison.hasPreviousData, isFalse);

      // Distinct available months
      expect(allData.availableMonths, equals(['2026-10', '2026-09']));
    });

    test('Adversarial: Category validation bounds & empty month handling', () async {
      final settingsNotifier = container.read(settingsProvider.notifier);

      // Reject empty or whitespace-only category name
      expect(await settingsNotifier.addCategory('', '#000000'), isFalse);
      expect(await settingsNotifier.addCategory('   ', '#000000'), isFalse);

      // Reject category name exceeding 30 characters
      final longName = 'A' * 31;
      expect(await settingsNotifier.addCategory(longName, '#000000'), isFalse);

      // Update category validation bounds
      expect(
        await settingsNotifier.updateCategory('Food', newName: '   '),
        isFalse,
      );
      expect(
        await settingsNotifier.updateCategory('Food', newName: longName),
        isFalse,
      );

      // Delete category enforces minimum 1 category
      // Keep deleting until 1 category remains
      while (container.read(settingsProvider).categories.length > 1) {
        final catToDelete = container.read(settingsProvider).categories.last.name;
        final deleted = await settingsNotifier.deleteCategory(catToDelete);
        expect(deleted, isTrue);
      }
      expect(container.read(settingsProvider).categories.length, equals(1));
      // Deleting the last remaining category must fail / return false
      final lastCat = container.read(settingsProvider).categories.first.name;
      final attemptDeleteLast = await settingsNotifier.deleteCategory(lastCat);
      expect(attemptDeleteLast, isFalse);
      expect(container.read(settingsProvider).categories.length, equals(1));

      // Month with 0 expenses
      container.read(selectedMonthFilterProvider.notifier).state = '2025-01';
      final emptyMonthData = container.read(analyticsProvider);
      expect(emptyMonthData.totalExpensesCents, equals(0));
      expect(emptyMonthData.categoryBreakdown, isEmpty);
      expect(emptyMonthData.topCategory, isNull);
      expect(emptyMonthData.momComparison.hasPreviousData, isFalse);
    });
  });
}
