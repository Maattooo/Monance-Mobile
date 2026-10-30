import 'package:intl/intl.dart';

int daysInMonth(int year, int month) => DateUtilsExt.daysInMonth(year, month);

class DateUtilsExt {
  DateUtilsExt._();

  static final DateFormat _isoDateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _isoMonthFormat = DateFormat('yyyy-MM');

  /// Determines whether [year] is a Gregorian leap year.
  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Returns the number of days in the specified [month] (1..12) of [year].
  /// Accurately handles leap years (February 29) and short months (30 days).
  static int daysInMonth(int year, int month) {
    if (month < 1 || month > 12) {
      throw ArgumentError.value(month, 'month', 'Month must be between 1 and 12');
    }
    switch (month) {
      case 2:
        return isLeapYear(year) ? 29 : 28;
      case 4:
      case 6:
      case 9:
      case 11:
        return 30;
      default:
        return 31;
    }
  }

  /// Formats a [DateTime] into `YYYY-MM-DD`.
  static String formatIsoDate(DateTime dt) {
    return _isoDateFormat.format(dt);
  }

  /// Formats a [DateTime] into `YYYY-MM`.
  static String formatIsoMonth(DateTime dt) {
    return _isoMonthFormat.format(dt);
  }

  /// Parses a `YYYY-MM-DD` string into a [DateTime] at midnight local time.
  static DateTime parseIsoDate(String dateStr) {
    return _isoDateFormat.parseStrict(dateStr);
  }

  /// Given a `YYYY-MM-DD` date string, returns the `YYYY-MM-DD` date string of the next day.
  /// Safely handles month and year roll-over.
  static String tomorrowIsoDate(String todayIsoDate) {
    final parsed = parseIsoDate(todayIsoDate);
    final tomorrow = DateTime(parsed.year, parsed.month, parsed.day + 1);
    return formatIsoDate(tomorrow);
  }

  /// Converts a `YYYY-MM` month string into a human-readable string like 'October 2026'.
  /// 'ALL' (case-insensitive) converts to 'All Time'.
  static String formatMonthYear(String isoMonth) {
    if (isoMonth.trim().toUpperCase() == 'ALL') {
      return 'All Time';
    }
    final parts = isoMonth.split('-');
    if (parts.length >= 2) {
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      if (year != null && month != null && month >= 1 && month <= 12) {
        final dt = DateTime(year, month);
        return DateFormat('MMMM yyyy', 'en_US').format(dt);
      }
    }
    return isoMonth;
  }

  /// Converts a `YYYY-MM-DD` date string into a human-readable display string like 'Oct 30, 2026'.
  static String formatDisplayDate(String isoDate) {
    try {
      final dt = parseIsoDate(isoDate);
      return DateFormat('MMM d, yyyy', 'en_US').format(dt);
    } catch (_) {
      return isoDate;
    }
  }
}
