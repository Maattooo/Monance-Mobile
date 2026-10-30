import 'package:flutter/material.dart';
import '../../models/category_model.dart';

class DefaultCategories {
  DefaultCategories._();

  static const String food = 'Food';
  static const String transport = 'Transport';
  static const String study = 'Study';
  static const String shopping = 'Shopping';
  static const String hangout = 'Hangout';
  static const String bills = 'Bills';
  static const String other = 'Other';

  static const String fallbackColorHex = '#64748B';

  static const Map<String, String> defaultCategoryHexMap = {
    food: '#EAB308',
    transport: '#3B82F6',
    study: '#6366F1',
    shopping: '#EF4444',
    hangout: '#A855F7',
    bills: '#06B6D4',
    other: '#64748B',
  };

  static List<CategoryModel> get defaults => const [
        CategoryModel(name: food, colorHex: '#EAB308', sortOrder: 0),
        CategoryModel(name: transport, colorHex: '#3B82F6', sortOrder: 1),
        CategoryModel(name: study, colorHex: '#6366F1', sortOrder: 2),
        CategoryModel(name: shopping, colorHex: '#EF4444', sortOrder: 3),
        CategoryModel(name: hangout, colorHex: '#A855F7', sortOrder: 4),
        CategoryModel(name: bills, colorHex: '#06B6D4', sortOrder: 5),
        CategoryModel(name: other, colorHex: '#64748B', sortOrder: 6),
      ];

  /// Resolves the hex code for a category name, checking custom categories first,
  /// then defaults, falling back to #64748B.
  static String getCategoryColorHex(String? categoryName, [List<CategoryModel>? customCategories]) {
    if (categoryName == null || categoryName.trim().isEmpty) {
      return fallbackColorHex;
    }

    if (customCategories != null && customCategories.isNotEmpty) {
      final match = customCategories.firstWhere(
        (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
        orElse: () => const CategoryModel(name: '', colorHex: ''),
      );
      if (match.colorHex.isNotEmpty) {
        return match.colorHex;
      }
    }

    for (final entry in defaultCategoryHexMap.entries) {
      if (entry.key.toLowerCase() == categoryName.toLowerCase()) {
        return entry.value;
      }
    }

    return fallbackColorHex;
  }

  /// Resolves the Color for a category name with fallback to #64748B.
  static Color getCategoryColor(String? categoryName, [List<CategoryModel>? customCategories]) {
    final hex = getCategoryColorHex(categoryName, customCategories).replaceAll('#', '');
    try {
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF64748B);
    }
  }
}
