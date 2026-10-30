import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'hangout_expense_model.dart';
import '../core/database/app_database.dart';

class HangoutSessionModel {
  final String id;
  final String title;
  final String date; // YYYY-MM-DD
  final List<String> people; // Always includes "You"
  final bool isDeleted;
  final int createdAt;
  final int updatedAt;
  final List<HangoutExpenseModel> expenses;

  const HangoutSessionModel({
    required this.id,
    required this.title,
    required this.date,
    required this.people,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.expenses = const [],
  });

  int get totalSpent => expenses.fold(0, (sum, e) => sum + e.totalAmount);

  factory HangoutSessionModel.fromDrift(
    HangoutSessionsTableData data, [
    List<HangoutExpenseModel> expenses = const [],
  ]) {
    List<String> parsedPeople = [];
    try {
      final decoded = jsonDecode(data.peopleJson);
      if (decoded is List) {
        parsedPeople = decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {
      parsedPeople = ['You'];
    }
    if (!parsedPeople.contains('You')) {
      parsedPeople.insert(0, 'You');
    }

    return HangoutSessionModel(
      id: data.id,
      title: data.title,
      date: data.date,
      people: parsedPeople,
      isDeleted: data.isDeleted,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      expenses: expenses,
    );
  }

  HangoutSessionsTableCompanion toCompanion() {
    final effectivePeople = List<String>.from(people);
    if (!effectivePeople.contains('You')) {
      effectivePeople.insert(0, 'You');
    }

    return HangoutSessionsTableCompanion(
      id: drift.Value(id),
      title: drift.Value(title),
      date: drift.Value(date),
      peopleJson: drift.Value(jsonEncode(effectivePeople)),
      isDeleted: drift.Value(isDeleted),
      createdAt: drift.Value(createdAt),
      updatedAt: drift.Value(updatedAt),
    );
  }

  factory HangoutSessionModel.fromJson(Map<String, dynamic> json) {
    final rawPeople = json['people'] ?? json['peopleJson'];
    List<String> parsedPeople = [];
    if (rawPeople is List) {
      parsedPeople = rawPeople.map((e) => e.toString()).toList();
    } else if (rawPeople is String) {
      try {
        final decoded = jsonDecode(rawPeople);
        if (decoded is List) {
          parsedPeople = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        parsedPeople = [rawPeople];
      }
    }
    if (!parsedPeople.contains('You')) {
      parsedPeople.insert(0, 'You');
    }

    final rawExpenses = json['expenses'];
    List<HangoutExpenseModel> parsedExpenses = [];
    if (rawExpenses is List) {
      for (final item in rawExpenses) {
        if (item is Map) {
          parsedExpenses.add(HangoutExpenseModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final rawCreatedAt = json['createdAt'];
    int parsedCreatedAt = DateTime.now().millisecondsSinceEpoch;
    if (rawCreatedAt is num) {
      parsedCreatedAt = rawCreatedAt.toInt();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt)?.millisecondsSinceEpoch ?? parsedCreatedAt;
    }

    final rawUpdatedAt = json['updatedAt'];
    int parsedUpdatedAt = DateTime.now().millisecondsSinceEpoch;
    if (rawUpdatedAt is num) {
      parsedUpdatedAt = rawUpdatedAt.toInt();
    } else if (rawUpdatedAt is String) {
      parsedUpdatedAt = DateTime.tryParse(rawUpdatedAt)?.millisecondsSinceEpoch ?? parsedUpdatedAt;
    }

    return HangoutSessionModel(
      id: json['id'] as String? ?? 'sess_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? '',
      date: json['date'] as String? ?? '',
      people: parsedPeople,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
      expenses: parsedExpenses,
    );
  }

  Map<String, dynamic> toJson() {
    final effectivePeople = List<String>.from(people);
    if (!effectivePeople.contains('You')) {
      effectivePeople.insert(0, 'You');
    }

    return {
      'id': id,
      'title': title,
      'date': date,
      'people': effectivePeople,
      'peopleJson': jsonEncode(effectivePeople),
      'isDeleted': isDeleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'expenses': expenses.map((e) => e.toJson()).toList(),
    };
  }

  HangoutSessionModel copyWith({
    String? id,
    String? title,
    String? date,
    List<String>? people,
    bool? isDeleted,
    int? createdAt,
    int? updatedAt,
    List<HangoutExpenseModel>? expenses,
  }) {
    return HangoutSessionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      people: people ?? this.people,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expenses: expenses ?? this.expenses,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HangoutSessionModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          date == other.date &&
          isDeleted == other.isDeleted &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      date.hashCode ^
      isDeleted.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}

