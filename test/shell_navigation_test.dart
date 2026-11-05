import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:monance_mobile/core/database/app_database.dart';
import 'package:monance_mobile/core/utils/date_utils_ext.dart';
import 'package:monance_mobile/main.dart';
import 'package:monance_mobile/providers/database_provider.dart';
import 'package:monance_mobile/providers/security_provider.dart';
import 'package:monance_mobile/providers/settings_provider.dart';
import 'package:monance_mobile/providers/theme_provider.dart';
import 'package:monance_mobile/services/local_notification_service.dart';
import 'package:monance_mobile/services/security_service.dart';
import 'package:monance_mobile/views/analytics/analytics_view.dart';
import 'package:monance_mobile/views/bills/bills_view.dart';
import 'package:monance_mobile/views/calendar/calendar_view.dart';
import 'package:monance_mobile/views/calendar/daily_modal.dart';
import 'package:monance_mobile/views/dashboard/dashboard_view.dart';
import 'package:monance_mobile/views/hangouts/hangouts_view.dart';
import 'package:monance_mobile/views/main_shell_view.dart';
import 'package:monance_mobile/views/settings/settings_panel_view.dart';

void main() {
  group('test/shell_navigation_test.dart (5-Tab Shell & Navigation)', () {
    late AppDatabase db;
    late InMemorySecureStorage storage;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      storage = InMemorySecureStorage();
    });

    tearDown(() async {
      await db.close();
    });

    Widget createTestApp({List<Override> extraOverrides = const []}) {
      final secService = SecurityService(storage: storage);
      final notifService = LocalNotificationService();

      return ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          securityServiceProvider.overrideWithValue(secService),
          localNotificationServiceProvider.overrideWithValue(notifService),
          themeProvider.overrideWith((ref) {
            final isDark = ref.watch(settingsProvider.select((s) => s.themeIsDark));
            return ThemeNotifier(ref, isDark);
          }),
          ...extraOverrides,
        ],
        child: const MonanceApp(),
      );
    }

    testWidgets('Five tabs in order: Switch visible IndexedStack child', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(MainShellView), findsOneWidget);

      // Assert 5 bottom bar destinations
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
      expect(find.text('Bills'), findsOneWidget);
      expect(find.text('Hangouts'), findsOneWidget);

      // Tab 0: Home (DashboardView is visible)
      final indexedStack0 = tester.widget<IndexedStack>(find.byKey(const Key('main_shell_indexed_stack')));
      expect(indexedStack0.index, equals(0));
      expect(find.byType(DashboardView), findsOneWidget);

      // Tap Calendar
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      final indexedStack1 = tester.widget<IndexedStack>(find.byKey(const Key('main_shell_indexed_stack')));
      expect(indexedStack1.index, equals(1));
      expect(find.byType(CalendarView), findsOneWidget);

      // Tap Analytics
      await tester.tap(find.text('Analytics'));
      await tester.pumpAndSettle();
      final indexedStack2 = tester.widget<IndexedStack>(find.byKey(const Key('main_shell_indexed_stack')));
      expect(indexedStack2.index, equals(2));
      expect(find.byType(AnalyticsView), findsOneWidget);

      // Tap Bills
      await tester.tap(find.text('Bills'));
      await tester.pumpAndSettle();
      final indexedStack3 = tester.widget<IndexedStack>(find.byKey(const Key('main_shell_indexed_stack')));
      expect(indexedStack3.index, equals(3));
      expect(find.byType(BillsView), findsOneWidget);

      // Tap Hangouts
      await tester.tap(find.text('Hangouts'));
      await tester.pumpAndSettle();
      final indexedStack4 = tester.widget<IndexedStack>(find.byKey(const Key('main_shell_indexed_stack')));
      expect(indexedStack4.index, equals(4));
      expect(find.byType(HangoutsView), findsOneWidget);
    });

    testWidgets('FAB opens today\'s modal and has BorderRadius.zero', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final fabFinder = find.byKey(const Key('daily_modal_fab'));
      expect(fabFinder, findsOneWidget);

      final fabWidget = tester.widget<FloatingActionButton>(fabFinder);
      expect(fabWidget.shape, isA<RoundedRectangleBorder>());
      final shape = fabWidget.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, equals(BorderRadius.zero));

      await tester.tap(fabFinder);
      await tester.pumpAndSettle();

      expect(find.byType(DailyModal), findsOneWidget);
      final todayIso = DateUtilsExt.formatIsoDate(DateTime.now());
      final expectedDateHeader = DateUtilsExt.formatDisplayDate(todayIso);
      expect(find.text(expectedDateHeader), findsOneWidget);
    });

    testWidgets('Theme toggle persists and flips MaterialApp themeMode', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final appFinder = find.byType(MaterialApp);
      final initialApp = tester.widget<MaterialApp>(appFinder);
      expect(initialApp.themeMode, equals(ThemeMode.dark));

      // Tap theme toggle button
      await tester.tap(find.byKey(const Key('theme_toggle_button')));
      await tester.pumpAndSettle();

      final updatedApp = tester.widget<MaterialApp>(appFinder);
      expect(updatedApp.themeMode, equals(ThemeMode.light));
    });

    testWidgets('Menu opens SettingsPanelView with 4 accordion headers', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('menu_button')));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPanelView), findsOneWidget);
      expect(find.text('Goal & Wallet Settings'), findsOneWidget);
      expect(find.text('Manage Monthly Bills'), findsOneWidget);
      expect(find.text('Manage Expense Categories'), findsOneWidget);
      expect(find.text('Security & Offline Backup'), findsOneWidget);
    });
  });
}
