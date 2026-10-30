import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import '../core/database/app_database.dart';

class HangoutExpenseModel {
  final String id;
  final String sessionId;
  final String title;
  final int totalAmount; // in cents (> 0)
  final int perPersonAmount; // base share in cents
  final String paidBy; // Defaults to 'You'
  final String splitType; // 'equal' | 'custom'
  final List<String> participants;
  final int timestamp;

  const HangoutExpenseModel({
    required this.id,
    required this.sessionId,
    required this.title,
    required this.totalAmount,
    required this.perPersonAmount,
    this.paidBy = 'You',
    this.splitType = 'equal',
    required this.participants,
    required this.timestamp,
  });

  factory HangoutExpenseModel.fromDrift(HangoutExpensesTableData data) {
    List<String> parsedParticipants = [];
    try {
      final decoded = jsonDecode(data.participantsJson);
      if (decoded is List) {
        parsedParticipants = decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {
      parsedParticipants = ['You'];
    }

    return HangoutExpenseModel(
      id: data.id,
      sessionId: data.sessionId,
      title: data.title,
      totalAmount: data.totalAmount,
      perPersonAmount: data.perPersonAmount,
      paidBy: data.paidBy,
      splitType: data.splitType,
      participants: parsedParticipants,
      timestamp: data.timestamp,
    );
  }

  HangoutExpensesTableCompanion toCompanion() {
    return HangoutExpensesTableCompanion(
      id: drift.Value(id),
      sessionId: drift.Value(sessionId),
      title: drift.Value(title),
      totalAmount: drift.Value(totalAmount),
      perPersonAmount: drift.Value(perPersonAmount),
      paidBy: drift.Value(paidBy),
      splitType: drift.Value(splitType),
      participantsJson: drift.Value(jsonEncode(participants)),
      timestamp: drift.Value(timestamp),
    );
  }

  factory HangoutExpenseModel.fromJson(Map<String, dynamic> json) {
    int parseCents(dynamic val) {
      if (val is num) return val.round();
      if (val is String) return (double.tryParse(val) ?? 0.0).round();
      return 0;
    }

    final rawParticipants = json['participants'] ?? json['participantsJson'];
    List<String> parts = [];
    if (rawParticipants is List) {
      parts = rawParticipants.map((e) => e.toString()).toList();
    } else if (rawParticipants is String) {
      try {
        final decoded = jsonDecode(rawParticipants);
        if (decoded is List) {
          parts = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        parts = [rawParticipants];
      }
    }
    if (parts.isEmpty) {
      parts = ['You'];
    }

    final total = parseCents(json['totalAmount'] ?? json['amount']);
    final rawPerPerson = json['perPersonAmount'];
    int perPerson = rawPerPerson != null ? parseCents(rawPerPerson) : (parts.isNotEmpty ? total ~/ parts.length : total);

    final rawTimestamp = json['timestamp'] ?? json['createdAt'];
    int parsedTimestamp = DateTime.now().millisecondsSinceEpoch;
    if (rawTimestamp is num) {
      parsedTimestamp = rawTimestamp.toInt();
    } else if (rawTimestamp is String) {
      parsedTimestamp = DateTime.tryParse(rawTimestamp)?.millisecondsSinceEpoch ?? parsedTimestamp;
    }

    return HangoutExpenseModel(
      id: json['id'] as String? ?? 'hexp_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: json['sessionId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      totalAmount: total,
      perPersonAmount: perPerson,
      paidBy: json['paidBy'] as String? ?? 'You',
      splitType: json['splitType'] as String? ?? 'equal',
      participants: parts,
      timestamp: parsedTimestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'title': title,
      'totalAmount': totalAmount,
      'perPersonAmount': perPersonAmount,
      'paidBy': paidBy,
      'splitType': splitType,
      'participants': participants,
      'participantsJson': jsonEncode(participants),
      'timestamp': timestamp,
    };
  }

  HangoutExpenseModel copyWith({
    String? id,
    String? sessionId,
    String? title,
    int? totalAmount,
    int? perPersonAmount,
    String? paidBy,
    String? splitType,
    List<String>? participants,
    int? timestamp,
  }) {
    return HangoutExpenseModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      totalAmount: totalAmount ?? this.totalAmount,
      perPersonAmount: perPersonAmount ?? this.perPersonAmount,
      paidBy: paidBy ?? this.paidBy,
      splitType: splitType ?? this.splitType,
      participants: participants ?? this.participants,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HangoutExpenseModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sessionId == other.sessionId &&
          title == other.title &&
          totalAmount == other.totalAmount &&
          perPersonAmount == other.perPersonAmount &&
          paidBy == other.paidBy &&
          splitType == other.splitType &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      id.hashCode ^
      sessionId.hashCode ^
      title.hashCode ^
      totalAmount.hashCode ^
      perPersonAmount.hashCode ^
      paidBy.hashCode ^
      splitType.hashCode ^
      timestamp.hashCode;
}

