import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:monance_mobile/core/database/app_database.dart';
import 'package:monance_mobile/models/daily_record_model.dart';
import 'package:monance_mobile/models/expense_model.dart';
import 'package:monance_mobile/models/settings_model.dart';
import 'package:monance_mobile/providers/database_provider.dart';
import 'package:monance_mobile/providers/goal_calculation_provider.dart';
import 'package:monance_mobile/providers/records_provider.dart';
import 'package:monance_mobile/providers/settings_provider.dart';

void main() {
  group('test/goal_calculations_test.dart (AUDIT-008 & Archive Trap Verification)', () {
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

    test('AUDIT-008 rest day isolation & goalStartDate filtering', () {
      // Configure goal: goalAmount = 100000 (₱1000), goalStartDate = '2026-10-15'
      const settings = SettingsModel(
        goalAmount: 100000,
        goalStartDate: '2026-10-15',
        currentBalance: 50000,
      );

      final records = [
        // 1. Allowance day BEFORE goalStartDate (should be ignored)
        const DailyRecordModel(
          date: '2026-10-10',
          startingMoney: 5000, // ₱50
          expenses: [
            ExpenseModel(
              id: 'exp-prior',
              date: '2026-10-10',
              title: 'Prior Lunch',
              amount: 2000,
              deductFrom: 'allowance',
              timestamp: 1,
            ),
          ],
          updatedAt: 1,
        ),
        // 2. Allowance day ON/AFTER goalStartDate
        // startingMoney: 6000, allowance expense: 2000, balance expense: 1500
        // daySavings = 6000 - 2000 = 4000 (balance expense must NOT reduce daySavings)
        const DailyRecordModel(
          date: '2026-10-16',
          startingMoney: 6000,
          expenses: [
            ExpenseModel(
              id: 'exp-active-allowance',
              date: '2026-10-16',
              title: 'Canteen',
              amount: 2000,
              deductFrom: 'allowance',
              timestamp: 2,
            ),
            ExpenseModel(
              id: 'exp-active-balance',
              date: '2026-10-16',
              title: 'Novel',
              amount: 1500,
              deductFrom: 'balance',
              timestamp: 3,
            ),
          ],
          updatedAt: 2,
        ),
        // 3. Rest day (startingMoney = 0) with expenses ON/AFTER goalStartDate (should be ignored)
        const DailyRecordModel(
          date: '2026-10-18',
          startingMoney: 0,
          expenses: [
            ExpenseModel(
              id: 'exp-rest-1',
              date: '2026-10-18',
              title: 'Rest Day Coffee',
              amount: 1500,
              deductFrom: 'allowance',
              timestamp: 4,
            ),
          ],
          updatedAt: 3,
        ),
      ];

      final metrics = GoalMetrics.calculate(settings: settings, records: records);

      // Only record 2 affects goal metrics:
      expect(metrics.allowanceDaysCount, equals(1));
      expect(metrics.totalSavings, equals(4000)); // ₱40.00
      expect(metrics.totalAllowanceSavings, equals(4000));
      expect(metrics.totalExpenses, equals(2000)); // ₱20.00
      expect(metrics.averageDailySavings, equals(40.0));
      expect(metrics.averageDailyExpenses, equals(20.0));
      expect(metrics.averageDailyAllowance, equals(60.0));
      // burnRatePercent = (20.0 / 60.0) * 100 = 33.333...
      expect(metrics.burnRatePercent, closeTo(33.333, 0.01));
      expect(metrics.pacingStatus, equals('On Track'));
    });

    test('Pacing & Smart Tip boundary conditions', () {
      // 1. allowanceDaysCount == 0
      const emptySettings = SettingsModel(goalAmount: 50000);
      final emptyMetrics = GoalMetrics.calculate(settings: emptySettings, records: []);
      expect(emptyMetrics.allowanceDaysCount, equals(0));
      expect(emptyMetrics.estimatedDaysText, equals('Start tracking allowance days to estimate'));
      expect(emptyMetrics.pacingStatus, equals('N/A'));
      expect(emptyMetrics.smartBudgetTip, equals('Start recording your daily expenses in the calendar to generate personalized budgeting tips.'));

      // 2. burnRatePercent == 80.0 ('High Burn')
      // startingMoney: 10000, allowance expense: 8000 -> burnRate = 80.0%
      const settings80 = SettingsModel(goalAmount: 50000);
      final record80 = [
        const DailyRecordModel(
          date: '2026-10-01',
          startingMoney: 10000,
          expenses: [
            ExpenseModel(id: 'e1', date: '2026-10-01', title: 'Spend', amount: 8000, deductFrom: 'allowance', timestamp: 1),
          ],
          updatedAt: 1,
        )
      ];
      final metrics80 = GoalMetrics.calculate(settings: settings80, records: record80);
      expect(metrics80.burnRatePercent, equals(80.0));
      expect(metrics80.pacingStatus, equals('High Burn'));

      // 3. burnRatePercent > 100.0 ('Overspending')
      // startingMoney: 10000, allowance expense: 12000 -> burnRate = 120.0%
      final record120 = [
        const DailyRecordModel(
          date: '2026-10-01',
          startingMoney: 10000,
          expenses: [
            ExpenseModel(id: 'e1', date: '2026-10-01', title: 'Spend', amount: 12000, deductFrom: 'allowance', timestamp: 1),
          ],
          updatedAt: 1,
        )
      ];
      final metrics120 = GoalMetrics.calculate(settings: settings80, records: record120);
      expect(metrics120.burnRatePercent, equals(120.0));
      expect(metrics120.pacingStatus, equals('Overspending'));

      // 4. burnRatePercent < 80.0 ('On Track')
      // startingMoney: 10000, allowance expense: 7900 -> burnRate = 79.0%
      final record79 = [
        const DailyRecordModel(
          date: '2026-10-01',
          startingMoney: 10000,
          expenses: [
            ExpenseModel(id: 'e1', date: '2026-10-01', title: 'Spend', amount: 7900, deductFrom: 'allowance', timestamp: 1),
          ],
          updatedAt: 1,
        )
      ];
      final metrics79 = GoalMetrics.calculate(settings: settings80, records: record79);
      expect(metrics79.burnRatePercent, equals(79.0));
      expect(metrics79.pacingStatus, equals('On Track'));

      // 5. Goal reached (displayRemaining == 0 && displayGoal > 0)
      // goalAmount: 5000 (₱50), savings: 6000 (₱60)
      const settingsReached = SettingsModel(goalAmount: 5000);
      final recordReached = [
        const DailyRecordModel(
          date: '2026-10-01',
          startingMoney: 8000,
          expenses: [
            ExpenseModel(id: 'e1', date: '2026-10-01', title: 'Spend', amount: 2000, deductFrom: 'allowance', timestamp: 1),
          ],
          updatedAt: 1,
        )
      ];
      final metricsReached = GoalMetrics.calculate(settings: settingsReached, records: recordReached);
      expect(metricsReached.displayRemaining, equals(0.0));
      expect(metricsReached.estimatedDaysText, equals('Goal reached!'));
      expect(metricsReached.smartBudgetTip, equals('Congratulations! You have reached your savings goal. Consider setting a new target in settings.'));

      // 6. averageDailySavings <= 0
      final recordZeroSavings = [
        const DailyRecordModel(
          date: '2026-10-01',
          startingMoney: 5000,
          expenses: [
            ExpenseModel(id: 'e1', date: '2026-10-01', title: 'Spend', amount: 5000, deductFrom: 'allowance', timestamp: 1),
          ],
          updatedAt: 1,
        )
      ];
      final metricsZeroSavings = GoalMetrics.calculate(settings: settings80, records: recordZeroSavings);
      expect(metricsZeroSavings.averageDailySavings, equals(0.0));
      expect(metricsZeroSavings.estimatedDaysText, equals('N/A (Average savings is <= 0)'));
      expect(metricsZeroSavings.smartBudgetTip, equals('Your current average daily savings is negative or zero. Try reducing non-essential categories like Shopping or Entertainment this week.'));

      // 7. daysNeeded > 60 tip
      // goalAmount: 200000 (₱2000), savings: ₱10/day -> remaining ₱1990 -> daysNeeded = 199 > 60
      const settings60 = SettingsModel(goalAmount: 200000);
      final record60 = [
        const DailyRecordModel(
          date: '2026-10-01',
          startingMoney: 5000, // ₱50
          expenses: [
            ExpenseModel(id: 'e1', date: '2026-10-01', title: 'Spend', amount: 4000, deductFrom: 'allowance', timestamp: 1),
          ],
          updatedAt: 1,
        )
      ];
      final metrics60 = GoalMetrics.calculate(settings: settings60, records: record60);
      expect(metrics60.daysNeeded!, greaterThan(60));
      expect(metrics60.smartBudgetTip, contains('To hit your goal in 30 days, you need to save an extra'));
    });

    test('Archive trap & Undo restoration (Trap #7 Fix)', () async {
      final settingsNotifier = container.read(settingsProvider.notifier);
      final recordsNotifier = container.read(recordsProvider.notifier);

      // Setup initial state:
      // currentBalance = 10000 (₱100), goalAmount = 50000 (₱500), goalStartDate = '2026-10-01'
      await settingsNotifier.updateCurrentBalance(10000);
      await settingsNotifier.updateGoalAmount(50000);
      await settingsNotifier.updateGoalStartDate('2026-10-01');

      // Add 2 allowance days:
      // Day 1 (2026-10-05): starting 5000, exp 2000 -> saved 3000
      // Day 2 (2026-10-06): starting 5000, exp 1000 -> saved 4000
      // Total savings = 7000 (₱70.00)
      await recordsNotifier.setRecord(const DailyRecordModel(
        date: '2026-10-05',
        startingMoney: 5000,
        expenses: [
          ExpenseModel(id: 'e1', date: '2026-10-05', title: 'Lunch', amount: 2000, deductFrom: 'allowance', timestamp: 1),
        ],
        updatedAt: 1,
      ));
      await recordsNotifier.setRecord(const DailyRecordModel(
        date: '2026-10-06',
        startingMoney: 5000,
        expenses: [
          ExpenseModel(id: 'e2', date: '2026-10-06', title: 'Snack', amount: 1000, deductFrom: 'allowance', timestamp: 2),
        ],
        updatedAt: 2,
      ));

      // Verify pre-archive calculations
      final preArchiveMetrics = container.read(goalCalculationProvider);
      expect(preArchiveMetrics.totalSavings, equals(7000));
      expect(container.read(settingsProvider).currentBalance, equals(10000));

      // 1. Complete & Archive Goal on '2026-10-30'
      final archivedItem = await settingsNotifier.archiveGoal(
        todayIsoDate: '2026-10-30',
        totalSavingsCents: 7000,
      );

      // Verify row inserted in GoalHistoryTable
      expect(archivedItem.amount, equals(50000));
      expect(archivedItem.saved, equals(7000));
      expect(archivedItem.startDate, equals('2026-10-01'));
      expect(archivedItem.endDate, equals('2026-10-30'));

      // Verify SettingsTable updated:
      // currentBalance = 10000 + 7000 = 17000
      // goalAmount = 0
      // goalStartDate = '2026-10-31' (tomorrow)
      final postArchiveSettings = container.read(settingsProvider);
      expect(postArchiveSettings.currentBalance, equals(17000));
      expect(postArchiveSettings.goalAmount, equals(0));
      expect(postArchiveSettings.goalStartDate, equals('2026-10-31'));

      // Verify post-archive goal metrics:
      // Since goalStartDate is '2026-10-31', prior days (10-05, 10-06) are NOT re-counted!
      final postArchiveMetrics = container.read(goalCalculationProvider);
      expect(postArchiveMetrics.totalSavings, equals(0));
      expect(postArchiveMetrics.allowanceDaysCount, equals(0));

      // 2. Undo Recent Goal
      final undone = await settingsNotifier.undoRecentGoal();
      expect(undone, isNotNull);
      expect(undone!.id, equals(archivedItem.id));

      // Verify pre-archive state restored identically:
      final undoneSettings = container.read(settingsProvider);
      expect(undoneSettings.goalAmount, equals(50000));
      expect(undoneSettings.goalStartDate, equals('2026-10-01'));
      expect(undoneSettings.currentBalance, equals(10000));

      // Verify totalSavings restored:
      final undoneMetrics = container.read(goalCalculationProvider);
      expect(undoneMetrics.totalSavings, equals(7000));
      expect(undoneMetrics.allowanceDaysCount, equals(2));
    });
  });
}
