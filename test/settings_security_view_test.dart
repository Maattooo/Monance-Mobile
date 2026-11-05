import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:monance_mobile/core/database/app_database.dart';
import 'package:monance_mobile/main.dart';
import 'package:monance_mobile/providers/database_provider.dart';
import 'package:monance_mobile/providers/security_provider.dart';
import 'package:monance_mobile/providers/settings_provider.dart';
import 'package:monance_mobile/services/local_notification_service.dart';
import 'package:monance_mobile/services/security_service.dart';
import 'package:monance_mobile/views/dashboard/dashboard_view.dart';
import 'package:monance_mobile/views/main_shell_view.dart';
import 'package:monance_mobile/views/security/pin_lock_screen.dart';
import 'package:monance_mobile/views/settings/settings_panel_view.dart';

class FakeUninitializedSecurityNotifier extends SecurityNotifier {
  FakeUninitializedSecurityNotifier(super.securityService);

  @override
  Future<void> init() async {
    // Intentionally no-op to keep state.isInitialized == false
  }
}

void main() {
  group('test/settings_security_view_test.dart (Security, PIN Gate & Settings)', () {
    late AppDatabase db;
    late InMemorySecureStorage storage;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      storage = InMemorySecureStorage();
    });

    tearDown(() async {
      await db.close();
    });

    Widget createTestApp({
      SecurityService? securityService,
      List<Override> extraOverrides = const [],
    }) {
      final sec = securityService ?? SecurityService(storage: storage);
      final notif = LocalNotificationService();

      return ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          securityServiceProvider.overrideWithValue(sec),
          localNotificationServiceProvider.overrideWithValue(notif),
          ...extraOverrides,
        ],
        child: const MonanceApp(),
      );
    }

    testWidgets('PIN gate (security-critical): Lock gates MainShellView and DashboardView',
        (tester) async {
      final sec = SecurityService(storage: storage);
      await sec.setupPin('1234');

      await tester.pumpWidget(createTestApp(securityService: sec));
      await tester.pumpAndSettle();

      // PinLockScreen must be shown
      expect(find.byType(PinLockScreen), findsOneWidget);
      // MainShellView must NOT exist in the tree
      expect(find.byType(MainShellView), findsNothing);
      // DashboardView must NOT exist in the tree
      expect(find.byType(DashboardView), findsNothing);
    });

    testWidgets('Wrong vs right PIN unlock flow', (tester) async {
      final sec = SecurityService(storage: storage);
      await sec.setupPin('1234');

      await tester.pumpWidget(createTestApp(securityService: sec));
      await tester.pumpAndSettle();

      expect(find.byType(PinLockScreen), findsOneWidget);

      // Enter wrong PIN: 9999 (auto-verifies upon 4th digit)
      await tester.enterText(find.byKey(const Key('pin_input_field')), '9999');
      await tester.pumpAndSettle();

      // Mismatch error shown, lock screen remains
      expect(find.byKey(const Key('pin_error_text')), findsOneWidget);
      expect(find.text('Incorrect PIN'), findsOneWidget);
      expect(find.byType(MainShellView), findsNothing);

      // Enter right PIN: 1234 (auto-verifies upon 4th digit)
      await tester.enterText(find.byKey(const Key('pin_input_field')), '1234');
      await tester.pumpAndSettle();

      // MainShellView renders
      expect(find.byType(PinLockScreen), findsNothing);
      expect(find.byType(MainShellView), findsOneWidget);
    });

    testWidgets('Loading screen while isInitialized == false: No financial data',
        (tester) async {
      final fakeNotifier = FakeUninitializedSecurityNotifier(SecurityService(storage: storage));
      // Keep isInitialized = false
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          securityProvider.overrideWith((ref) => fakeNotifier),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MonanceApp(),
        ),
      );
      // Pump one frame without settling
      await tester.pump();

      // Neither MainShellView nor PinLockScreen financial data
      expect(find.byType(MainShellView), findsNothing);
      expect(find.byType(PinLockScreen), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Category limits: Delete disabled at 1, 31-char rejected, duplicate rejected',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Open Settings
      await tester.tap(find.byKey(const Key('menu_button')));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPanelView), findsOneWidget);

      // Verify category delete when multiple categories exist
      final container = ProviderScope.containerOf(tester.element(find.byType(MonanceApp)));
      final notifier = container.read(settingsProvider.notifier);

      // Scroll to category section
      await tester.ensureVisible(find.byKey(const Key('new_category_name_input')));
      await tester.pumpAndSettle();

      // Add a 31-char category name
      const longName = '1234567890123456789012345678901'; // 31 chars
      await tester.enterText(find.byKey(const Key('new_category_name_input')), longName);
      await tester.tap(find.byKey(const Key('add_category_button')));
      await tester.pumpAndSettle();

      expect(find.text('Category name must be 1–30 characters'), findsOneWidget);

      // Add duplicate 'food' when 'Food' exists
      await tester.enterText(find.byKey(const Key('new_category_name_input')), 'food');
      await tester.tap(find.byKey(const Key('add_category_button')));
      await tester.pumpAndSettle();

      expect(find.text('Category already exists'), findsOneWidget);

      // Delete all categories down to 1
      final categories = container.read(settingsProvider).categories;
      for (final cat in categories.skip(1)) {
        await notifier.deleteCategory(cat.name);
      }
      await tester.pumpAndSettle();

      // Assert only 1 category remains and its delete button is disabled
      final remainingCats = container.read(settingsProvider).categories;
      expect(remainingCats.length, equals(1));

      final deleteBtnFinder = find.byKey(Key('delete_category_${remainingCats.first.name}'));
      expect(deleteBtnFinder, findsOneWidget);
      final iconButton = tester.widget<IconButton>(deleteBtnFinder);
      expect(iconButton.onPressed, isNull); // Disabled!
    });

    testWidgets('Restore failure is handled as a toast without crashing',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('menu_button')));
      await tester.pumpAndSettle();

      // Scroll to and tap restore button
      await tester.ensureVisible(find.byKey(const Key('restore_backup_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('restore_backup_button')));
      await tester.pumpAndSettle();

      // Confirm dialog appears
      expect(find.text('Restore'), findsWidgets);
      // Confirming with no file selected (or cancelled file picker) surfaces toast
      await tester.tap(find.text('Restore').last);
      await tester.pumpAndSettle();

      // Toast appears and app did not crash
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
