import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:monance_mobile/core/database/app_database.dart';

void main() {
  group('Phase 1: Drift SQLite Database Schema & Constraint Tests', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    // -------------------------------------------------------------
    // Required Happy Path Tests (Ticket Acceptance Criteria & Scope)
    // -------------------------------------------------------------

    test('1-3. Instantiate AppDatabase, insert and query SettingsTableData', () async {
      // Insert default SettingsTableData with id: 1, currentBalance: 10000 (cents)
      await db.into(db.settingsTable).insert(
            const SettingsTableCompanion(
              id: Value(1),
              currentBalance: Value(10000),
              defaultAllowance: Value(5000),
              currencyCode: Value('PHP'),
              currencySymbol: Value('₱'),
            ),
          );

      final settings = await (db.select(db.settingsTable)..where((tbl) => tbl.id.equals(1))).getSingle();
      expect(settings.id, equals(1));
      expect(settings.currentBalance, equals(10000));
      expect(settings.defaultAllowance, equals(5000));
      expect(settings.currencyCode, equals('PHP'));
      expect(settings.currencySymbol, equals('₱'));
      expect(settings.themeIsDark, isTrue);
      expect(settings.privacyMode, isFalse);
      expect(settings.updatedAt, greaterThan(0));
    });

    test('4-5. Insert DailyRecord and associated Expense, verify cascading delete', () async {
      const testDate = '2026-10-30';
      const expenseId = 'exp-uuid-1';

      // Insert daily record
      await db.into(db.dailyRecordsTable).insert(
            const DailyRecordsTableCompanion(
              date: Value(testDate),
              title: Value('school'),
              startingMoney: Value(5000),
              isDeleted: Value(false),
            ),
          );

      // Insert associated expense with deductFrom: 'allowance'
      await db.into(db.expensesTable).insert(
            const ExpensesTableCompanion(
              id: Value(expenseId),
              date: Value(testDate),
              title: Value('Lunch at canteen'),
              amount: Value(1200), // 12.00 PHP in cents
              category: Value('Food'),
              deductFrom: Value('allowance'),
            ),
          );

      // Verify insertion
      final expensesBefore = await (db.select(db.expensesTable)..where((t) => t.date.equals(testDate))).get();
      expect(expensesBefore.length, equals(1));
      expect(expensesBefore.first.id, equals(expenseId));
      expect(expensesBefore.first.amount, equals(1200));
      expect(expensesBefore.first.deductFrom, equals('allowance'));

      // Delete daily record
      await (db.delete(db.dailyRecordsTable)..where((t) => t.date.equals(testDate))).go();

      // Verify cascading delete: expense must be automatically purged
      final expensesAfter = await (db.select(db.expensesTable)..where((t) => t.date.equals(testDate))).get();
      expect(expensesAfter, isEmpty);
    });

    // -------------------------------------------------------------
    // Negative & Adversarial Tests
    // -------------------------------------------------------------

    test('Adversarial 1: Foreign key rejects orphan expense with non-existent daily record', () async {
      // Attempt to insert an expense for a date that does not exist in DailyRecordsTable
      expect(
        () async {
          await db.into(db.expensesTable).insert(
                const ExpensesTableCompanion(
                  id: Value('orphan-exp-1'),
                  date: Value('2026-10-31'), // Not in DailyRecordsTable
                  title: Value('Orphan snack'),
                  amount: Value(500),
                  category: Value('Food'),
                  deductFrom: Value('allowance'),
                ),
              );
        },
        throwsA(isA<SqliteException>()),
      );
    });

    test('Adversarial 2: Hangout sessions cascading delete removes associated hangout expenses', () async {
      const sessionId = 'session-100';
      const expenseId = 'hangout-exp-100';

      // Insert hangout session
      await db.into(db.hangoutSessionsTable).insert(
            const HangoutSessionsTableCompanion(
              id: Value(sessionId),
              title: Value('Dinner with Friends'),
              date: Value('2026-10-30'),
              peopleJson: Value('["You", "Alice", "Bob"]'),
              isDeleted: Value(false),
            ),
          );

      // Insert associated hangout expense
      await db.into(db.hangoutExpensesTable).insert(
            const HangoutExpensesTableCompanion(
              id: Value(expenseId),
              sessionId: Value(sessionId),
              title: Value('Pizza'),
              totalAmount: Value(3000),
              perPersonAmount: Value(1000),
              paidBy: Value('You'),
              splitType: Value('equal'),
              participantsJson: Value('["You", "Alice", "Bob"]'),
            ),
          );

      // Verify hangout expense exists
      final expensesBefore = await (db.select(db.hangoutExpensesTable)
            ..where((t) => t.sessionId.equals(sessionId)))
          .get();
      expect(expensesBefore.length, equals(1));

      // Delete the parent session
      await (db.delete(db.hangoutSessionsTable)..where((t) => t.id.equals(sessionId))).go();

      // Verify hangout expense was cascaded and deleted
      final expensesAfter = await (db.select(db.hangoutExpensesTable)
            ..where((t) => t.sessionId.equals(sessionId)))
          .get();
      expect(expensesAfter, isEmpty);
    });

    test('Adversarial 3: Foreign key rejects orphan hangout expense with non-existent session', () async {
      expect(
        () async {
          await db.into(db.hangoutExpensesTable).insert(
                const HangoutExpensesTableCompanion(
                  id: Value('orphan-hangout-exp'),
                  sessionId: Value('non-existent-session-id'),
                  title: Value('Coffee'),
                  totalAmount: Value(400),
                  perPersonAmount: Value(200),
                  participantsJson: Value('["You", "Alice"]'),
                ),
              );
        },
        throwsA(isA<SqliteException>()),
      );
    });

    test('Adversarial 4: SettingsTable rejects duplicate primary key (single-row constraint)', () async {
      // First insert id = 1
      await db.into(db.settingsTable).insert(
            const SettingsTableCompanion(
              id: Value(1),
              currentBalance: Value(5000),
            ),
          );

      // Duplicate insert of id = 1 must throw SQLite unique/PK constraint error
      expect(
        () async {
          await db.into(db.settingsTable).insert(
                const SettingsTableCompanion(
                  id: Value(1),
                  currentBalance: Value(9000),
                ),
              );
        },
        throwsA(isA<SqliteException>()),
      );

      // Upsert (insertOrReplace) successfully updates without creating a second row
      await db.into(db.settingsTable).insertOnConflictUpdate(
            const SettingsTableCompanion(
              id: Value(1),
              currentBalance: Value(9000),
            ),
          );

      final allRows = await db.select(db.settingsTable).get();
      expect(allRows.length, equals(1));
      expect(allRows.first.currentBalance, equals(9000));
    });

    test('Adversarial 5: DailyRecordsTable rejects duplicate primary key (date)', () async {
      const date = '2026-10-30';
      await db.into(db.dailyRecordsTable).insert(
            const DailyRecordsTableCompanion(
              date: Value(date),
              startingMoney: Value(5000),
            ),
          );

      // Attempt second insert with same date
      expect(
        () async {
          await db.into(db.dailyRecordsTable).insert(
                const DailyRecordsTableCompanion(
                  date: Value(date),
                  startingMoney: Value(8000),
                ),
              );
        },
        throwsA(isA<SqliteException>()),
      );
    });

    test('Adversarial 6: ExpensesTable.category has NO foreign key constraint to CategoriesTable', () async {
      // Per Section 5.1 Rule 2: Deleting custom category must NOT cascade or violate FK
      const testDate = '2026-10-30';
      await db.into(db.dailyRecordsTable).insert(
            const DailyRecordsTableCompanion(
              date: Value(testDate),
              startingMoney: Value(10000),
            ),
          );

      // Insert category into CategoriesTable
      await db.into(db.categoriesTable).insert(
            const CategoriesTableCompanion(
              name: Value('CustomGadgets'),
              colorHex: Value('#FF00AA'),
              sortOrder: Value(1),
            ),
          );

      // Insert expense using that category
      await db.into(db.expensesTable).insert(
            const ExpensesTableCompanion(
              id: Value('gadget-exp-1'),
              date: Value(testDate),
              title: Value('USB Cable'),
              amount: Value(250),
              category: Value('CustomGadgets'),
              deductFrom: Value('allowance'),
            ),
          );

      // Also insert expense with completely unknown category not in CategoriesTable
      await db.into(db.expensesTable).insert(
            const ExpensesTableCompanion(
              id: Value('random-exp-2'),
              date: Value(testDate),
              title: Value('Random Antique'),
              amount: Value(999),
              category: Value('UnknownNonExistentCategory'),
              deductFrom: Value('balance'),
            ),
          );

      // Delete category 'CustomGadgets' from CategoriesTable
      await (db.delete(db.categoriesTable)..where((t) => t.name.equals('CustomGadgets'))).go();

      // Verify that neither expense was deleted or corrupted
      final remaining = await db.select(db.expensesTable).get();
      expect(remaining.length, equals(2));
      expect(remaining.any((e) => e.category == 'CustomGadgets'), isTrue);
      expect(remaining.any((e) => e.category == 'UnknownNonExistentCategory'), isTrue);
    });

    test('Adversarial 7: Dynamic timestamps generated via clientDefault', () async {
      final beforeTime = DateTime.now().millisecondsSinceEpoch;

      await db.into(db.dailyRecordsTable).insert(
            const DailyRecordsTableCompanion(
              date: Value('2026-10-30'),
              startingMoney: Value(2000),
            ),
          );

      final record = await (db.select(db.dailyRecordsTable)..where((t) => t.date.equals('2026-10-30'))).getSingle();
      final afterTime = DateTime.now().millisecondsSinceEpoch;

      expect(record.updatedAt, greaterThanOrEqualTo(beforeTime));
      expect(record.updatedAt, lessThanOrEqualTo(afterTime));
    });

    test('Adversarial 8: All monetary amounts stored as integer cents without precision loss', () async {
      // Insert Monthly Bill with large cent amount
      const billAmount = 123456789; // 1,234,567.89 currency units
      await db.into(db.monthlyBillsTable).insert(
            const MonthlyBillsTableCompanion(
              id: Value('bill-1'),
              title: Value('Server Hosting'),
              amount: Value(billAmount),
              dueDay: Value(15),
              isPaid: Value(false),
            ),
          );

      final bill = await (db.select(db.monthlyBillsTable)..where((t) => t.id.equals('bill-1'))).getSingle();
      expect(bill.amount, equals(billAmount));

      // Insert Goal History record with exact cents
      const goalAmount = 999999999;
      const savedAmount = 999999999;
      await db.into(db.goalHistoryTable).insert(
            const GoalHistoryTableCompanion(
              id: Value('goal-hist-1'),
              amount: Value(goalAmount),
              saved: Value(savedAmount),
              startDate: Value('2026-01-01'),
              endDate: Value('2026-12-31'),
            ),
          );

      final goalHist = await (db.select(db.goalHistoryTable)..where((t) => t.id.equals('goal-hist-1'))).getSingle();
      expect(goalHist.amount, equals(goalAmount));
      expect(goalHist.saved, equals(savedAmount));
    });
  });
}

