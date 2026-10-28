import 'category_model.dart';

class SettingsModel {
  final int defaultAllowance; // in cents
  final int goalAmount;       // in cents
  final int currentBalance;   // in cents (cash in wallet)
  final String? goalStartDate;
  final List<CategoryModel> categories;

  SettingsModel({
    this.defaultAllowance = 0,
    this.goalAmount = 0,
    this.currentBalance = 0,
    this.goalStartDate,
    this.categories = const [],
  });

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
    if (parsedCategories.isEmpty) {
      parsedCategories = CategoryModel.defaultCategories;
    }

    return SettingsModel(
      defaultAllowance: parseCents(json['defaultAllowance']),
      goalAmount: parseCents(json['goalAmount']),
      currentBalance: parseCents(json['currentBalance']),
      goalStartDate: json['goalStartDate'] as String?,
      categories: parsedCategories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultAllowance': defaultAllowance,
      'goalAmount': goalAmount,
      'currentBalance': currentBalance,
      'goalStartDate': goalStartDate,
      'categories': categories.map((c) => c.toJson()).toList(),
    };
  }

  SettingsModel copyWith({
    int? defaultAllowance,
    int? goalAmount,
    int? currentBalance,
    String? goalStartDate,
    List<CategoryModel>? categories,
  }) {
    return SettingsModel(
      defaultAllowance: defaultAllowance ?? this.defaultAllowance,
      goalAmount: goalAmount ?? this.goalAmount,
      currentBalance: currentBalance ?? this.currentBalance,
      goalStartDate: goalStartDate ?? this.goalStartDate,
      categories: categories ?? this.categories,
    );
  }
}
