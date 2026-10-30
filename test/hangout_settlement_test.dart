import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:monance_mobile/core/database/app_database.dart';
import 'package:monance_mobile/models/daily_record_model.dart';
import 'package:monance_mobile/models/expense_model.dart';
import 'package:monance_mobile/models/hangout_expense_model.dart';
import 'package:monance_mobile/models/hangout_session_model.dart';
import 'package:monance_mobile/providers/database_provider.dart';
import 'package:monance_mobile/providers/hangouts_provider.dart';
import 'package:monance_mobile/providers/records_provider.dart';
import 'package:monance_mobile/providers/settings_provider.dart';

void main() {
  group('test/hangout_settlement_test.dart (Remainder & Settlement Verification)', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );
      await container.read(settingsProvider.notifier).loadSettings();
      await container.read(recordsProvider.notifier).loadRecords();
      await container.read(hangoutsProvider.notifier).loadSessions();
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('Remainder absorption & zero-sum split (Traps #3 & #4 Fix)', () {
      // 1. Split ₱100.00 (10000 cents) across 3 participants ['You', 'Alice', 'Bob'] paid by 'You'
      final sharesYouPaid = HangoutsNotifier.splitExpense(
        totalAmount: 10000,
        participants: ['You', 'Alice', 'Bob'],
        paidBy: 'You',
      );

      expect(sharesYouPaid['You'], equals(3334)); // Remainder recipient
      expect(sharesYouPaid['Alice'], equals(3333));
      expect(sharesYouPaid['Bob'], equals(3333));
      expect(sharesYouPaid.values.fold(0, (s, a) => s + a), equals(10000));

      // 2. paidBy is NOT in participants: 'You' pays for ['Alice', 'Bob', 'Charlie']
      final sharesOtherPaid = HangoutsNotifier.splitExpense(
        totalAmount: 10000,
        participants: ['Alice', 'Bob', 'Charlie'],
        paidBy: 'You',
      );

      // Remainder recipient is participants.first ('Alice')
      expect(sharesOtherPaid['Alice'], equals(3334));
      expect(sharesOtherPaid['Bob'], equals(3333));
      expect(sharesOtherPaid['Charlie'], equals(3333));
      expect(sharesOtherPaid.values.fold(0, (s, a) => s + a), equals(10000));
    });

    test('Pairwise debt settlement (calculateWhoOwesWhom)', () {
      // Create a multi-expense session with 3 participants: You, Alice, Bob
      // Exp 1: You paid 10000 for ['You', 'Alice', 'Bob']
      //   Shares: You: 3334, Alice: 3333, Bob: 3333
      // Exp 2: Alice paid 6000 for ['Alice', 'Bob']
      //   Shares: Alice: 3000, Bob: 3000
      //
      // Net calculations:
      // You: Paid 10000, Owed 3334 -> Net = +6666 (Creditor)
      // Alice: Paid 6000, Owed (3333 + 3000 = 6333) -> Net = -333 (Debtor owes 333)
      // Bob: Paid 0, Owed (3333 + 3000 = 6333) -> Net = -6333 (Debtor owes 6333)
      //
      // Sum Net = +6666 - 333 - 6333 = 0 (Guaranteed zero-sum invariant)
      const session = HangoutSessionModel(
        id: 'sess-1',
        title: 'Road Trip',
        date: '2026-10-30',
        people: ['You', 'Alice', 'Bob'],
        createdAt: 1,
        updatedAt: 1,
        expenses: [
          HangoutExpenseModel(
            id: 'h-exp-1',
            sessionId: 'sess-1',
            title: 'Gas',
            totalAmount: 10000,
            perPersonAmount: 3333,
            paidBy: 'You',
            participants: ['You', 'Alice', 'Bob'],
            timestamp: 1,
          ),
          HangoutExpenseModel(
            id: 'h-exp-2',
            sessionId: 'sess-1',
            title: 'Snacks',
            totalAmount: 6000,
            perPersonAmount: 3000,
            paidBy: 'Alice',
            participants: ['Alice', 'Bob'],
            timestamp: 2,
          ),
        ],
      );

      final settlement = HangoutsNotifier.calculateWhoOwesWhom(session);

      // Largest debtor is Bob (6333), largest creditor is You (6666)
      // Bob owes You ₱63.33 (6333 cents), remaining You credit = 333 cents
      // Next debtor is Alice (333 cents), You credit = 333 cents
      // Alice owes You ₱3.33 (333 cents)
      expect(settlement.length, equals(2));
      expect(settlement[0], equals('Bob owes You ₱63.33'));
      expect(settlement[1], equals('Alice owes You ₱3.33'));
    });

    test('Idempotent Calendar merge vs overwrite', () async {
      final recordsNotifier = container.read(recordsProvider.notifier);
      final hangoutsNotifier = container.read(hangoutsProvider.notifier);

      const targetDate = '2026-10-30';

      // 1. Pre-seed a manual expense on targetDate
      await recordsNotifier.setRecord(const DailyRecordModel(
        date: targetDate,
        title: 'Normal Day',
        startingMoney: 5000,
        expenses: [
          ExpenseModel(
            id: 'exp-1',
            date: targetDate,
            title: 'Morning Coffee',
            amount: 1500,
            category: 'Food',
            deductFrom: 'allowance',
            timestamp: 10,
          ),
        ],
        updatedAt: 10,
      ));

      // Create Hangout Session with 1 expense including 'You'
      const session = HangoutSessionModel(
        id: 'sess-merge',
        title: 'Team Dinner',
        date: targetDate,
        people: ['You', 'Alice'],
        createdAt: 20,
        updatedAt: 20,
        expenses: [
          HangoutExpenseModel(
            id: 'exp-h1',
            sessionId: 'sess-merge',
            title: 'Buffet',
            totalAmount: 4000, // You share is 2000
            perPersonAmount: 2000,
            paidBy: 'Alice',
            participants: ['You', 'Alice'],
            timestamp: 25,
          ),
        ],
      );

      // 2. Log in 'merge' mode
      await hangoutsNotifier.logHangoutToCalendar(
        session: session,
        mode: 'merge',
        modalDeductFrom: 'allowance',
        modalIsAllowance: false,
      );

      var record = container.read(recordsProvider)[targetDate]!;
      expect(record.expenses.length, equals(2));
      expect(record.expenses.any((e) => e.id == 'exp-1'), isTrue); // 'exp-1' PRESERVED!
      final hangoutExp = record.expenses.firstWhere((e) => e.id == 'hangout-sess-merge-exp-h1');
      expect(hangoutExp.amount, equals(2000));
      expect(hangoutExp.title, equals('Team Dinner: Buffet'));

      // 3. Re-log the same hangout in 'merge' mode with updated expense amount (Buffet is now 6000, You share 3000)
      final updatedSession = session.copyWith(
        expenses: const [
          HangoutExpenseModel(
            id: 'exp-h1',
            sessionId: 'sess-merge',
            title: 'Buffet',
            totalAmount: 6000, // You share is 3000
            perPersonAmount: 3000,
            paidBy: 'Alice',
            participants: ['You', 'Alice'],
            timestamp: 30,
          ),
        ],
      );

      await hangoutsNotifier.logHangoutToCalendar(
        session: updatedSession,
        mode: 'merge',
        modalDeductFrom: 'allowance',
        modalIsAllowance: false,
      );

      // Verify: still 2 expenses, no duplicate, updated amount
      record = container.read(recordsProvider)[targetDate]!;
      expect(record.expenses.length, equals(2));
      expect(record.expenses.any((e) => e.id == 'exp-1'), isTrue);
      final updatedHangoutExp = record.expenses.firstWhere((e) => e.id == 'hangout-sess-merge-exp-h1');
      expect(updatedHangoutExp.amount, equals(3000));

      // 4. Log in 'overwrite' mode
      await hangoutsNotifier.logHangoutToCalendar(
        session: updatedSession,
        mode: 'overwrite',
        modalDeductFrom: 'allowance',
        modalIsAllowance: true,
        allowanceCents: 5000,
      );

      // In 'overwrite' mode, manual expense 'exp-1' is replaced
      record = container.read(recordsProvider)[targetDate]!;
      expect(record.expenses.length, equals(1));
      expect(record.expenses.first.id, equals('hangout-sess-merge-exp-h1'));
      expect(record.expenses.any((e) => e.id == 'exp-1'), isFalse);
      expect(record.startingMoney, equals(5000));
    });
  });
}
