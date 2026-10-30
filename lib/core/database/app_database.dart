import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  SettingsTable,
  DailyRecordsTable,
  ExpensesTable,
  MonthlyBillsTable,
  CategoriesTable,
  GoalHistoryTable,
  HangoutSessionsTable,
  HangoutExpensesTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          // Explicitly enforce SQLite foreign key constraints
          await customStatement('PRAGMA foreign_keys = ON;');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'monance.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

