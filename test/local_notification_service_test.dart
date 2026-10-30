import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:monance_mobile/core/database/app_database.dart';
import 'package:monance_mobile/models/monthly_bill_model.dart';
import 'package:monance_mobile/providers/bills_provider.dart';
import 'package:monance_mobile/providers/database_provider.dart';
import 'package:monance_mobile/providers/settings_provider.dart';
import 'package:monance_mobile/services/local_notification_service.dart';

void main() {
  group('test/local_notification_service_test.dart (Offline Bill Reminders)', () {
    test('Short-month clamping & rollover scheduling math', () {
      // Bill with dueDay = 31
      const dueDay = 31;

      // 1. Current date 2026-02-10 08:00
      final now1 = DateTime(2026, 2, 10, 8, 0);
      final nextReminder1 = LocalNotificationService.calculateNextReminderDate(dueDay, now1);
      final priorReminder1 = LocalNotificationService.calculateOneDayPriorReminderDate(dueDay, now1);

      // In 2026 (non-leap), February has 28 days -> clamped to 2026-02-28 09:00
      expect(nextReminder1, equals(DateTime(2026, 2, 28, 9, 0)));
      expect(priorReminder1, equals(DateTime(2026, 2, 27, 9, 0)));

      // 2. Current date 2026-02-28 10:00 (after 09:00 on effective due day)
      final now2 = DateTime(2026, 2, 28, 10, 0);
      final nextReminder2 = LocalNotificationService.calculateNextReminderDate(dueDay, now2);
      final priorReminder2 = LocalNotificationService.calculateOneDayPriorReminderDate(dueDay, now2);

      // Rolls forward to next calendar month (March has 31 days) -> 2026-03-31 09:00
      expect(nextReminder2, equals(DateTime(2026, 3, 31, 9, 0)));
      expect(priorReminder2, equals(DateTime(2026, 3, 30, 9, 0)));

      // 3. Current date 2026-02-28 09:00 (at exact moment of 09:00 cutoff)
      final now3 = DateTime(2026, 2, 28, 9, 0);
      final nextReminder3 = LocalNotificationService.calculateNextReminderDate(dueDay, now3);
      // At or past 09:00 rolls forward
      expect(nextReminder3, equals(DateTime(2026, 3, 31, 9, 0)));

      // 4. Year boundary rollover: 2026-12-31 10:00
      final nowDec = DateTime(2026, 12, 31, 10, 0);
      final nextReminderDec = LocalNotificationService.calculateNextReminderDate(dueDay, nowDec);
      expect(nextReminderDec, equals(DateTime(2027, 1, 31, 9, 0)));

      // 5. Leap year February 2028 (29 days)
      final nowLeap = DateTime(2028, 2, 1, 8, 0);
      final nextReminderLeap = LocalNotificationService.calculateNextReminderDate(dueDay, nowLeap);
      expect(nextReminderLeap, equals(DateTime(2028, 2, 29, 9, 0)));
    });

    test('Unpaid filter & permission resilience', () async {
      final scheduledList = <Map<String, dynamic>>[];
      bool cancelledAll = false;

      final mockNotificationService = LocalNotificationService(
        onScheduleZoned: ({
          required int id,
          required String? title,
          required String? body,
          required DateTime scheduledDate,
        }) async {
          scheduledList.add({
            'id': id,
            'title': title,
            'body': body,
            'scheduledDate': scheduledDate,
          });
        },
        onCancelAll: () async {
          cancelledAll = true;
          scheduledList.clear();
        },
        onRequestPermission: () async {
          throw Exception('Simulated OS Permission Error');
        },
      );

      // 1. Permission request throws simulated exception -> must return false without crashing
      final permResult = await mockNotificationService.requestPermissions();
      expect(permResult, isFalse);

      // 2. Setup bills: 1 unpaid, 1 paid
      const unpaidBill = MonthlyBillModel(
        id: 'bill-unpaid',
        title: 'Electricity',
        amount: 350000,
        dueDay: 20,
        isPaid: false,
      );

      const paidBill = MonthlyBillModel(
        id: 'bill-paid',
        title: 'Water',
        amount: 80000,
        dueDay: 15,
        isPaid: true,
      );

      final testNow = DateTime(2026, 2, 10, 8, 0);

      // Reschedule with notifications enabled
      await mockNotificationService.rescheduleBillNotifications(
        [unpaidBill, paidBill],
        enabled: true,
        now: testNow,
      );

      expect(cancelledAll, isTrue);
      // Should only schedule reminders for unpaid bill
      // 1 for due date (2026-02-20 09:00), 1 for 1-day-prior (2026-02-19 09:00)
      expect(scheduledList.length, equals(2));
      expect(scheduledList.every((n) => (n['title'] as String).contains('Electricity')), isTrue);
      expect(scheduledList.any((n) => (n['title'] as String).contains('Water')), isFalse);

      // 3. Toggling billNotificationsEnabled == false cancels all notifications
      await mockNotificationService.rescheduleBillNotifications(
        [unpaidBill, paidBill],
        enabled: false,
        now: testNow,
      );
      expect(scheduledList, isEmpty);
    });

    test('Integration: BillsNotifier and SettingsNotifier notification lifecycle', () async {
      final scheduledList = <Map<String, dynamic>>[];
      int cancelCount = 0;

      final testService = LocalNotificationService(
        onScheduleZoned: ({
          required int id,
          required String? title,
          required String? body,
          required DateTime scheduledDate,
        }) async {
          scheduledList.add({
            'id': id,
            'title': title,
            'body': body,
            'scheduledDate': scheduledDate,
          });
        },
        onCancelAll: () async {
          cancelCount++;
          scheduledList.clear();
        },
      );

      final db = AppDatabase(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          localNotificationServiceProvider.overrideWithValue(testService),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      final settingsNotifier = container.read(settingsProvider.notifier);
      final billsNotifier = container.read(billsProvider.notifier);

      await settingsNotifier.loadSettings();
      await billsNotifier.loadBills();

      // Enable notifications in settings
      await settingsNotifier.toggleBillNotifications(true);
      expect(container.read(settingsProvider).billNotificationsEnabled, isTrue);

      // Adding bill reschedules notifications
      final bill = await billsNotifier.addBill(
        title: 'Internet Fiber',
        amount: 150000,
        dueDay: 25,
      );
      expect(container.read(billsProvider).length, equals(1));
      expect(scheduledList.isNotEmpty, isTrue);

      // Defensive check: toggle non-existent bill ID does not throw StateError
      expect(
        () async => await billsNotifier.toggleBillPaid('non-existent-uuid', true),
        returnsNormally,
      );

      // Toggle bill to paid -> notifications are cancelled & not rescheduled for paid bill
      await billsNotifier.toggleBillPaid(bill.id, true);
      expect(container.read(billsProvider).first.isPaid, isTrue);
      expect(scheduledList, isEmpty);

      // Reset bills -> bill becomes unpaid and notifications are rescheduled
      await billsNotifier.resetAllBills();
      expect(container.read(billsProvider).first.isPaid, isFalse);
      expect(scheduledList.isNotEmpty, isTrue);

      // Disabling notifications cancels everything
      await settingsNotifier.toggleBillNotifications(false);
      expect(scheduledList, isEmpty);
      expect(cancelCount, greaterThan(0));
    });
  });
}
