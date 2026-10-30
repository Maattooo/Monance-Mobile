import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../models/daily_record_model.dart';
import 'records_provider.dart';
import 'settings_provider.dart';

class CategoryBreakdownItem {
  final String category;
  final String colorHex;
  final int amountCents;
  final double percentage; // 0.0 .. 100.0

  const CategoryBreakdownItem({
    required this.category,
    required this.colorHex,
    required this.amountCents,
    required this.percentage,
  });

  @override
  String toString() =>
      'CategoryBreakdownItem($category, amount: $amountCents, pct: $percentage%, color: $colorHex)';
}

class MonthOverMonthComparison {
  final bool hasPreviousData;
  final double percentageChange;
  final int previousTotalCents;

  const MonthOverMonthComparison({
    required this.hasPreviousData,
    required this.percentageChange,
    required this.previousTotalCents,
  });

  @override
  String toString() =>
      'MonthOverMonthComparison(hasPrev: $hasPreviousData, pctChange: $percentageChange%, prevTotal: $previousTotalCents)';
}

class AnalyticsData {
  final String selectedFilter; // 'ALL' or 'YYYY-MM'
  final int totalExpensesCents;
  final List<CategoryBreakdownItem> categoryBreakdown;
  final CategoryBreakdownItem? topCategory;
  final MonthOverMonthComparison momComparison;
  final List<String> availableMonths;

  const AnalyticsData({
    required this.selectedFilter,
    required this.totalExpensesCents,
    required this.categoryBreakdown,
    required this.topCategory,
    required this.momComparison,
    required this.availableMonths,
  });
}

class AnalyticsEngine {
  AnalyticsEngine._();

  static const String fallbackCategoryColor = '#64748B';

  static String? getPrecedingMonth(String monthStr) {
    if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(monthStr)) return null;
    final year = int.parse(monthStr.substring(0, 4));
    final month = int.parse(monthStr.substring(5, 7));
    final prevYear = month == 1 ? year - 1 : year;
    final prevMonth = month == 1 ? 12 : month - 1;
    return '$prevYear-${prevMonth.toString().padLeft(2, '0')}';
  }

  static AnalyticsData calculate({
    required Map<String, DailyRecordModel> records,
    required List<CategoryModel> categories,
    required String selectedFilter,
  }) {
    // 1. Available months (distinct YYYY-MM from non-deleted records, sorted descending)
    final distinctMonths = <String>{};
    for (final record in records.values) {
      if (record.isDeleted) continue;
      if (record.date.length >= 7) {
        distinctMonths.add(record.date.substring(0, 7));
      }
    }
    final sortedMonths = distinctMonths.toList()..sort((a, b) => b.compareTo(a));

    // 2. Aggregate expenses for selected filter across non-deleted records
    final Map<String, int> amountsByCategory = {};
    int totalCents = 0;

    for (final record in records.values) {
      if (record.isDeleted) continue;
      if (selectedFilter != 'ALL' && !record.date.startsWith(selectedFilter)) {
        continue;
      }

      for (final exp in record.expenses) {
        amountsByCategory[exp.category] =
            (amountsByCategory[exp.category] ?? 0) + exp.amount;
        totalCents += exp.amount;
      }
    }

    // 3. Category breakdown with color resolution and percentage
    final categoryColorMap = {for (final c in categories) c.name: c.colorHex};
    final sortedEntries = amountsByCategory.entries.toList()
      ..sort((a, b) {
        final cmp = b.value.compareTo(a.value);
        if (cmp != 0) return cmp;
        return a.key.compareTo(b.key);
      });

    final List<CategoryBreakdownItem> breakdown = [];
    for (final entry in sortedEntries) {
      final catName = entry.key;
      final amount = entry.value;
      final colorHex = categoryColorMap[catName] ?? fallbackCategoryColor;
      final percentage = totalCents > 0 ? (amount / totalCents) * 100.0 : 0.0;
      breakdown.add(CategoryBreakdownItem(
        category: catName,
        colorHex: colorHex,
        amountCents: amount,
        percentage: percentage,
      ));
    }

    final topCategory = breakdown.isNotEmpty ? breakdown.first : null;

    // 4. Month-over-Month calculation
    MonthOverMonthComparison momComparison;
    final precedingMonth = getPrecedingMonth(selectedFilter);
    if (precedingMonth != null) {
      int prevTotal = 0;
      for (final record in records.values) {
        if (record.isDeleted) continue;
        if (record.date.startsWith(precedingMonth)) {
          for (final exp in record.expenses) {
            prevTotal += exp.amount;
          }
        }
      }

      if (prevTotal > 0) {
        final change = ((totalCents - prevTotal) / prevTotal) * 100.0;
        momComparison = MonthOverMonthComparison(
          hasPreviousData: true,
          percentageChange: change,
          previousTotalCents: prevTotal,
        );
      } else {
        momComparison = const MonthOverMonthComparison(
          hasPreviousData: false,
          percentageChange: 0.0,
          previousTotalCents: 0,
        );
      }
    } else {
      momComparison = const MonthOverMonthComparison(
        hasPreviousData: false,
        percentageChange: 0.0,
        previousTotalCents: 0,
      );
    }

    return AnalyticsData(
      selectedFilter: selectedFilter,
      totalExpensesCents: totalCents,
      categoryBreakdown: breakdown,
      topCategory: topCategory,
      momComparison: momComparison,
      availableMonths: sortedMonths,
    );
  }
}

final selectedMonthFilterProvider = StateProvider<String>((ref) => 'ALL');

final availableMonthsProvider = Provider<List<String>>((ref) {
  final records = ref.watch(recordsProvider);
  final distinctMonths = <String>{};
  for (final record in records.values) {
    if (record.isDeleted) continue;
    if (record.date.length >= 7) {
      distinctMonths.add(record.date.substring(0, 7));
    }
  }
  return distinctMonths.toList()..sort((a, b) => b.compareTo(a));
});

final analyticsProvider = Provider<AnalyticsData>((ref) {
  final filter = ref.watch(selectedMonthFilterProvider);
  final records = ref.watch(recordsProvider);
  final settings = ref.watch(settingsProvider);

  return AnalyticsEngine.calculate(
    records: records,
    categories: settings.categories,
    selectedFilter: filter,
  );
});

