import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:monance_mobile/core/database/app_database.dart';
import 'package:monance_mobile/main.dart';
import 'package:monance_mobile/models/daily_record_model.dart';
import 'package:monance_mobile/models/expense_model.dart';
import 'package:monance_mobile/providers/database_provider.dart';
import 'package:monance_mobile/providers/hangouts_provider.dart';
import 'package:monance_mobile/providers/records_provider.dart';
import 'package:monance_mobile/providers/security_provider.dart';
import 'package:monance_mobile/services/local_notification_service.dart';
import 'package:monance_mobile/services/security_service.dart';
import 'package:monance_mobile/views/hangouts/hangouts_view.dart';
import 'package:monance_mobile/views/hangouts/who_owes_whom_card.dart';

void main() {
  group('test/hangouts_view_test.dart (Hangouts, Remainder Splitting & Settlement)', () {
    late AppDatabase db;
    late InMemorySecureStorage storage;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      storage = InMemorySecureStorage();
    });

    tearDown(() async {
      await db.close();
    });

    Widget createTestApp() {
      final sec = SecurityService(storage: storage);
      final notif = LocalNotificationService();

      return ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          securityServiceProvider.overrideWithValue(sec),
          localNotificationServiceProvider.overrideWithValue(notif),
        ],
        child: const MonanceApp(),
      );
    }

    testWidgets('Create session rules: "You" permanent and duplicate names rejected',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to Hangouts tab
      await tester.tap(find.text('Hangouts'));
      await tester.pumpAndSettle();
      expect(find.byType(HangoutsView), findsOneWidget);

      // Tap + New
      await tester.tap(find.byKey(const Key('create_hangout_button')));
      await tester.pumpAndSettle();

      // Assert "You" is present and has no remove icon
      expect(find.byKey(const Key('participant_chip_You')), findsOneWidget);
      expect(find.byKey(const Key('remove_participant_You')), findsNothing);

      // Add 'Alice'
      await tester.enterText(find.byKey(const Key('participant_name_input')), 'Alice');
      await tester.tap(find.byKey(const Key('add_participant_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('participant_chip_Alice')), findsOneWidget);
      expect(find.byKey(const Key('remove_participant_Alice')), findsOneWidget);

      // Try adding duplicate 'alice' (case-insensitive)
      await tester.enterText(find.byKey(const Key('participant_name_input')), 'alice');
      await tester.tap(find.byKey(const Key('add_participant_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('create_hangout_error_text')), findsOneWidget);
      expect(find.textContaining('Duplicate participant name'), findsOneWidget);
    });

    testWidgets('Paid By chips and remainder absorption live preview',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(MonanceApp));
      final container = ProviderScope.containerOf(element);

      // Create session with You, Alice, Bob
      final session = await container.read(hangoutsProvider.notifier).createSession(
            title: 'Dinner Trip',
            date: '2026-11-25',
            people: ['You', 'Alice', 'Bob'],
          );
      await tester.pumpAndSettle();

      // Navigate to Hangouts tab
      await tester.tap(find.text('Hangouts'));
      await tester.pumpAndSettle();

      // Tap session card to open Detail View
      await tester.tap(find.byKey(Key('hangout_card_${session.id}')));
      await tester.pumpAndSettle();

      // Tap Add Expense
      await tester.tap(find.byKey(const Key('add_hangout_expense_button')));
      await tester.pumpAndSettle();

      // Assert Paid By chips equal session.people and default is You
      expect(find.byKey(const Key('paid_by_chip_You')), findsOneWidget);
      expect(find.byKey(const Key('paid_by_chip_Alice')), findsOneWidget);
      expect(find.byKey(const Key('paid_by_chip_Bob')), findsOneWidget);

      final youChip = tester.widget<ChoiceChip>(find.byKey(const Key('paid_by_chip_You')));
      expect(youChip.selected, isTrue);

      // Enter amount 100.00 (10000 cents)
      await tester.enterText(find.byKey(const Key('hangout_exp_amount_input')), '100.00');
      await tester.pumpAndSettle();

      // Live preview shows 10000 / 3: You (payer) absorbs remainder: 3334, Alice: 3333, Bob: 3333
      expect(find.byKey(const Key('live_share_You')), findsOneWidget);
      expect(find.byKey(const Key('live_share_Alice')), findsOneWidget);
      expect(find.byKey(const Key('live_share_Bob')), findsOneWidget);

      expect(find.text('₱33.34'), findsOneWidget);
      expect(find.text('₱33.33'), findsNWidgets(2));
    });

    testWidgets('Settlement card renders HangoutsNotifier.calculateWhoOwesWhom strings',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(MonanceApp));
      final container = ProviderScope.containerOf(element);

      // Seed multi-payer session
      final session = await container.read(hangoutsProvider.notifier).createSession(
            title: 'Weekend Getaway',
            date: '2026-11-28',
            people: ['You', 'Alice', 'Bob'],
          );

      // Exp 1: Alice paid 90.00 for all 3 (30.00 each)
      await container.read(hangoutsProvider.notifier).addExpenseToSession(
            sessionId: session.id,
            title: 'Hotel',
            totalAmount: 9000,
            paidBy: 'Alice',
            participants: ['You', 'Alice', 'Bob'],
          );

      // Exp 2: Bob paid 60.00 for all 3 (20.00 each)
      await container.read(hangoutsProvider.notifier).addExpenseToSession(
            sessionId: session.id,
            title: 'Gas',
            totalAmount: 6000,
            paidBy: 'Bob',
            participants: ['You', 'Alice', 'Bob'],
          );

      await tester.pumpAndSettle();

      // Open Hangouts Detail View
      await tester.tap(find.text('Hangouts'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('hangout_card_${session.id}')));
      await tester.pumpAndSettle();

      // Assert WhoOwesWhomCard exists
      expect(find.byType(WhoOwesWhomCard), findsOneWidget);

      final updatedSession = container.read(hangoutsProvider).firstWhere((s) => s.id == session.id);
      final expectedSettlement = HangoutsNotifier.calculateWhoOwesWhom(updatedSession, '₱');

      for (final line in expectedSettlement) {
        expect(find.text(line), findsOneWidget);
      }
    });

    testWidgets('Idempotent Log to Calendar: Merge mode leaves manual expenses untouched and avoids duplicates',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(MonanceApp));
      final container = ProviderScope.containerOf(element);

      const sessionDate = '2026-11-22';

      // Seed manual expense on sessionDate
      final manualRecord = DailyRecordModel(
        date: sessionDate,
        title: 'school',
        startingMoney: 5000,
        expenses: [
          ExpenseModel(
            id: 'exp-1',
            date: sessionDate,
            title: 'Breakfast',
            amount: 1000,
            category: 'Food',
            deductFrom: 'allowance',
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        ],
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        isDeleted: false,
      );
      await container.read(recordsProvider.notifier).setRecord(manualRecord);

      // Create hangout session on same date
      final session = await container.read(hangoutsProvider.notifier).createSession(
            title: 'Boardgames',
            date: sessionDate,
            people: ['You', 'Alice'],
          );

      await container.read(hangoutsProvider.notifier).addExpenseToSession(
            sessionId: session.id,
            title: 'Tickets',
            totalAmount: 4000,
            paidBy: 'You',
            participants: ['You', 'Alice'],
          );

      await tester.pumpAndSettle();

      // Open Hangouts Detail View
      await tester.tap(find.text('Hangouts'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('hangout_card_${session.id}')));
      await tester.pumpAndSettle();

      // First Log in Merge mode
      expect(find.text('Log to Calendar'), findsOneWidget);
      await tester.tap(find.byKey(const Key('log_to_calendar_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('confirm_log_to_calendar_button')));
      await tester.pumpAndSettle();

      // Button label switches to Update Calendar
      expect(find.text('Update Calendar'), findsOneWidget);

      // Second Log in Merge mode
      await tester.tap(find.byKey(const Key('log_to_calendar_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm_log_to_calendar_button')));
      await tester.pumpAndSettle();

      // Check date record in recordsProvider
      final updatedRecord = container.read(recordsProvider)[sessionDate]!;
      // Must contain manual exp-1
      expect(updatedRecord.expenses.any((e) => e.id == 'exp-1'), isTrue);

      // Must contain exactly 1 hangout expense (id starts with hangout-<sessionId>-)
      final hangoutExpCount = updatedRecord.expenses
          .where((e) => e.id.startsWith('hangout-${session.id}-'))
          .length;
      expect(hangoutExpCount, equals(1));

      // Go back to list view and check Calendar badge
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byKey(Key('calendar_badge_${session.id}')), findsOneWidget);
    });
  });
}

