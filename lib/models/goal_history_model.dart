import 'package:drift/drift.dart' as drift;
import '../core/database/app_database.dart';

class GoalHistoryModel {
  final String id;
  final int amount; // Target goal amount in cents
  final int saved; // Total saved in cents at archive time
  final String? startDate; // YYYY-MM-DD
  final String endDate; // YYYY-MM-DD or ISO-8601
  final int archivedAt; // Milliseconds timestamp

  const GoalHistoryModel({
    required this.id,
    required this.amount,
    required this.saved,
    this.startDate,
    required this.endDate,
    required this.archivedAt,
  });

  factory GoalHistoryModel.fromDrift(GoalHistoryTableData data) {
    return GoalHistoryModel(
      id: data.id,
      amount: data.amount,
      saved: data.saved,
      startDate: data.startDate,
      endDate: data.endDate,
      archivedAt: data.archivedAt,
    );
  }

  GoalHistoryTableCompanion toCompanion() {
    return GoalHistoryTableCompanion(
      id: drift.Value(id),
      amount: drift.Value(amount),
      saved: drift.Value(saved),
      startDate: drift.Value(startDate),
      endDate: drift.Value(endDate),
      archivedAt: drift.Value(archivedAt),
    );
  }

  factory GoalHistoryModel.fromJson(Map<String, dynamic> json) {
    int parseCents(dynamic val) {
      if (val is num) return val.round();
      if (val is String) return (double.tryParse(val) ?? 0.0).round();
      return 0;
    }

    final rawArchivedAt = json['archivedAt'];
    int parsedArchivedAt = DateTime.now().millisecondsSinceEpoch;
    if (rawArchivedAt is num) {
      parsedArchivedAt = rawArchivedAt.toInt();
    } else if (rawArchivedAt is String) {
      parsedArchivedAt = DateTime.tryParse(rawArchivedAt)?.millisecondsSinceEpoch ??
          int.tryParse(rawArchivedAt) ??
          parsedArchivedAt;
    }

    return GoalHistoryModel(
      id: json['id'] as String? ?? 'gh_${DateTime.now().millisecondsSinceEpoch}',
      amount: parseCents(json['amount']),
      saved: parseCents(json['saved']),
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String? ?? '',
      archivedAt: parsedArchivedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'saved': saved,
      'startDate': startDate,
      'endDate': endDate,
      'archivedAt': archivedAt,
    };
  }

  GoalHistoryModel copyWith({
    String? id,
    int? amount,
    int? saved,
    String? startDate,
    String? endDate,
    int? archivedAt,
  }) {
    return GoalHistoryModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      saved: saved ?? this.saved,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalHistoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          amount == other.amount &&
          saved == other.saved &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          archivedAt == other.archivedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      amount.hashCode ^
      saved.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      archivedAt.hashCode;
}

