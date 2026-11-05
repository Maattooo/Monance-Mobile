import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:monance_mobile/core/database/app_database.dart';
import 'package:monance_mobile/core/theme/app_theme.dart';
import 'package:monance_mobile/main.dart';
import 'package:monance_mobile/models/daily_record_model.dart';
import 'package:monance_mobile/models/expense_model.dart';
import 'package:monance_mobile/providers/analytics_provider.dart';
import 'package:monance_mobile/providers/bills_provider.dart';
import 'package:monance_mobile/providers/database_provider.dart';
import 'package:monance_mobile/providers/records_provider.dart';
import 'package:monance_mobile/providers/security_provider.dart';
import 'package:monance_mobile/services/local_notification_service.dart';
import 'package:monance_mobile/services/security_service.dart';
import 'package:monance_mobile/views/analytics/analytics_view.dart';
import 'package:monance_mobile/views/bills/bills_view.dart';

void main() {
  group('test/bills_analytics_view_test.dart (Bills View & Analytics View)', () {
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

    testWidgets('Bills sorting, status labels, checkbox toggle, and reset',
        (tester) async {
      final sec = SecurityService(storage: storage);
      final notif = LocalNotificationService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            securityServiceProvider.overrideWithValue(sec),
            localNotificationServiceProvider.overrideWithValue(notif),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: BillsView(now: DateTime(2026, 4, 30)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(BillsView));
      final container = ProviderScope.containerOf(element);

      // Seed 3 bills with dueDay: 31, 5, 15
      await container.read(billsProvider.notifier).addBill(
            title: 'Internet',
            amount: 150000,
            dueDay: 31,
          );
      final bill5 = await container.read(billsProvider.notifier).addBill(
            title: 'Water',
            amount: 50000,
            dueDay: 5,
          );
      final bill15 = await container.read(billsProvider.notifier).addBill(
            title: 'Electric',
            amount: 200000,
            dueDay: 15,
          );

      // Mark bill15 as paid
      await container.read(billsProvider.notifier).toggleBillPaid(bill15.id, true);
      await tester.pumpAndSettle();

      expect(find.byType(BillsView), findsOneWidget);

      // Verify rendering order in widget tree: Water (5), Electric (15), Internet (31)
      final waterFinder = find.text('Water');
      final electricFinder = find.text('Electric');
      final internetFinder = find.text('Internet');

      expect(waterFinder, findsOneWidget);
      expect(electricFinder, findsOneWidget);
      expect(internetFinder, findsOneWidget);

      final waterTop = tester.getTopLeft(waterFinder).dy;
      final electricTop = tester.getTopLeft(electricFinder).dy;
      final internetTop = tester.getTopLeft(internetFinder).dy;

      // Sorted by dueDay ascending: 5 < 15 < 31
      expect(waterTop < electricTop, isTrue);
      expect(electricTop < internetTop, isTrue);

      // Assert Electric shows 'Paid'
      expect(find.text('Paid'), findsOneWidget);

      // Assert Internet (dueDay = 31 under 2026-04-30) shows 'Due Today!'
      expect(find.text('Due Today!'), findsOneWidget);

      // Assert unpaid count and total in header
      // Total unpaid = 150000 + 50000 = 200000 cents (₱2,000.00)
      expect(find.text('2 unpaid · ₱2,000.00'), findsOneWidget);

      // Tap checkbox for Water to toggle paid
      await tester.tap(find.byKey(Key('bill_checkbox_${bill5.id}')));
      await tester.pumpAndSettle();

      // Check Drift SQLite persistence
      final row5 = await (db.select(db.monthlyBillsTable)..where((t) => t.id.equals(bill5.id))).getSingle();
      expect(row5.isPaid, isTrue);

      // Test Reset Bills button
      await tester.tap(find.byKey(const Key('reset_bills_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset Bills').last);
      await tester.pumpAndSettle();

      // Assert all bills reset to unpaid (isPaid = false)
      final allBills = await db.select(db.monthlyBillsTable).get();
      for (final b in allBills) {
        expect(b.isPaid, isFalse);
      }
    });

    testWidgets('Analytics Month-over-Month calculation and period filtering',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(MonanceApp));
      final container = ProviderScope.containerOf(element);

      // Seed 2026-09 = 10000 cents (₱100.00) and 2026-10 = 12500 cents (₱125.00)
      final sepRecord = DailyRecordModel(
        date: '2026-09-15',
        title: 'school',
        startingMoney: 0,
        expenses: [
          ExpenseModel(
            id: 'exp-sep',
            date: '2026-09-15',
            title: 'Books',
            amount: 10000,
            category: 'Study',
            deductFrom: 'allowance',
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        ],
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        isDeleted: false,
      );

      final octRecord = DailyRecordModel(
        date: '2026-10-15',
        title: 'school',
        startingMoney: 0,
        expenses: [
          ExpenseModel(
            id: 'exp-oct',
            date: '2026-10-15',
            title: 'Tuition',
            amount: 12500,
            category: 'Study',
            deductFrom: 'allowance',
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        ],
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        isDeleted: false,
      );

      await container.read(recordsProvider.notifier).setRecord(sepRecord);
      await container.read(recordsProvider.notifier).setRecord(octRecord);
      await tester.pumpAndSettle();

      // Navigate to Analytics
      await tester.tap(find.text('Analytics'));
      await tester.pumpAndSettle();
      expect(find.byType(AnalyticsView), findsOneWidget);

      // Select October 2026: MoM change from 10000 to 12500 = +25.0%
      container.read(selectedMonthFilterProvider.notifier).state = '2026-10';
      await tester.pumpAndSettle();

      expect(find.text('▲ 25.0%'), findsOneWidget);
      expect(find.text('₱125.00'), findsWidgets);

      // Select September 2026: preceding month has no data -> 'No prev data'
      container.read(selectedMonthFilterProvider.notifier).state = '2026-09';
      await tester.pumpAndSettle();

      expect(find.text('No prev data'), findsOneWidget);
      expect(find.text('₱100.00'), findsWidgets);

      // Select All Time: total = 10000 + 12500 = 22500 cents = ₱225.00
      container.read(selectedMonthFilterProvider.notifier).state = 'ALL';
      await tester.pumpAndSettle();

      expect(find.text('₱225.00'), findsWidgets);
    });

    testWidgets('Analytics empty state renders gracefully without throwing',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to Analytics with 0 records
      await tester.tap(find.text('Analytics'));
      await tester.pumpAndSettle();

      expect(find.byType(AnalyticsView), findsOneWidget);
      expect(find.byKey(const Key('analytics_empty_state_text')), findsOneWidget);
      expect(find.text('No expenses recorded for this period.'), findsOneWidget);
    });
  });
}
