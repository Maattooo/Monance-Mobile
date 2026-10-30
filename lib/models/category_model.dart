import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../core/database/app_database.dart';

class CategoryModel {
  final String name;
  final String colorHex;
  final int sortOrder;

  const CategoryModel({
    required this.name,
    required this.colorHex,
    this.sortOrder = 0,
  });

  factory CategoryModel.fromDrift(CategoriesTableData data) {
    return CategoryModel(
      name: data.name,
      colorHex: data.colorHex,
      sortOrder: data.sortOrder,
    );
  }

  CategoriesTableCompanion toCompanion() {
    return CategoriesTableCompanion(
      name: drift.Value(name),
      colorHex: drift.Value(colorHex),
      sortOrder: drift.Value(sortOrder),
    );
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final rawColor = json['colorHex'] ?? json['color'] ?? '#64748B';
    final rawSort = json['sortOrder'];
    int sort = 0;
    if (rawSort is num) {
      sort = rawSort.toInt();
    } else if (rawSort is String) {
      sort = int.tryParse(rawSort) ?? 0;
    }

    return CategoryModel(
      name: json['name'] as String? ?? 'Other',
      colorHex: rawColor.toString(),
      sortOrder: sort,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'colorHex': colorHex,
      'color': colorHex, // for backward compatibility
      'sortOrder': sortOrder,
    };
  }

  Color get color {
    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF64748B);
    }
  }

  CategoryModel copyWith({
    String? name,
    String? colorHex,
    int? sortOrder,
  }) {
    return CategoryModel(
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  static List<CategoryModel> get defaultCategories => const [
        CategoryModel(name: 'Food', colorHex: '#EAB308', sortOrder: 0),
        CategoryModel(name: 'Transport', colorHex: '#3B82F6', sortOrder: 1),
        CategoryModel(name: 'Study', colorHex: '#6366F1', sortOrder: 2),
        CategoryModel(name: 'Shopping', colorHex: '#EF4444', sortOrder: 3),
        CategoryModel(name: 'Hangout', colorHex: '#A855F7', sortOrder: 4),
        CategoryModel(name: 'Bills', colorHex: '#06B6D4', sortOrder: 5),
        CategoryModel(name: 'Other', colorHex: '#64748B', sortOrder: 6),
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          colorHex.toLowerCase() == other.colorHex.toLowerCase() &&
          sortOrder == other.sortOrder;

  @override
  int get hashCode => name.hashCode ^ colorHex.toLowerCase().hashCode ^ sortOrder.hashCode;
}
