import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:monance_mobile/core/database/app_database.dart';
import 'package:monance_mobile/models/category_model.dart';
import 'package:monance_mobile/models/daily_record_model.dart';
import 'package:monance_mobile/models/expense_model.dart';
import 'package:monance_mobile/models/goal_history_model.dart';
import 'package:monance_mobile/models/hangout_expense_model.dart';
import 'package:monance_mobile/models/hangout_session_model.dart';
import 'package:monance_mobile/models/monthly_bill_model.dart';
import 'package:monance_mobile/models/settings_model.dart';
import 'package:monance_mobile/services/backup_restore_service.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('test/backup_restore_test.dart (Atomic Offline JSON Backup & Restore)', () {
    late AppDatabase sourceDb;
    late AppDatabase targetDb;

    setUp(() {
      sourceDb = AppDatabase.forTesting(NativeDatabase.memory());
      targetDb = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await sourceDb.close();
      await targetDb.close();
    });

    test('Atomic round-trip backup & restore across all 8 Drift tables', () async {
      // 1. Populate sourceDb with rich sample data across all 8 tables

      // Table 1: SettingsTable
      const customSettings = SettingsModel(
        id: 1,
        defaultAllowance: 7500,
        goalAmount: 250000,
        currentBalance: 120000,
        goalStartDate: '2026-10-01',
        currencyCode: 'USD',
        currencySymbol: '\$',
        lastBillsMonth: '2026-10',
        themeIsDark: false,
        privacyMode: true,
        billNotificationsEnabled: true,
      );
      await sourceDb.into(sourceDb.settingsTable).insert(customSettings.toCompanion());

      // Table 2: CategoriesTable
      const cat1 = CategoryModel(name: 'Groceries', colorHex: '#10B981', sortOrder: 0);
      const cat2 = CategoryModel(name: 'Gaming', colorHex: '#8B5CF6', sortOrder: 1);
      await sourceDb.into(sourceDb.categoriesTable).insert(cat1.toCompanion());
      await sourceDb.into(sourceDb.categoriesTable).insert(cat2.toCompanion());

      // Table 3: DailyRecordsTable
      const day1 = DailyRecordModel(
        date: '2026-10-28',
        title: 'Office Day',
        startingMoney: 6000,
        isDeleted: false,
        updatedAt: 100,
      );
      await sourceDb.into(sourceDb.dailyRecordsTable).insert(day1.toCompanion());

      // Table 4: ExpensesTable
      const exp1 = ExpenseModel(
        id: 'exp-b-1',
        date: '2026-10-28',
        title: 'Lunch Bowl',
        amount: 2500,
        category: 'Groceries',
        deductFrom: 'allowance',
        timestamp: 105,
      );
      const exp2 = ExpenseModel(
        id: 'exp-b-2',
        date: '2026-10-28',
        title: 'Keyboard',
        amount: 4500,
        category: 'Gaming',
        deductFrom: 'balance',
        timestamp: 110,
      );
      await sourceDb.into(sourceDb.expensesTable).insert(exp1.toCompanion());
      await sourceDb.into(sourceDb.expensesTable).insert(exp2.toCompanion());

      // Table 5: MonthlyBillsTable
      const bill1 = MonthlyBillModel(
        id: 'bill-b-1',
        title: 'Cloud Server',
        amount: 120000,
        dueDay: 25,
        isPaid: true,
        sortOrder: 1,
      );
      await sourceDb.into(sourceDb.monthlyBillsTable).insert(bill1.toCompanion());

      // Table 6: GoalHistoryTable
      const history1 = GoalHistoryModel(
        id: 'gh-b-1',
        amount: 100000,
        saved: 102000,
        startDate: '2026-08-01',
        endDate: '2026-09-30',
        archivedAt: 120,
      );
      await sourceDb.into(sourceDb.goalHistoryTable).insert(history1.toCompanion());

      // Table 7: HangoutSessionsTable
      const session1 = HangoutSessionModel(
        id: 'sess-b-1',
        title: 'Arcade Night',
        date: '2026-10-25',
        people: ['You', 'Chloe', 'Dan'],
        isDeleted: false,
        createdAt: 130,
        updatedAt: 130,
      );
      await sourceDb.into(sourceDb.hangoutSessionsTable).insert(session1.toCompanion());

      // Table 8: HangoutExpensesTable
      const hangoutExp1 = HangoutExpenseModel(
        id: 'hexp-b-1',
        sessionId: 'sess-b-1',
        title: 'Tokens',
        totalAmount: 9000,
        perPersonAmount: 3000,
        paidBy: 'Chloe',
        splitType: 'equal',
        participants: ['You', 'Chloe', 'Dan'],
        timestamp: 135,
      );
      await sourceDb.into(sourceDb.hangoutExpensesTable).insert(hangoutExp1.toCompanion());

      // 2. Export to JSON string
      final jsonString = await BackupRestoreService.exportToJsonString(sourceDb);
      expect(jsonString, isNotEmpty);
      expect(jsonString, contains('Arcade Night'));
      expect(jsonString, contains('Cloud Server'));

      // 3. Restore into empty targetDb
      await BackupRestoreService.restoreFromJsonString(targetDb, jsonString);

      // 4. Assert deep equality across all 8 tables in targetDb
      final targetSettings = await targetDb.select(targetDb.settingsTable).getSingle();
      expect(targetSettings.currentBalance, equals(120000));
      expect(targetSettings.goalAmount, equals(250000));
      expect(targetSettings.currencyCode, equals('USD'));
      expect(targetSettings.currencySymbol, equals('\$'));
      expect(targetSettings.privacyMode, isTrue);

      final targetCategories = await targetDb.select(targetDb.categoriesTable).get();
      expect(targetCategories.length, equals(2));
      expect(targetCategories.map((c) => c.name), containsAll(['Groceries', 'Gaming']));

      final targetDailyRecords = await targetDb.select(targetDb.dailyRecordsTable).get();
      expect(targetDailyRecords.length, equals(1));
      expect(targetDailyRecords.first.date, equals('2026-10-28'));
      expect(targetDailyRecords.first.startingMoney, equals(6000));

      final targetExpenses = await targetDb.select(targetDb.expensesTable).get();
      expect(targetExpenses.length, equals(2));
      expect(targetExpenses.firstWhere((e) => e.id == 'exp-b-1').deductFrom, equals('allowance'));
      expect(targetExpenses.firstWhere((e) => e.id == 'exp-b-2').deductFrom, equals('balance'));

      final targetBills = await targetDb.select(targetDb.monthlyBillsTable).get();
      expect(targetBills.length, equals(1));
      expect(targetBills.first.title, equals('Cloud Server'));
      expect(targetBills.first.isPaid, isTrue);

      final targetHistory = await targetDb.select(targetDb.goalHistoryTable).get();
      expect(targetHistory.length, equals(1));
      expect(targetHistory.first.id, equals('gh-b-1'));
      expect(targetHistory.first.saved, equals(102000));

      final targetSessions = await targetDb.select(targetDb.hangoutSessionsTable).get();
      expect(targetSessions.length, equals(1));
      expect(targetSessions.first.title, equals('Arcade Night'));

      final targetHangoutExpenses = await targetDb.select(targetDb.hangoutExpensesTable).get();
      expect(targetHangoutExpenses.length, equals(1));
      expect(targetHangoutExpenses.first.title, equals('Tokens'));
      expect(targetHangoutExpenses.first.totalAmount, equals(9000));
    });

    test('Invalid JSON rollback: corrupt JSON preserves existing database state', () async {
      // 1. Pre-populate targetDb with initial data
      const initialSettings = SettingsModel(
        id: 1,
        currentBalance: 50000,
        defaultAllowance: 5000,
      );
      await targetDb.into(targetDb.settingsTable).insert(initialSettings.toCompanion());

      const initialBill = MonthlyBillModel(
        id: 'original-bill',
        title: 'Original Bill',
        amount: 2000,
        dueDay: 5,
      );
      await targetDb.into(targetDb.monthlyBillsTable).insert(initialBill.toCompanion());

      // 2. Attempt restoring malformed JSON string (syntax error)
      await expectLater(
        BackupRestoreService.restoreFromJsonString(targetDb, '{not-valid-json: null'),
        throwsA(isA<FormatException>()),
      );

      // Verify data remains untouched
      var currentSettings = await targetDb.select(targetDb.settingsTable).getSingle();
      expect(currentSettings.currentBalance, equals(50000));
      var currentBills = await targetDb.select(targetDb.monthlyBillsTable).get();
      expect(currentBills.length, equals(1));
      expect(currentBills.first.id, equals('original-bill'));

      // 3. Attempt restoring valid JSON with invalid business constraint (dueDay = 99)
      const invalidJson = '''
      {
        "version": 1,
        "tables": {
          "monthlyBills": [
            {
              "id": "bad-bill",
              "title": "Bad Day Bill",
              "amount": 1000,
              "dueDay": 99
            }
          ]
        }
      }
      ''';

      await expectLater(
        BackupRestoreService.restoreFromJsonString(targetDb, invalidJson),
        throwsA(isA<FormatException>()),
      );

      // Verify transaction rolled back cleanly and database was NOT purged
      currentSettings = await targetDb.select(targetDb.settingsTable).getSingle();
      expect(currentSettings.currentBalance, equals(50000));
      currentBills = await targetDb.select(targetDb.monthlyBillsTable).get();
      expect(currentBills.length, equals(1));
      expect(currentBills.first.id, equals('original-bill'));

      // 4. Attempt restoring negative expense amount
      const negativeExpJson = '''
      {
        "version": 1,
        "tables": {
          "expenses": [
            {
              "id": "neg-exp",
              "title": "Negative Expense",
              "amount": -500
            }
          ]
        }
      }
      ''';

      await expectLater(
        BackupRestoreService.restoreFromJsonString(targetDb, negativeExpJson),
        throwsA(isA<FormatException>()),
      );

      // Verify untouched
      currentBills = await targetDb.select(targetDb.monthlyBillsTable).get();
      expect(currentBills.length, equals(1));
      expect(currentBills.first.id, equals('original-bill'));
    });
  });
}
