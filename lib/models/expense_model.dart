import 'package:drift/drift.dart' as drift;
import '../core/database/app_database.dart';

class ExpenseModel {
  final String id;
  final String date;
  final String title;
  final int amount; // in cents (> 0)
  final String category;
  final String deductFrom; // 'allowance' | 'balance'
  final int timestamp; // Milliseconds since epoch

  const ExpenseModel({
    required this.id,
    this.date = '',
    required this.title,
    required this.amount,
    this.category = 'Other',
    this.deductFrom = 'allowance',
    required this.timestamp,
  });

  /// Legacy backward compatibility getter
  String get deductionType => deductFrom == 'balance' ? 'wallet' : 'daily';

  factory ExpenseModel.fromDrift(ExpensesTableData data) {
    return ExpenseModel(
      id: data.id,
      date: data.date,
      title: data.title,
      amount: data.amount,
      category: data.category,
      deductFrom: data.deductFrom,
      timestamp: data.timestamp,
    );
  }

  ExpensesTableCompanion toCompanion() {
    return ExpensesTableCompanion(
      id: drift.Value(id),
      date: drift.Value(date),
      title: drift.Value(title),
      amount: drift.Value(amount),
      category: drift.Value(category),
      deductFrom: drift.Value(deductFrom),
      timestamp: drift.Value(timestamp),
    );
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    // Robust conversion for amount which can be int or double from JSON
    final rawAmount = json['amount'];
    int parsedAmount = 0;
    if (rawAmount is num) {
      parsedAmount = rawAmount.round();
    } else if (rawAmount is String) {
      parsedAmount = (double.tryParse(rawAmount) ?? 0.0).round();
    }

    // Robust timestamp parsing
    final rawTime = json['timestamp'] ?? json['createdAt'];
    int parsedTime = DateTime.now().millisecondsSinceEpoch;
    if (rawTime is num) {
      parsedTime = rawTime.toInt();
    } else if (rawTime is String) {
      parsedTime = DateTime.tryParse(rawTime)?.millisecondsSinceEpoch ?? parsedTime;
    }

    // AUDIT-002: Map legacy 'daily' -> 'allowance' and 'wallet' -> 'balance'
    final rawDeduct = (json['deductFrom'] ?? json['deductionType'] ?? 'allowance').toString().toLowerCase();
    final String deductFrom;
    if (rawDeduct == 'balance' || rawDeduct == 'wallet') {
      deductFrom = 'balance';
    } else {
      deductFrom = 'allowance';
    }

    return ExpenseModel(
      id: (json['id'] ?? json['_id'] ?? 'exp_${DateTime.now().millisecondsSinceEpoch}').toString(),
      date: json['date'] as String? ?? '',
      title: json['title'] as String? ?? '',
      amount: parsedAmount,
      category: json['category'] as String? ?? 'Other',
      deductFrom: deductFrom,
      timestamp: parsedTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'title': title,
      'amount': amount,
      'category': category,
      'deductFrom': deductFrom,
      'deductionType': deductionType, // for backward compatibility
      'timestamp': timestamp,
    };
  }

  ExpenseModel copyWith({
    String? id,
    String? date,
    String? title,
    int? amount,
    String? category,
    String? deductFrom,
    int? timestamp,
    // Support legacy copyWith parameter
    String? deductionType,
  }) {
    final effectiveDeduct = deductFrom ?? (deductionType != null ? (deductionType == 'wallet' ? 'balance' : 'allowance') : this.deductFrom);
    return ExpenseModel(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      deductFrom: effectiveDeduct,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          date == other.date &&
          title == other.title &&
          amount == other.amount &&
          category == other.category &&
          deductFrom == other.deductFrom &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      id.hashCode ^
      date.hashCode ^
      title.hashCode ^
      amount.hashCode ^
      category.hashCode ^
      deductFrom.hashCode ^
      timestamp.hashCode;
}
