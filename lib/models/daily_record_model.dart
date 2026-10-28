import 'expense_model.dart';

class DailyRecordModel {
  final String date; // YYYY-MM-DD
  final String title;
  final int startingMoney; // in cents
  final List<ExpenseModel> expenses;
  final bool isDeleted;
  final int updatedAt; // Milliseconds timestamp

  DailyRecordModel({
    required this.date,
    this.title = 'school',
    this.startingMoney = 0,
    this.expenses = const [],
    this.isDeleted = false,
    required this.updatedAt,
  });

  /// Total of daily allowance deductions
  int get dailyExpensesTotal {
    return expenses
        .where((e) => e.deductionType == 'daily')
        .fold(0, (sum, e) => sum + e.amount);
  }

  /// Total of wallet balance deductions
  int get walletExpensesTotal {
    return expenses
        .where((e) => e.deductionType == 'wallet')
        .fold(0, (sum, e) => sum + e.amount);
  }

  /// Total of all expenses
  int get totalExpenses {
    return expenses.fold(0, (sum, e) => sum + e.amount);
  }

  /// Remaining daily allowance for this date
  int get remainingDailyAllowance {
    return startingMoney - dailyExpensesTotal;
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
}
