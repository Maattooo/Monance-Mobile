import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../core/database/app_database.dart';
import '../core/constants/default_categories.dart';
import '../core/utils/date_utils_ext.dart';
import '../models/category_model.dart';
import '../models/goal_history_model.dart';
import '../models/settings_model.dart';
import '../services/local_notification_service.dart';
import 'bills_provider.dart';
import 'database_provider.dart';

class SettingsNotifier extends StateNotifier<SettingsModel> {
  final AppDatabase _db;
  final Ref? _ref;
  static const _uuid = Uuid();

  SettingsNotifier(this._db, [this._ref]) : super(const SettingsModel()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    // Ensure default categories exist in CategoriesTable
    final existingCategories = await _db.select(_db.categoriesTable).get();
    if (existingCategories.isEmpty) {
      await _db.batch((batch) {
        for (final cat in DefaultCategories.defaults) {
          batch.insert(
            _db.categoriesTable,
            cat.toCompanion(),
            mode: drift.InsertMode.insertOrIgnore,
          );
        }
      });
    }

    final categoriesList = (await (_db.select(_db.categoriesTable)
              ..orderBy([(t) => drift.OrderingTerm(expression: t.sortOrder)]))
            .get())
        .map(CategoryModel.fromDrift)
        .toList();

    // Query SettingsTable row (id == 1)
    final existingSettings = await (_db.select(_db.settingsTable)
          ..where((tbl) => tbl.id.equals(1)))
        .getSingleOrNull();

    if (existingSettings != null) {
      state = SettingsModel.fromDrift(existingSettings, categoriesList);
    } else {
      // Seed default settings row
      const initialSettings = SettingsModel(
        id: 1,
        defaultAllowance: 0,
        goalAmount: 0,
        currentBalance: 0,
        currencyCode: 'PHP',
        currencySymbol: '₱',
        themeIsDark: true,
        privacyMode: false,
        billNotificationsEnabled: false,
      );
      await _db.into(_db.settingsTable).insert(
            initialSettings.toCompanion(),
            mode: drift.InsertMode.insertOrReplace,
          );
      final inserted = await (_db.select(_db.settingsTable)
            ..where((tbl) => tbl.id.equals(1)))
          .getSingle();
      state = SettingsModel.fromDrift(inserted, categoriesList);
    }
  }

  /// Invariant: Routine expense operations NEVER call this method.
  /// Used ONLY by AddMoneyModal to adjust base reserve balance.
  Future<void> updateCurrentBalance(int centavos) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(currentBalance: centavos, updatedAt: now);
    await (_db.update(_db.settingsTable)..where((tbl) => tbl.id.equals(1))).write(
      SettingsTableCompanion(
        currentBalance: drift.Value(centavos),
        updatedAt: drift.Value(now),
      ),
    );
  }

  Future<void> updateAllowance(int centavos) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(defaultAllowance: centavos, updatedAt: now);
    await (_db.update(_db.settingsTable)..where((tbl) => tbl.id.equals(1))).write(
      SettingsTableCompanion(
        defaultAllowance: drift.Value(centavos),
        updatedAt: drift.Value(now),
      ),
    );
  }

  Future<void> updateGoalAmount(int centavos) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(goalAmount: centavos, updatedAt: now);
    await (_db.update(_db.settingsTable)..where((tbl) => tbl.id.equals(1))).write(
      SettingsTableCompanion(
        goalAmount: drift.Value(centavos),
        updatedAt: drift.Value(now),
      ),
    );
  }

  Future<void> updateGoalStartDate(String? date) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(goalStartDate: date, updatedAt: now);
    await (_db.update(_db.settingsTable)..where((tbl) => tbl.id.equals(1))).write(
      SettingsTableCompanion(
        goalStartDate: drift.Value(date),
        updatedAt: drift.Value(now),
      ),
    );
  }

  Future<void> updateCurrency(String code, String symbol) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(currencyCode: code, currencySymbol: symbol, updatedAt: now);
    await (_db.update(_db.settingsTable)..where((tbl) => tbl.id.equals(1))).write(
      SettingsTableCompanion(
        currencyCode: drift.Value(code),
        currencySymbol: drift.Value(symbol),
        updatedAt: drift.Value(now),
      ),
    );
  }

  Future<void> updateLastBillsMonth(String? month) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(lastBillsMonth: month, updatedAt: now);
    await (_db.update(_db.settingsTable)..where((tbl) => tbl.id.equals(1))).write(
      SettingsTableCompanion(
        lastBillsMonth: drift.Value(month),
        updatedAt: drift.Value(now),
      ),
    );
  }

  Future<void> toggleTheme([bool? isDark]) async {
    final target = isDark ?? !state.themeIsDark;
    final now = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(themeIsDark: target, updatedAt: now);
    await (_db.update(_db.settingsTable)..where((tbl) => tbl.id.equals(1))).write(
      SettingsTableCompanion(
        themeIsDark: drift.Value(target),
        updatedAt: drift.Value(now),
      ),
    );
  }

  Future<void> togglePrivacyMode([bool? enabled]) async {
    final target = enabled ?? !state.privacyMode;
    final now = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(privacyMode: target, updatedAt: now);
    await (_db.update(_db.settingsTable)..where((tbl) => tbl.id.equals(1))).write(
      SettingsTableCompanion(
        privacyMode: drift.Value(target),
        updatedAt: drift.Value(now),
      ),
    );
  }

  Future<void> toggleBillNotifications([bool? enabled]) async {
    final target = enabled ?? !state.billNotificationsEnabled;
    final now = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(billNotificationsEnabled: target, updatedAt: now);
    await (_db.update(_db.settingsTable)..where((tbl) => tbl.id.equals(1))).write(
      SettingsTableCompanion(
        billNotificationsEnabled: drift.Value(target),
        updatedAt: drift.Value(now),
      ),
    );

    if (_ref != null) {
      try {
        final notifService = _ref!.read(localNotificationServiceProvider);
        if (target) {
          final bills = _ref!.read(billsProvider);
          await notifService.rescheduleBillNotifications(bills, enabled: true);
        } else {
          await notifService.cancelAllNotifications();
        }
      } catch (_) {
        // Notification errors must not block settings state update
      }
    }
  }

  Future<bool> addCategory(String name, String hexColor) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty || trimmedName.length > 30) {
      return false;
    }
    if (state.categories.length >= 25) {
      return false;
    }

    final sort = state.categories.length;
    final newCat = CategoryModel(name: trimmedName, colorHex: hexColor, sortOrder: sort);
    await _db.into(_db.categoriesTable).insert(
          newCat.toCompanion(),
          mode: drift.InsertMode.insertOrReplace,
        );
    final updatedCategories = List<CategoryModel>.from(state.categories)..add(newCat);
    state = state.copyWith(categories: updatedCategories);
    return true;
  }

  Future<bool> updateCategory(String oldName, {String? newName, String? newHexColor}) async {
    final index = state.categories.indexWhere((c) => c.name == oldName);
    if (index == -1) return false;

    final target = state.categories[index];
    final updatedName = (newName ?? target.name).trim();
    if (updatedName.isEmpty || updatedName.length > 30) {
      return false;
    }
    final updatedColor = newHexColor ?? target.colorHex;

    if (updatedName != oldName) {
      await _db.transaction(() async {
        await (_db.delete(_db.categoriesTable)..where((tbl) => tbl.name.equals(oldName))).go();
        final updatedModel = CategoryModel(
          name: updatedName,
          colorHex: updatedColor,
          sortOrder: target.sortOrder,
        );
        await _db.into(_db.categoriesTable).insert(
              updatedModel.toCompanion(),
              mode: drift.InsertMode.insertOrReplace,
            );
      });
    } else {
      await (_db.update(_db.categoriesTable)..where((tbl) => tbl.name.equals(oldName))).write(
        CategoriesTableCompanion(
          colorHex: drift.Value(updatedColor),
        ),
      );
    }

    final updatedModel = CategoryModel(
      name: updatedName,
      colorHex: updatedColor,
      sortOrder: target.sortOrder,
    );
    final updatedCategories = [
      for (int i = 0; i < state.categories.length; i++)
        if (i == index) updatedModel else state.categories[i]
    ];
    state = state.copyWith(categories: updatedCategories);
    return true;
  }

  Future<bool> deleteCategory(String name) async {
    if (state.categories.length <= 1) {
      return false;
    }

    await (_db.delete(_db.categoriesTable)..where((tbl) => tbl.name.equals(name))).go();
    final updatedCategories = state.categories.where((c) => c.name != name).toList();
    state = state.copyWith(categories: updatedCategories);
    return true;
  }

  /// specification.md §6.3.1: Complete & Archive Goal atomically
  Future<GoalHistoryModel> archiveGoal({
    required String todayIsoDate,
    required int totalSavingsCents,
  }) async {
    final goalId = _uuid.v4();
    final tomorrow = DateUtilsExt.tomorrowIsoDate(todayIsoDate);
    final now = DateTime.now().millisecondsSinceEpoch;

    final historyItem = GoalHistoryModel(
      id: goalId,
      amount: state.goalAmount,
      saved: totalSavingsCents,
      startDate: state.goalStartDate,
      endDate: todayIsoDate,
      archivedAt: now,
    );

    final newBalance = state.currentBalance + totalSavingsCents;

    await _db.transaction(() async {
      await _db.into(_db.goalHistoryTable).insert(historyItem.toCompanion());
      await (_db.update(_db.settingsTable)..where((tbl) => tbl.id.equals(1))).write(
        SettingsTableCompanion(
          currentBalance: drift.Value(newBalance),
          goalAmount: const drift.Value(0),
          goalStartDate: drift.Value(tomorrow),
          updatedAt: drift.Value(now),
        ),
      );
    });

    state = state.copyWith(
      currentBalance: newBalance,
      goalAmount: 0,
      goalStartDate: tomorrow,
      updatedAt: now,
    );

    return historyItem;
  }

  /// specification.md §6.3.2: Undo Most Recent Goal atomically
  Future<GoalHistoryModel?> undoRecentGoal() async {
    final mostRecent = await (_db.select(_db.goalHistoryTable)
          ..orderBy([(t) => drift.OrderingTerm(expression: t.archivedAt, mode: drift.OrderingMode.desc)])
          ..limit(1))
        .getSingleOrNull();

    if (mostRecent == null) return null;

    final model = GoalHistoryModel.fromDrift(mostRecent);
    final now = DateTime.now().millisecondsSinceEpoch;
    final restoredBalance = max(0, state.currentBalance - model.saved);

    await _db.transaction(() async {
      await (_db.delete(_db.goalHistoryTable)..where((t) => t.id.equals(model.id))).go();
      await (_db.update(_db.settingsTable)..where((tbl) => tbl.id.equals(1))).write(
        SettingsTableCompanion(
          goalAmount: drift.Value(model.amount),
          goalStartDate: drift.Value(model.startDate),
          currentBalance: drift.Value(restoredBalance),
          updatedAt: drift.Value(now),
        ),
      );
    });

    state = state.copyWith(
      goalAmount: model.amount,
      goalStartDate: model.startDate,
      currentBalance: restoredBalance,
      updatedAt: now,
    );

    return model;
  }

  /// specification.md §6.3.3: Edit Goal History Entry
  Future<void> editGoalHistory(
    String id, {
    int? amount,
    int? saved,
    String? startDate,
    String? endDate,
  }) async {
    final existing = await (_db.select(_db.goalHistoryTable)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (existing == null) return;

    await (_db.update(_db.goalHistoryTable)..where((t) => t.id.equals(id))).write(
      GoalHistoryTableCompanion(
        amount: amount != null ? drift.Value(amount) : const drift.Value.absent(),
        saved: saved != null ? drift.Value(saved) : const drift.Value.absent(),
        startDate: startDate != null ? drift.Value(startDate) : const drift.Value.absent(),
        endDate: endDate != null ? drift.Value(endDate) : const drift.Value.absent(),
      ),
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsModel>((ref) {
  final db = ref.watch(databaseProvider);
  return SettingsNotifier(db, ref);
});

final goalHistoryProvider = FutureProvider<List<GoalHistoryModel>>((ref) async {
  final db = ref.watch(databaseProvider);
  // Re-fetch whenever settings change
  ref.watch(settingsProvider);
  final rows = await (db.select(db.goalHistoryTable)
        ..orderBy([(t) => drift.OrderingTerm(expression: t.archivedAt, mode: drift.OrderingMode.desc)]))
      .get();
  return rows.map(GoalHistoryModel.fromDrift).toList();
});
