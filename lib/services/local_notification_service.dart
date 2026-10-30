import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../core/utils/date_utils_ext.dart';
import '../models/monthly_bill_model.dart';

typedef ScheduleZonedCallback = Future<void> Function({
  required int id,
  required String? title,
  required String? body,
  required DateTime scheduledDate,
});

typedef CancelCallback = Future<void> Function();
typedef RequestPermissionCallback = Future<bool> Function();

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin? _plugin;
  final ScheduleZonedCallback? onScheduleZoned;
  final CancelCallback? onCancelAll;
  final RequestPermissionCallback? onRequestPermission;

  static bool _timeZonesInitialized = false;

  LocalNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    this.onScheduleZoned,
    this.onCancelAll,
    this.onRequestPermission,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static void ensureTimeZonesInitialized() {
    if (!_timeZonesInitialized) {
      try {
        tz.initializeTimeZones();
        _timeZonesInitialized = true;
      } catch (_) {
        // Safe fallback in test or headless environments
      }
    }
  }

  Future<void> init() async {
    ensureTimeZonesInitialized();
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      await _plugin?.initialize(initSettings);
    } catch (_) {
      // Ignored for headless tests
    }
  }

  /// Calculates the next occurrence of a bill's effective due day at 09:00 local time.
  /// If `now` is at or past 09:00 on the current month's effective due day,
  /// rolls forward to the next calendar month.
  static DateTime calculateNextReminderDate(int dueDay, [DateTime? now]) {
    final current = now ?? DateTime.now();
    final clampedDueDay = dueDay.clamp(1, 31);

    // Current month effective due day
    final currentDaysInMonth =
        DateUtilsExt.daysInMonth(current.year, current.month);
    final effectiveDayThisMonth = min(clampedDueDay, currentDaysInMonth);
    final targetThisMonth = DateTime(
      current.year,
      current.month,
      effectiveDayThisMonth,
      9,
      0,
      0,
    );

    // If current time is strictly before 09:00 on this month's effective due day,
    // this month's date is the next occurrence.
    if (current.isBefore(targetThisMonth)) {
      return targetThisMonth;
    }

    // Otherwise, roll forward to next calendar month
    final nextMonthYear = current.month == 12 ? current.year + 1 : current.year;
    final nextMonth = current.month == 12 ? 1 : current.month + 1;
    final nextDaysInMonth =
        DateUtilsExt.daysInMonth(nextMonthYear, nextMonth);
    final effectiveDayNextMonth = min(clampedDueDay, nextDaysInMonth);

    return DateTime(
      nextMonthYear,
      nextMonth,
      effectiveDayNextMonth,
      9,
      0,
      0,
    );
  }

  /// Calculates the 1-day-prior reminder timestamp (at 09:00 local time).
  static DateTime calculateOneDayPriorReminderDate(int dueDay, [DateTime? now]) {
    final nextDueDate = calculateNextReminderDate(dueDay, now);
    return nextDueDate.subtract(const Duration(days: 1));
  }

  Future<bool> requestPermissions() async {
    try {
      if (onRequestPermission != null) {
        return await onRequestPermission!();
      }

      final android = _plugin?.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final androidGranted = await android?.requestNotificationsPermission();

      final ios = _plugin?.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final iosGranted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      return (androidGranted ?? iosGranted) ?? true;
    } catch (_) {
      return false;
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      if (onCancelAll != null) {
        await onCancelAll!();
        return;
      }
      await _plugin?.cancelAll();
    } catch (_) {
      // Safe fallback
    }
  }

  Future<void> scheduleBillReminder(
    MonthlyBillModel bill, {
    DateTime? now,
  }) async {
    if (bill.isPaid) return;

    final current = now ?? DateTime.now();
    final dueDate = calculateNextReminderDate(bill.dueDay, current);
    final priorDate = dueDate.subtract(const Duration(days: 1));

    final baseId = (bill.id.hashCode & 0x3FFFFFFF) * 2;
    final dueId = baseId;
    final priorId = baseId + 1;

    final amountStr = (bill.amount / 100).toStringAsFixed(2);
    final dueTitle = 'Bill Due Today: ${bill.title}';
    final dueBody = 'Your bill of $amountStr is due today!';
    final priorTitle = 'Bill Due Tomorrow: ${bill.title}';
    final priorBody = 'Reminder: Your bill of $amountStr is due tomorrow.';

    // Schedule due date reminder at 09:00
    await _scheduleNotification(
      id: dueId,
      title: dueTitle,
      body: dueBody,
      scheduledDate: dueDate,
    );

    // Schedule 1-day prior reminder if it's in the future
    if (priorDate.isAfter(current)) {
      await _scheduleNotification(
        id: priorId,
        title: priorTitle,
        body: priorBody,
        scheduledDate: priorDate,
      );
    }
  }

  Future<void> rescheduleBillNotifications(
    List<MonthlyBillModel> bills, {
    bool enabled = true,
    DateTime? now,
  }) async {
    await cancelAllNotifications();
    if (!enabled) return;

    final current = now ?? DateTime.now();
    for (final bill in bills) {
      if (!bill.isPaid) {
        await scheduleBillReminder(bill, now: current);
      }
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      if (onScheduleZoned != null) {
        await onScheduleZoned!(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
        );
        return;
      }

      ensureTimeZonesInitialized();
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
      const androidDetails = AndroidNotificationDetails(
        'bill_reminders_channel',
        'Bill Reminders',
        channelDescription:
            'Notifications for upcoming and due monthly recurring bills',
        importance: Importance.high,
        priority: Priority.high,
      );
      const iosDetails = DarwinNotificationDetails();
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin?.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      // Safe fallback if plugin not registered or permissions missing
    }
  }
}

final localNotificationServiceProvider =
    Provider<LocalNotificationService>((ref) {
  final service = LocalNotificationService();
  service.init();
  return service;
});
