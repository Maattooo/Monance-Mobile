import 'package:drift/drift.dart' as drift;
import '../core/database/app_database.dart';

class MonthlyBillModel {
  final String id;
  final String title;
  final int amount; // in cents (> 0)
  final int dueDay; // 1..31
  final bool isPaid;
  final int sortOrder;

  const MonthlyBillModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDay,
    this.isPaid = false,
    this.sortOrder = 0,
  });

  factory MonthlyBillModel.fromDrift(MonthlyBillsTableData data) {
    return MonthlyBillModel(
      id: data.id,
      title: data.title,
      amount: data.amount,
      dueDay: data.dueDay,
      isPaid: data.isPaid,
      sortOrder: data.sortOrder,
    );
  }

  MonthlyBillsTableCompanion toCompanion() {
    return MonthlyBillsTableCompanion(
      id: drift.Value(id),
      title: drift.Value(title),
      amount: drift.Value(amount),
      dueDay: drift.Value(dueDay),
      isPaid: drift.Value(isPaid),
      sortOrder: drift.Value(sortOrder),
    );
  }

  factory MonthlyBillModel.fromJson(Map<String, dynamic> json) {
    int parseCents(dynamic val) {
      if (val is num) return val.round();
      if (val is String) return (double.tryParse(val) ?? 0.0).round();
      return 0;
    }

    final rawDue = json['dueDay'] ?? json['due_day'];
    int due = 1;
    if (rawDue is num) {
      due = rawDue.toInt();
    } else if (rawDue is String) {
      due = int.tryParse(rawDue) ?? 1;
    }

    final rawSort = json['sortOrder'] ?? json['sort_order'];
    int sort = 0;
    if (rawSort is num) {
      sort = rawSort.toInt();
    } else if (rawSort is String) {
      sort = int.tryParse(rawSort) ?? 0;
    }

    return MonthlyBillModel(
      id: json['id'] as String? ?? 'bill_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? '',
      amount: parseCents(json['amount']),
      dueDay: due,
      isPaid: json['isPaid'] as bool? ?? false,
      sortOrder: sort,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'dueDay': dueDay,
      'isPaid': isPaid,
      'sortOrder': sortOrder,
    };
  }

  MonthlyBillModel copyWith({
    String? id,
    String? title,
    int? amount,
    int? dueDay,
    bool? isPaid,
    int? sortOrder,
  }) {
    return MonthlyBillModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDay: dueDay ?? this.dueDay,
      isPaid: isPaid ?? this.isPaid,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyBillModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          amount == other.amount &&
          dueDay == other.dueDay &&
          isPaid == other.isPaid &&
          sortOrder == other.sortOrder;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      amount.hashCode ^
      dueDay.hashCode ^
      isPaid.hashCode ^
      sortOrder.hashCode;
}
