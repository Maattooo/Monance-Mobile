import 'package:drift/drift.dart' as drift;
import 'category_model.dart';
import '../core/database/app_database.dart';

class SettingsModel {
  final int id;
  final int defaultAllowance; // in cents
  final int goalAmount; // in cents
  final int currentBalance; // in cents (base reserve)
  final String? goalStartDate; // YYYY-MM-DD
  final String currencyCode;
  final String currencySymbol;
  final String? lastBillsMonth; // YYYY-MM
  final bool themeIsDark;
  final bool privacyMode;
  final bool billNotificationsEnabled;
  final int updatedAt;
  final List<CategoryModel> categories;

  const SettingsModel({
    this.id = 1,
    this.defaultAllowance = 0,
    this.goalAmount = 0,
    this.currentBalance = 0,
    this.goalStartDate,
    this.currencyCode = 'PHP',
    this.currencySymbol = '₱',
    this.lastBillsMonth,
    this.themeIsDark = true,
    this.privacyMode = false,
    this.billNotificationsEnabled = false,
    this.updatedAt = 0,
    this.categories = const [],
  });

  factory SettingsModel.fromDrift(
    SettingsTableData data, [
    List<CategoryModel> categories = const [],
  ]) {
    return SettingsModel(
      id: data.id,
      defaultAllowance: data.defaultAllowance,
      goalAmount: data.goalAmount,
      currentBalance: data.currentBalance,
      goalStartDate: data.goalStartDate,
      currencyCode: data.currencyCode,
      currencySymbol: data.currencySymbol,
      lastBillsMonth: data.lastBillsMonth,
      themeIsDark: data.themeIsDark,
      privacyMode: data.privacyMode,
      billNotificationsEnabled: data.billNotificationsEnabled,
      updatedAt: data.updatedAt,
      categories: categories,
    );
  }

  SettingsTableCompanion toCompanion() {
    return SettingsTableCompanion(
      id: drift.Value(id),
      defaultAllowance: drift.Value(defaultAllowance),
      goalAmount: drift.Value(goalAmount),
      currentBalance: drift.Value(currentBalance),
      goalStartDate: drift.Value(goalStartDate),
      currencyCode: drift.Value(currencyCode),
      currencySymbol: drift.Value(currencySymbol),
      lastBillsMonth: drift.Value(lastBillsMonth),
      themeIsDark: drift.Value(themeIsDark),
      privacyMode: drift.Value(privacyMode),
      billNotificationsEnabled: drift.Value(billNotificationsEnabled),
      updatedAt: drift.Value(updatedAt == 0 ? DateTime.now().millisecondsSinceEpoch : updatedAt),
    );
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    int parseCents(dynamic val) {
      if (val is num) return val.round();
      if (val is String) return (double.tryParse(val) ?? 0.0).round();
      return 0;
    }

    final rawCategories = json['categories'];
    List<CategoryModel> parsedCategories = [];
    if (rawCategories is List && rawCategories.isNotEmpty) {
      for (final item in rawCategories) {
        if (item is Map) {
          parsedCategories.add(CategoryModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final rawUpdatedAt = json['updatedAt'];
    int parsedUpdatedAt = 0;
    if (rawUpdatedAt is num) {
      parsedUpdatedAt = rawUpdatedAt.toInt();
    } else if (rawUpdatedAt is String) {
      parsedUpdatedAt = int.tryParse(rawUpdatedAt) ?? 0;
    }

    return SettingsModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : 1,
      defaultAllowance: parseCents(json['defaultAllowance']),
      goalAmount: parseCents(json['goalAmount']),
      currentBalance: parseCents(json['currentBalance']),
      goalStartDate: json['goalStartDate'] as String?,
      currencyCode: json['currencyCode'] as String? ?? 'PHP',
      currencySymbol: json['currencySymbol'] as String? ?? '₱',
      lastBillsMonth: json['lastBillsMonth'] as String?,
      themeIsDark: json['themeIsDark'] as bool? ?? true,
      privacyMode: json['privacyMode'] as bool? ?? false,
      billNotificationsEnabled: json['billNotificationsEnabled'] as bool? ?? false,
      updatedAt: parsedUpdatedAt,
      categories: parsedCategories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'defaultAllowance': defaultAllowance,
      'goalAmount': goalAmount,
      'currentBalance': currentBalance,
      'goalStartDate': goalStartDate,
      'currencyCode': currencyCode,
      'currencySymbol': currencySymbol,
      'lastBillsMonth': lastBillsMonth,
      'themeIsDark': themeIsDark,
      'privacyMode': privacyMode,
      'billNotificationsEnabled': billNotificationsEnabled,
      'updatedAt': updatedAt,
      'categories': categories.map((c) => c.toJson()).toList(),
    };
  }

  SettingsModel copyWith({
    int? id,
    int? defaultAllowance,
    int? goalAmount,
    int? currentBalance,
    String? goalStartDate,
    String? currencyCode,
    String? currencySymbol,
    String? lastBillsMonth,
    bool? themeIsDark,
    bool? privacyMode,
    bool? billNotificationsEnabled,
    int? updatedAt,
    List<CategoryModel>? categories,
  }) {
    return SettingsModel(
      id: id ?? this.id,
      defaultAllowance: defaultAllowance ?? this.defaultAllowance,
      goalAmount: goalAmount ?? this.goalAmount,
      currentBalance: currentBalance ?? this.currentBalance,
      goalStartDate: goalStartDate ?? this.goalStartDate,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      lastBillsMonth: lastBillsMonth ?? this.lastBillsMonth,
      themeIsDark: themeIsDark ?? this.themeIsDark,
      privacyMode: privacyMode ?? this.privacyMode,
      billNotificationsEnabled: billNotificationsEnabled ?? this.billNotificationsEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
      categories: categories ?? this.categories,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          defaultAllowance == other.defaultAllowance &&
          goalAmount == other.goalAmount &&
          currentBalance == other.currentBalance &&
          goalStartDate == other.goalStartDate &&
          currencyCode == other.currencyCode &&
          currencySymbol == other.currencySymbol &&
          lastBillsMonth == other.lastBillsMonth &&
          themeIsDark == other.themeIsDark &&
          privacyMode == other.privacyMode &&
          billNotificationsEnabled == other.billNotificationsEnabled;

  @override
  int get hashCode =>
      id.hashCode ^
      defaultAllowance.hashCode ^
      goalAmount.hashCode ^
      currentBalance.hashCode ^
      goalStartDate.hashCode ^
      currencyCode.hashCode ^
      currencySymbol.hashCode ^
      lastBillsMonth.hashCode ^
      themeIsDark.hashCode ^
      privacyMode.hashCode ^
      billNotificationsEnabled.hashCode;
}
