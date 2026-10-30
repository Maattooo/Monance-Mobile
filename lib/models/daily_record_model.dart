import 'package:drift/drift.dart' as drift;
import 'expense_model.dart';
import '../core/database/app_database.dart';

class DailyRecordModel {
  final String date; // YYYY-MM-DD
  final String title;
  final int startingMoney; // in cents
  final List<ExpenseModel> expenses;
  final bool isDeleted;
  final int updatedAt; // Milliseconds timestamp

  const DailyRecordModel({
    required this.date,
    this.title = 'school',
    this.startingMoney = 0,
    this.expenses = const [],
    this.isDeleted = false,
    required this.updatedAt,
  });

  /// Total sum of expenses deducted from allowance (deductFrom != 'balance')
  int get allowanceExpensesSum {
    return expenses
        .where((e) => e.deductFrom != 'balance')
        .fold(0, (sum, e) => sum + e.amount);
  }

  /// Total sum of expenses deducted from balance / wallet (deductFrom == 'balance')
  int get balanceExpensesSum {
    return expenses
        .where((e) => e.deductFrom == 'balance')
        .fold(0, (sum, e) => sum + e.amount);
  }

  /// Remaining allowance for this date: startingMoney - allowanceExpensesSum
  int get remainingAllowance {
    return startingMoney - allowanceExpensesSum;
  }

  /// Legacy compatibility getters
  int get dailyExpensesTotal => allowanceExpensesSum;
  int get walletExpensesTotal => balanceExpensesSum;
  int get remainingDailyAllowance => remainingAllowance;
  int get totalExpenses => expenses.fold(0, (sum, e) => sum + e.amount);

  factory DailyRecordModel.fromDrift(
    DailyRecordsTableData data, [
    List<ExpenseModel> expenses = const [],
  ]) {
    return DailyRecordModel(
      date: data.date,
      title: data.title,
      startingMoney: data.startingMoney,
      expenses: expenses,
      isDeleted: data.isDeleted,
      updatedAt: data.updatedAt,
    );
  }

  DailyRecordsTableCompanion toCompanion() {
    return DailyRecordsTableCompanion(
      date: drift.Value(date),
      title: drift.Value(title),
      startingMoney: drift.Value(startingMoney),
      isDeleted: drift.Value(isDeleted),
      updatedAt: drift.Value(updatedAt),
    );
  }

  factory DailyRecordModel.fromJson(Map<String, dynamic> json) {
    final rawStarting = json['startingMoney'];
    int parsedStarting = 0;
    if (rawStarting is num) {
      parsedStarting = rawStarting.round();
    } else if (rawStarting is String) {
      parsedStarting = (double.tryParse(rawStarting) ?? 0.0).round();
    }

    final rawExpenses = json['expenses'];
    List<ExpenseModel> parsedExpenses = [];
    if (rawExpenses is List) {
      for (final item in rawExpenses) {
        if (item is Map) {
          parsedExpenses.add(ExpenseModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final rawUpdatedAt = json['updatedAt'];
    int parsedUpdatedAt = DateTime.now().millisecondsSinceEpoch;
    if (rawUpdatedAt is num) {
      parsedUpdatedAt = rawUpdatedAt.toInt();
    } else if (rawUpdatedAt is String) {
      parsedUpdatedAt = DateTime.tryParse(rawUpdatedAt)?.millisecondsSinceEpoch ?? parsedUpdatedAt;
    }

    return DailyRecordModel(
      date: json['date'] as String? ?? '',
      title: json['title'] as String? ?? 'school',
      startingMoney: parsedStarting,
      expenses: parsedExpenses,
      isDeleted: json['isDeleted'] as bool? ?? false,
      updatedAt: parsedUpdatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'title': title,
      'startingMoney': startingMoney,
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'isDeleted': isDeleted,
      'updatedAt': updatedAt,
    };
  }

  DailyRecordModel copyWith({
    String? date,
    String? title,
    int? startingMoney,
    List<ExpenseModel>? expenses,
    bool? isDeleted,
    int? updatedAt,
  }) {
    return DailyRecordModel(
      date: date ?? this.date,
      title: title ?? this.title,
      startingMoney: startingMoney ?? this.startingMoney,
      expenses: expenses ?? this.expenses,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordModel &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          title == other.title &&
          startingMoney == other.startingMoney &&
          isDeleted == other.isDeleted &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      date.hashCode ^
      title.hashCode ^
      startingMoney.hashCode ^
      isDeleted.hashCode ^
      updatedAt.hashCode;
}
