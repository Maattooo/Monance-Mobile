import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:monance_mobile/core/database/app_database.dart';
import 'package:monance_mobile/main.dart';
import 'package:monance_mobile/models/daily_record_model.dart';
import 'package:monance_mobile/models/expense_model.dart';
import 'package:monance_mobile/providers/database_provider.dart';
import 'package:monance_mobile/providers/records_provider.dart';
import 'package:monance_mobile/providers/security_provider.dart';
import 'package:monance_mobile/providers/settings_provider.dart';
import 'package:monance_mobile/services/local_notification_service.dart';
import 'package:monance_mobile/services/security_service.dart';
import 'package:monance_mobile/views/dashboard/add_money_modal.dart';
import 'package:monance_mobile/views/dashboard/goal_history_modal.dart';

void main() {
  group('test/dashboard_view_test.dart (Dashboard & Goal Calculations)', () {
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

    testWidgets(
        'AUDIT-001 UI regression: Derived balance reflects deductions, settings.currentBalance stays invariant',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(MonanceApp));
      final container = ProviderScope.containerOf(element);

      // Seed currentBalance = 10000 cents
      await container.read(settingsProvider.notifier).updateCurrentBalance(10000);

      // Seed a rest day with 1500 expense
      const testDate = '2026-11-01';
      final restDay = DailyRecordModel(
        date: testDate,
        title: 'rest',
        startingMoney: 0,
        expenses: [
          ExpenseModel(
            id: 'exp-1',
            date: testDate,
            title: 'Coffee',
            amount: 1500,
            category: 'Food',
            deductFrom: 'allowance',
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        ],
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        isDeleted: false,
      );
      await container.read(recordsProvider.notifier).setRecord(restDay);
      await tester.pumpAndSettle();

      // Derived balance = 10000 - 1500 = 8500 cents = ₱85.00
      expect(find.text('₱85.00'), findsOneWidget);

      // settings.currentBalance must still be 10000
      final currentBalance = container.read(settingsProvider).currentBalance;
      expect(currentBalance, equals(10000));
    });

    testWidgets('Add Money / Set Balance: Validation and mode execution',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(MonanceApp));
      final container = ProviderScope.containerOf(element);

      // Initial base reserve = 10000 cents (100.00)
      await container.read(settingsProvider.notifier).updateCurrentBalance(10000);
      await tester.pumpAndSettle();

      // Open AddMoneyModal
      await tester.tap(find.byKey(const Key('add_money_button')));
      await tester.pumpAndSettle();
      expect(find.byType(AddMoneyModal), findsOneWidget);

      // Test invalid inputs: 0, -5, abc, 10000000
      for (final invalid in ['0', '-5', 'abc', '10000000']) {
        await tester.enterText(find.byKey(const Key('add_money_amount_input')), invalid);
        await tester.tap(find.byKey(const Key('add_money_submit_button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('add_money_error_text')), findsOneWidget);
        expect(container.read(settingsProvider).currentBalance, equals(10000));
      }

      // Add mode: enter 50 -> 10000 + 5000 = 15000 cents
      await tester.tap(find.byKey(const Key('mode_add_button')));
      await tester.enterText(find.byKey(const Key('add_money_amount_input')), '50');
      await tester.tap(find.byKey(const Key('add_money_submit_button')));
      await tester.pumpAndSettle();

      expect(container.read(settingsProvider).currentBalance, equals(15000));

      // Re-open in Set mode: enter 20 -> 2000 cents
      await tester.tap(find.byKey(const Key('add_money_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('mode_set_button')));
      await tester.enterText(find.byKey(const Key('add_money_amount_input')), '20');
      await tester.tap(find.byKey(const Key('add_money_submit_button')));
      await tester.pumpAndSettle();

      expect(container.read(settingsProvider).currentBalance, equals(2000));
    });

    testWidgets('Archive & undo through UI: Goal completion and restoration',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(MonanceApp));
      final container = ProviderScope.containerOf(element);

      // Seed goalAmount = 5000 (₱50.00) and startingMoney = 6000 with 0 expenses (savings = 6000 >= 5000)
      await container.read(settingsProvider.notifier).updateGoalAmount(5000);
      await container.read(settingsProvider.notifier).updateGoalStartDate('2026-11-01');

      final reachedRecord = DailyRecordModel(
        date: '2026-11-02',
        title: 'school',
        startingMoney: 6000,
        expenses: const [],
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        isDeleted: false,
      );
      await container.read(recordsProvider.notifier).setRecord(reachedRecord);
      await tester.pumpAndSettle();

      // Assert "Complete & Archive" button is shown
      final archiveButton = find.byKey(const Key('complete_and_archive_button'));
      expect(archiveButton, findsOneWidget);

      // Tap and confirm
      await tester.tap(archiveButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archive'));
      await tester.pumpAndSettle();

      // Assert goalAmount == 0 and View Past Goals (1) is shown
      expect(container.read(settingsProvider).goalAmount, equals(0));
      expect(find.text('View Past Goals (1)'), findsOneWidget);

      // Open GoalHistoryModal
      await tester.ensureVisible(find.text('View Past Goals (1)'));
      await tester.tap(find.text('View Past Goals (1)'));
      await tester.pumpAndSettle();
      expect(find.byType(GoalHistoryModal), findsOneWidget);

      // Tap Undo Most Recent, confirm
      await tester.ensureVisible(find.byKey(const Key('undo_most_recent_goal_button')));
      await tester.tap(find.byKey(const Key('undo_most_recent_goal_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      // Assert goal restored (goalAmount == 5000) and count is (0)
      expect(container.read(settingsProvider).goalAmount, equals(5000));
      expect(find.text('View Past Goals (0)'), findsOneWidget);
    });

    testWidgets('Privacy masking: Banner, gauge, est days, and currency symbol',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(MonanceApp));
      final container = ProviderScope.containerOf(element);

      // Toggle privacy mode ON
      await container.read(settingsProvider.notifier).togglePrivacyMode(true);
      await tester.pumpAndSettle();

      // Assert masked values
      expect(find.text('₱ ***.**'), findsWidgets);
      expect(find.text('*** %'), findsWidgets);
      expect(find.text('***'), findsWidgets);

      // Switch currency to USD $
      await container.read(settingsProvider.notifier).updateCurrency('USD', '\$');
      await tester.pumpAndSettle();

      expect(find.text('\$ ***.**'), findsWidgets);
    });
  });
}
