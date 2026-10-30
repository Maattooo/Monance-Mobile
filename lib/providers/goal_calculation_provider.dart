import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/currency_formatter.dart';
import '../models/daily_record_model.dart';
import '../models/settings_model.dart';
import 'records_provider.dart';
import 'settings_provider.dart';

class GoalMetrics {
  final int totalSavings; // in cents
  final int totalAllowanceSavings; // in cents
  final int totalExpenses; // in cents
  final int allowanceDaysCount;
  final double displayGoal;
  final double displaySavings;
  final double displayRemaining;
  final double progressPercent;
  final double averageDailySavings;
  final double averageDailyExpenses;
  final double averageDailyAllowance;
  final double burnRatePercent;
  final int? daysNeeded;
  final String estimatedDaysText;
  final String pacingStatus; // 'N/A' | 'On Track' | 'High Burn' | 'Overspending'
  final String smartBudgetTip;

  const GoalMetrics({
    required this.totalSavings,
    required this.totalAllowanceSavings,
    required this.totalExpenses,
    required this.allowanceDaysCount,
    required this.displayGoal,
    required this.displaySavings,
    required this.displayRemaining,
    required this.progressPercent,
    required this.averageDailySavings,
    required this.averageDailyExpenses,
    required this.averageDailyAllowance,
    required this.burnRatePercent,
    this.daysNeeded,
    required this.estimatedDaysText,
    required this.pacingStatus,
    required this.smartBudgetTip,
  });

  /// Implements specification.md §6.2 verbatim
  static GoalMetrics calculate({
    required SettingsModel settings,
    required Iterable<DailyRecordModel> records,
  }) {
    // 1. Post-Archive Protection (Trap #7 Fix):
    // If goalAmount == 0 and goalStartDate == null, totalSavings = 0
    final bool isPostArchiveEmptyGoal =
        settings.goalAmount == 0 && settings.goalStartDate == null;

    int totalSavings = 0;
    int totalAllowanceSavings = 0;
    int totalExpenses = 0;
    int allowanceDaysCount = 0;

    if (!isPostArchiveEmptyGoal) {
      for (final record in records) {
        // Across all records in DailyRecordsTable where isDeleted == false AND record.startingMoney > 0
        if (record.isDeleted || record.startingMoney <= 0) continue;

        // Date Filtering:
        // record is included if and only if settings.goalStartDate == null || record.date.compareTo(settings.goalStartDate!) >= 0
        if (settings.goalStartDate != null &&
            record.date.compareTo(settings.goalStartDate!) < 0) {
          continue;
        }

        // Per-Day Allowance Savings:
        // allowanceExpSum = sum where deductFrom != 'balance'
        final allowanceExpSum = record.allowanceExpensesSum;
        final daySavings = record.startingMoney - allowanceExpSum;

        totalSavings += daySavings;
        totalAllowanceSavings += daySavings;
        totalExpenses += allowanceExpSum;
        allowanceDaysCount += 1;
      }
    }

    // 3. Metrics (in display units = cents / 100.0)
    final displayGoal = settings.goalAmount / 100.0;
    final displaySavings = totalSavings / 100.0;
    final displayRemaining = max(0.0, displayGoal - displaySavings);

    final double progressPercent;
    if (displayGoal > 0) {
      progressPercent = ((displaySavings / displayGoal) * 100.0).clamp(0.0, 100.0);
    } else if (displaySavings >= 0) {
      progressPercent = 100.0;
    } else {
      progressPercent = 0.0;
    }

    final double averageDailySavings = allowanceDaysCount > 0
        ? (totalAllowanceSavings / 100.0) / allowanceDaysCount
        : 0.0;

    final double averageDailyExpenses = allowanceDaysCount > 0
        ? (totalExpenses / 100.0) / allowanceDaysCount
        : 0.0;

    final double averageDailyAllowance = allowanceDaysCount > 0
        ? ((totalAllowanceSavings + totalExpenses) / 100.0) / allowanceDaysCount
        : 0.0;

    final double burnRatePercent = averageDailyAllowance > 0
        ? (averageDailyExpenses / averageDailyAllowance) * 100.0
        : 0.0;

    // 4. Estimated Days Text
    int? daysNeeded;
    final String estimatedDaysText;
    if (allowanceDaysCount == 0) {
      estimatedDaysText = 'Start tracking allowance days to estimate';
    } else if (displayRemaining <= 0) {
      estimatedDaysText = 'Goal reached!';
    } else if (averageDailySavings <= 0) {
      estimatedDaysText = 'N/A (Average savings is <= 0)';
    } else {
      daysNeeded = (displayRemaining / averageDailySavings).ceil();
      estimatedDaysText = '$daysNeeded allowance day${daysNeeded > 1 ? "s" : ""}';
    }

    // 5. Pacing Status
    final String pacingStatus;
    if (allowanceDaysCount == 0) {
      pacingStatus = 'N/A';
    } else if (burnRatePercent > 100) {
      pacingStatus = 'Overspending';
    } else if (burnRatePercent >= 80) {
      pacingStatus = 'High Burn';
    } else {
      pacingStatus = 'On Track';
    }

    // 6. Smart Budget Tip Formula
    final String smartBudgetTip;
    if (allowanceDaysCount == 0) {
      smartBudgetTip =
          'Start recording your daily expenses in the calendar to generate personalized budgeting tips.';
    } else if (displayRemaining == 0 && displayGoal > 0) {
      smartBudgetTip =
          'Congratulations! You have reached your savings goal. Consider setting a new target in settings.';
    } else if (averageDailySavings <= 0) {
      smartBudgetTip =
          'Your current average daily savings is negative or zero. Try reducing non-essential categories like Shopping or Entertainment this week.';
    } else if (daysNeeded != null && daysNeeded > 60) {
      final extraRequired = max(0.0, (displayRemaining / 30.0) - averageDailySavings);
      smartBudgetTip =
          'To hit your goal in 30 days, you need to save an extra ${formatCurrency(extraRequired, settings.currencySymbol)} daily. Try cutting down on high-spend items.';
    } else {
      smartBudgetTip =
          'At your current savings rate, you are on track! Tip: Keeping your daily spend below ${formatCurrency(averageDailyExpenses * 0.9, settings.currencySymbol)} can speed up your goal by 10%.';
    }

    return GoalMetrics(
      totalSavings: totalSavings,
      totalAllowanceSavings: totalAllowanceSavings,
      totalExpenses: totalExpenses,
      allowanceDaysCount: allowanceDaysCount,
      displayGoal: displayGoal,
      displaySavings: displaySavings,
      displayRemaining: displayRemaining,
      progressPercent: progressPercent,
      averageDailySavings: averageDailySavings,
      averageDailyExpenses: averageDailyExpenses,
      averageDailyAllowance: averageDailyAllowance,
      burnRatePercent: burnRatePercent,
      daysNeeded: daysNeeded,
      estimatedDaysText: estimatedDaysText,
      pacingStatus: pacingStatus,
      smartBudgetTip: smartBudgetTip,
    );
  }
}

final goalCalculationProvider = Provider<GoalMetrics>((ref) {
  final settings = ref.watch(settingsProvider);
  final recordsMap = ref.watch(recordsProvider);
  return GoalMetrics.calculate(settings: settings, records: recordsMap.values);
});

