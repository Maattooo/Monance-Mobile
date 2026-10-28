import 'package:flutter/material.dart';

class CategoryModel {
  final String name;
  final String colorHex;

  CategoryModel({
    required this.name,
    required this.colorHex,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      name: json['name'] as String? ?? 'Other',
      colorHex: json['color'] as String? ?? '#64748b',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': colorHex,
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

  static List<CategoryModel> get defaultCategories => [
        CategoryModel(name: 'Food', colorHex: '#eab308'),
        CategoryModel(name: 'Transport', colorHex: '#3b82f6'),
        CategoryModel(name: 'Study', colorHex: '#6366f1'),
        CategoryModel(name: 'Shopping', colorHex: '#ef4444'),
        CategoryModel(name: 'Hangout', colorHex: '#a855f7'),
        CategoryModel(name: 'Bills', colorHex: '#06b6d4'),
        CategoryModel(name: 'Other', colorHex: '#64748b'),
      ];
}
