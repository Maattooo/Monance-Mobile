import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:intl/intl.dart';
import 'package:monance_mobile/core/database/app_database.dart';
import 'package:monance_mobile/core/theme/app_theme.dart';
import 'package:monance_mobile/main.dart';
import 'package:monance_mobile/models/daily_record_model.dart';
import 'package:monance_mobile/providers/database_provider.dart';
import 'package:monance_mobile/providers/records_provider.dart';
import 'package:monance_mobile/providers/security_provider.dart';
import 'package:monance_mobile/providers/settings_provider.dart';
import 'package:monance_mobile/services/local_notification_service.dart';
import 'package:monance_mobile/services/security_service.dart';
import 'package:monance_mobile/views/calendar/calendar_view.dart';
import 'package:monance_mobile/views/calendar/daily_modal.dart';
import 'package:monance_mobile/views/main_shell_view.dart';

void main() {
  group('test/calendar_daily_modal_test.dart (Calendar Grid & Daily Modal)', () {
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

    testWidgets('42-cell grid renders for 2026-02 and 2026-08', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to Calendar tab
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarView), findsOneWidget);

      Future<void> navigateTo(String targetMonthYear) async {
        final targetDate = DateFormat('MMMM yyyy').parse(targetMonthYear);
        for (int i = 0; i < 48; i++) {
          final currentText = tester
              .widget<Text>(find.byKey(const Key('calendar_month_text')))
              .data!;
          if (currentText == targetMonthYear) break;
          final currentDate = DateFormat('MMMM yyyy').parse(currentText);
          if (currentDate.isAfter(targetDate)) {
            await tester.tap(find.byKey(const Key('prev_month_button')));
          } else {
            await tester.tap(find.byKey(const Key('next_month_button')));
          }
          await tester.pumpAndSettle();
        }
      }

      // 1. Navigate to 2026-02 (February 2026)
      await navigateTo('February 2026');
      expect(find.text('February 2026'), findsOneWidget);

      final febGridFinder = find.byType(GridView);
      expect(febGridFinder, findsOneWidget);
      final febCells = tester
          .widget<GridView>(febGridFinder)
          .childrenDelegate
          .estimatedChildCount;
      expect(febCells, equals(42));

      // 2. Navigate to 2026-08 (August 2026)
      await navigateTo('August 2026');
      expect(find.text('August 2026'), findsOneWidget);

      final augGridFinder = find.byType(GridView);
      expect(augGridFinder, findsOneWidget);
      final augCells = tester
          .widget<GridView>(augGridFinder)
          .childrenDelegate
          .estimatedChildCount;
      expect(augCells, equals(42));
    });

    testWidgets('Uninitialized day cards: Action cards initialize startingMoney',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(MonanceApp));
      final container = ProviderScope.containerOf(element);

      // Set default allowance = 15000 cents (₱150.00)
      await container.read(settingsProvider.notifier).updateAllowance(15000);
      await tester.pumpAndSettle();

      // Open DailyModal for empty date
      const emptyDate = '2026-11-20';
      final ctx = tester.element(find.byType(MainShellView));
      DailyModal.show(ctx, emptyDate);
      await tester.pumpAndSettle();

      expect(find.byType(DailyModal), findsOneWidget);
      expect(find.text('School / Work (+₱150.00)'), findsOneWidget);
      expect(find.text('Rest Day (₱0.00)'), findsOneWidget);

      // Tap School / Work card
      await tester.tap(find.byKey(const Key('school_work_card')));
      await tester.pumpAndSettle();

      // Assert record created with startingMoney == 15000
      final record = container.read(recordsProvider)[emptyDate];
      expect(record, isNotNull);
      expect(record!.startingMoney, equals(15000));
      expect(record.isDeleted, isFalse);
    });

    testWidgets(
        'Wallet expense never overspends (§6.4): Allowance isolation & cell dot color',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(MonanceApp));
      final container = ProviderScope.containerOf(element);

      // Seed allowance day with startingMoney = 5000 (₱50.00)
      const testDate = '2026-11-15';
      await container.read(recordsProvider.notifier).setRecord(
            DailyRecordModel(
              date: testDate,
              title: 'school',
              startingMoney: 5000,
              updatedAt: DateTime.now().millisecondsSinceEpoch,
              isDeleted: false,
            ),
          );

      // Open DailyModal
      final ctx = tester.element(find.byType(MainShellView));
      DailyModal.show(ctx, testDate);
      await tester.pumpAndSettle();

      // Add a 'balance' expense of 8000 (₱80.00)
      await tester.tap(find.byKey(const Key('tab_add_expense_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('deduct_wallet_button')));
      await tester.enterText(find.byKey(const Key('expense_title_input')), 'New Shoes');
      await tester.enterText(find.byKey(const Key('expense_amount_input')), '80');
      await tester.ensureVisible(find.byKey(const Key('submit_expense_button')));
      await tester.tap(find.byKey(const Key('submit_expense_button')));
      await tester.pumpAndSettle();

      // Assert remaining badge is ₱50.00, color is colorSuccess, no overspent warning
      expect(find.text('₱50.00'), findsOneWidget);
      expect(find.text(' remaining'), findsOneWidget);
      expect(find.byKey(const Key('overspent_warning')), findsNothing);

      final badgeText = tester.widget<Text>(find.text('₱50.00'));
      expect(badgeText.style?.color, equals(AppTheme.darkColors.colorSuccess));

      // Test clickable remaining / spent toggle
      await tester.tap(find.byKey(const Key('toggle_remaining_spent_button')));
      await tester.pumpAndSettle();
      expect(find.text(' spent'), findsOneWidget);
      // Total spent = 80 (wallet expense) = 80.00 inside remaining_badge
      expect(
        find.descendant(
          of: find.byKey(const Key('remaining_badge')),
          matching: find.text('₱80.00'),
        ),
        findsOneWidget,
      );

      // Tap again to toggle back to remaining
      await tester.tap(find.byKey(const Key('toggle_remaining_spent_button')));
      await tester.pumpAndSettle();
      expect(find.text(' remaining'), findsOneWidget);
      expect(find.text('₱50.00'), findsOneWidget);

      // Close modal and navigate to calendar to check cell dot
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      // Dot exists and is green
      final dotFinder = find.byKey(const Key('cell_dot_2026-11-15'));
      expect(dotFinder, findsOneWidget);
      final dotContainer = tester.widget<Container>(dotFinder);
      final dotDeco = dotContainer.decoration as BoxDecoration;
      expect(dotDeco.color, equals(AppTheme.darkColors.colorSuccess));

      // Re-open modal and add an 'allowance' expense of 6000 (₱60.00)
      DailyModal.show(tester.element(find.byType(MainShellView)), testDate);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tab_add_expense_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('deduct_allowance_button')));
      await tester.enterText(find.byKey(const Key('expense_title_input')), 'Dinner');
      await tester.enterText(find.byKey(const Key('expense_amount_input')), '60');
      await tester.ensureVisible(find.byKey(const Key('submit_expense_button')));
      await tester.tap(find.byKey(const Key('submit_expense_button')));
      await tester.pumpAndSettle();

      // Assert remaining badge is -₱10.00, color is colorDanger, overspent warning visible
      expect(find.text('-₱10.00'), findsOneWidget);
      expect(find.byKey(const Key('overspent_warning')), findsOneWidget);

      final overspentBadgeText = tester.widget<Text>(find.text('-₱10.00'));
      expect(overspentBadgeText.style?.color, equals(AppTheme.darkColors.colorDanger));
    });

    testWidgets('Persisted strings: deductFrom persisted as allowance / balance in Drift',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      const testDate = '2026-11-10';
      DailyModal.show(tester.element(find.byType(MainShellView)), testDate);
      await tester.pumpAndSettle();

      // Initialize as school day
      await tester.tap(find.byKey(const Key('school_work_card')));
      await tester.pumpAndSettle();

      // Add allowance expense
      await tester.tap(find.byKey(const Key('tab_add_expense_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('deduct_allowance_button')));
      await tester.enterText(find.byKey(const Key('expense_title_input')), 'Snack');
      await tester.enterText(find.byKey(const Key('expense_amount_input')), '15');
      await tester.ensureVisible(find.byKey(const Key('submit_expense_button')));
      await tester.tap(find.byKey(const Key('submit_expense_button')));
      await tester.pumpAndSettle();

      // Add balance expense
      await tester.tap(find.byKey(const Key('tab_add_expense_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('deduct_wallet_button')));
      await tester.enterText(find.byKey(const Key('expense_title_input')), 'Gadget');
      await tester.enterText(find.byKey(const Key('expense_amount_input')), '50');
      await tester.ensureVisible(find.byKey(const Key('submit_expense_button')));
      await tester.tap(find.byKey(const Key('submit_expense_button')));
      await tester.pumpAndSettle();

      // Check Drift SQLite rows directly
      final rows = await db.select(db.expensesTable).get();
      final deductTypes = rows.map((r) => r.deductFrom).toList();
      expect(deductTypes, contains('allowance'));
      expect(deductTypes, contains('balance'));
      expect(deductTypes, isNot(contains('daily')));
      expect(deductTypes, isNot(contains('wallet')));
    });

    testWidgets('Clear Day leaves settings.currentBalance completely unchanged',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(MonanceApp));
      final container = ProviderScope.containerOf(element);

      await container.read(settingsProvider.notifier).updateCurrentBalance(25000);
      const testDate = '2026-11-05';
      await container.read(recordsProvider.notifier).setRecord(
            DailyRecordModel(
              date: testDate,
              title: 'school',
              startingMoney: 5000,
              updatedAt: DateTime.now().millisecondsSinceEpoch,
              isDeleted: false,
            ),
          );
      await tester.pumpAndSettle();

      // Open modal and confirm Clear Day
      DailyModal.show(tester.element(find.byType(MainShellView)), testDate);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('clear_day_button')));
      await tester.pumpAndSettle();

      // Confirm dialog
      await tester.tap(find.text('Clear Day').last);
      await tester.pumpAndSettle();

      // Assert record is deleted
      final record = container.read(recordsProvider)[testDate];
      expect(record?.isDeleted, isTrue);

      // Invariant: settings.currentBalance is STILL 25000
      expect(container.read(settingsProvider).currentBalance, equals(25000));
    });
  });
}
