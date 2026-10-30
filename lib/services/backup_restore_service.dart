import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/database/app_database.dart';
import '../models/category_model.dart';
import '../models/daily_record_model.dart';
import '../models/expense_model.dart';
import '../models/goal_history_model.dart';
import '../models/hangout_expense_model.dart';
import '../models/hangout_session_model.dart';
import '../models/monthly_bill_model.dart';
import '../models/settings_model.dart';
import '../providers/bills_provider.dart';
import '../providers/hangouts_provider.dart';
import '../providers/records_provider.dart';
import '../providers/settings_provider.dart';

class BackupRestoreService {
  BackupRestoreService._();

  static const int currentVersion = 1;

  /// Pure Dart method to export all 8 Drift SQLite tables into a versioned JSON string.
  /// Fully headless and unit-testable without platform channel dependencies.
  static Future<String> exportToJsonString(AppDatabase db) async {
    final settingsRows = await db.select(db.settingsTable).get();
    final categoriesRows = await db.select(db.categoriesTable).get();
    final dailyRecordRows = await db.select(db.dailyRecordsTable).get();
    final expenseRows = await db.select(db.expensesTable).get();
    final billRows = await db.select(db.monthlyBillsTable).get();
    final goalHistoryRows = await db.select(db.goalHistoryTable).get();
    final sessionRows = await db.select(db.hangoutSessionsTable).get();
    final hangoutExpenseRows = await db.select(db.hangoutExpensesTable).get();

    final payload = {
      'version': currentVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'tables': {
        'settings': settingsRows.map((r) => SettingsModel.fromDrift(r).toJson()).toList(),
        'categories': categoriesRows.map((r) => CategoryModel.fromDrift(r).toJson()).toList(),
        'dailyRecords': dailyRecordRows.map((r) => DailyRecordModel.fromDrift(r).toJson()).toList(),
        'expenses': expenseRows.map((r) => ExpenseModel.fromDrift(r).toJson()).toList(),
        'monthlyBills': billRows.map((r) => MonthlyBillModel.fromDrift(r).toJson()).toList(),
        'goalHistory': goalHistoryRows.map((r) => GoalHistoryModel.fromDrift(r).toJson()).toList(),
        'hangoutSessions': sessionRows.map((r) => HangoutSessionModel.fromDrift(r).toJson()).toList(),
        'hangoutExpenses': hangoutExpenseRows.map((r) => HangoutExpenseModel.fromDrift(r).toJson()).toList(),
      },
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Exports backup to a local temporary JSON file and triggers platform file share/save.
  static Future<bool> exportBackupToFile(AppDatabase db) async {
    try {
      final jsonString = await exportToJsonString(db);
      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();
      final timestamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
          '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
      final fileName = 'monance_backup_$timestamp.json';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonString);

      final xFile = XFile(file.path, mimeType: 'application/json', name: fileName);
      final shareResult = await Share.shareXFiles([xFile], subject: 'Monance Backup $fileName');
      return shareResult.status == ShareResultStatus.success;
    } catch (_) {
      return false;
    }
  }

  /// Opens the platform file picker for a `.json` backup file and restores it into [db].
  static Future<bool> restoreBackupFromFilePicker(AppDatabase db) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.isEmpty) {
        return false;
      }

      final pickedFile = result.files.first;
      String? jsonContent;
      if (pickedFile.bytes != null) {
        jsonContent = utf8.decode(pickedFile.bytes!);
      } else if (pickedFile.path != null) {
        final file = File(pickedFile.path!);
        jsonContent = await file.readAsString();
      }

      if (jsonContent == null || jsonContent.isEmpty) {
        return false;
      }

      await restoreFromJsonString(db, jsonContent);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Refreshes all in-memory Riverpod provider state from the database after a restore.
  static Future<void> refreshProviders(dynamic refOrContainer) async {
    try {
      await refOrContainer.read(settingsProvider.notifier).loadSettings();
      await refOrContainer.read(recordsProvider.notifier).loadRecords();
      await refOrContainer.read(billsProvider.notifier).loadBills();
      await refOrContainer.read(hangoutsProvider.notifier).loadSessions();
      refOrContainer.invalidate(goalHistoryProvider);
    } catch (_) {
      // Safe fallback
    }
  }

  /// Pure Dart method to validate and restore all 8 Drift SQLite tables from JSON within
  /// a single atomic transaction. Any validation failure or runtime exception automatically
  /// rolls back the transaction, preserving existing database state.
  static Future<void> restoreFromJsonString(AppDatabase db, String jsonString) async {
    final dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } catch (e) {
      throw FormatException('Invalid JSON payload: $e');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected JSON root to be an object');
    }

    // Extract tables map either from 'tables', 'data', or the root map
    final Map<String, dynamic> tables;
    if (decoded['tables'] is Map<String, dynamic>) {
      tables = decoded['tables'] as Map<String, dynamic>;
    } else if (decoded['data'] is Map<String, dynamic>) {
      tables = decoded['data'] as Map<String, dynamic>;
    } else {
      tables = decoded;
    }

    // 1. Parse and validate all rows in-memory before beginning database mutation
    final List<SettingsModel> settingsList = [];
    if (tables['settings'] is List) {
      for (final item in tables['settings'] as List) {
        if (item is! Map<String, dynamic>) throw const FormatException('Invalid settings entry');
        final s = SettingsModel.fromJson(item);
        if (s.id < 1) throw const FormatException('Settings ID must be >= 1');
        settingsList.add(s);
      }
    }

    final List<CategoryModel> categoriesList = [];
    if (tables['categories'] is List) {
      for (final item in tables['categories'] as List) {
        if (item is! Map<String, dynamic>) throw const FormatException('Invalid category entry');
        final c = CategoryModel.fromJson(item);
        if (c.name.trim().isEmpty) throw const FormatException('Category name cannot be empty');
        categoriesList.add(c);
      }
    }

    final List<DailyRecordModel> dailyRecordsList = [];
    if (tables['dailyRecords'] is List) {
      for (final item in tables['dailyRecords'] as List) {
        if (item is! Map<String, dynamic>) throw const FormatException('Invalid daily record entry');
        final r = DailyRecordModel.fromJson(item);
        if (r.date.trim().isEmpty) throw const FormatException('Daily record date cannot be empty');
        dailyRecordsList.add(r);
      }
    }

    final List<ExpenseModel> expensesList = [];
    if (tables['expenses'] is List) {
      for (final item in tables['expenses'] as List) {
        if (item is! Map<String, dynamic>) throw const FormatException('Invalid expense entry');
        final rawAmount = item['amount'];
        if (rawAmount is num && rawAmount <= 0) {
          throw const FormatException('Expense amount must be > 0');
        }
        final e = ExpenseModel.fromJson(item);
        if (e.amount <= 0) throw const FormatException('Expense amount must be > 0');
        if (e.id.trim().isEmpty) throw const FormatException('Expense ID cannot be empty');
        expensesList.add(e);
      }
    }

    final List<MonthlyBillModel> billsList = [];
    if (tables['monthlyBills'] is List) {
      for (final item in tables['monthlyBills'] as List) {
        if (item is! Map<String, dynamic>) throw const FormatException('Invalid monthly bill entry');
        final rawDue = item['dueDay'] ?? item['due_day'];
        if (rawDue is num && (rawDue < 1 || rawDue > 31)) {
          throw const FormatException('Due day must be 1..31');
        }
        final b = MonthlyBillModel.fromJson(item);
        if (b.amount <= 0) throw const FormatException('Monthly bill amount must be > 0');
        if (b.dueDay < 1 || b.dueDay > 31) throw const FormatException('Due day must be 1..31');
        billsList.add(b);
      }
    }

    final List<GoalHistoryModel> goalHistoryList = [];
    if (tables['goalHistory'] is List) {
      for (final item in tables['goalHistory'] as List) {
        if (item is! Map<String, dynamic>) throw const FormatException('Invalid goal history entry');
        final g = GoalHistoryModel.fromJson(item);
        goalHistoryList.add(g);
      }
    }

    final List<HangoutSessionModel> sessionsList = [];
    if (tables['hangoutSessions'] is List) {
      for (final item in tables['hangoutSessions'] as List) {
        if (item is! Map<String, dynamic>) throw const FormatException('Invalid hangout session entry');
        final h = HangoutSessionModel.fromJson(item);
        sessionsList.add(h);
      }
    }

    final List<HangoutExpenseModel> hangoutExpensesList = [];
    if (tables['hangoutExpenses'] is List) {
      for (final item in tables['hangoutExpenses'] as List) {
        if (item is! Map<String, dynamic>) throw const FormatException('Invalid hangout expense entry');
        final rawAmount = item['totalAmount'] ?? item['amount'];
        if (rawAmount is num && rawAmount <= 0) {
          throw const FormatException('Hangout expense total amount must be > 0');
        }
        final he = HangoutExpenseModel.fromJson(item);
        if (he.totalAmount <= 0) throw const FormatException('Hangout expense total amount must be > 0');
        hangoutExpensesList.add(he);
      }
    }

    // 2. Perform atomic purge and restore inside a single database transaction
    await db.transaction(() async {
      // Step A: Purge child tables first to satisfy foreign key constraints
      await db.delete(db.expensesTable).go();
      await db.delete(db.hangoutExpensesTable).go();

      // Step B: Purge parent tables
      await db.delete(db.dailyRecordsTable).go();
      await db.delete(db.hangoutSessionsTable).go();
      await db.delete(db.monthlyBillsTable).go();
      await db.delete(db.goalHistoryTable).go();
      await db.delete(db.categoriesTable).go();
      await db.delete(db.settingsTable).go();

      // Step C: Insert parent tables
      for (final s in settingsList) {
        await db.into(db.settingsTable).insert(s.toCompanion(), mode: drift.InsertMode.insertOrReplace);
      }
      for (final c in categoriesList) {
        await db.into(db.categoriesTable).insert(c.toCompanion(), mode: drift.InsertMode.insertOrReplace);
      }
      for (final r in dailyRecordsList) {
        await db.into(db.dailyRecordsTable).insert(r.toCompanion(), mode: drift.InsertMode.insertOrReplace);
      }
      for (final b in billsList) {
        await db.into(db.monthlyBillsTable).insert(b.toCompanion(), mode: drift.InsertMode.insertOrReplace);
      }
      for (final g in goalHistoryList) {
        await db.into(db.goalHistoryTable).insert(g.toCompanion(), mode: drift.InsertMode.insertOrReplace);
      }
      for (final s in sessionsList) {
        await db.into(db.hangoutSessionsTable).insert(s.toCompanion(), mode: drift.InsertMode.insertOrReplace);
      }

      // Step D: Insert child tables
      for (final e in expensesList) {
        await db.into(db.expensesTable).insert(e.toCompanion(), mode: drift.InsertMode.insertOrReplace);
      }
      for (final he in hangoutExpensesList) {
        await db.into(db.hangoutExpensesTable).insert(he.toCompanion(), mode: drift.InsertMode.insertOrReplace);
      }
    });
  }
}
