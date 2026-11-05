import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils_ext.dart';
import '../../providers/records_provider.dart';
import 'daily_modal.dart';

class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month, 1);
  }

  void _goToPrevMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    });
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _displayedMonth = DateTime(now.year, now.month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final recordsMap = ref.watch(recordsProvider);

    // Compute 42 day cells
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final leadingDays = firstDayOfMonth.weekday % 7; // Sunday = 0, Monday = 1, etc.
    final startDate = firstDayOfMonth.subtract(Duration(days: leadingDays));

    final dayCells = List.generate(42, (index) {
      return DateTime(startDate.year, startDate.month, startDate.day + index);
    });

    final weekHeaders = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Navigation Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.bgCard,
                  border: Border.all(color: colors.borderColor, width: 1),
                  borderRadius: BorderRadius.zero,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(_displayedMonth),
                      key: const Key('calendar_month_text'),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          key: const Key('prev_month_button'),
                          onPressed: _goToPrevMonth,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colors.borderColor, width: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: const Size(36, 32),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: Text(
                            'Prev',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        OutlinedButton(
                          key: const Key('today_button'),
                          onPressed: _goToToday,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colors.borderColor, width: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: const Size(42, 32),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: Text(
                            'Today',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        OutlinedButton(
                          key: const Key('next_month_button'),
                          onPressed: _goToNextMonth,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colors.borderColor, width: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: const Size(36, 32),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: Text(
                            'Next',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Sun-Sat Day Headers
              Container(
                decoration: BoxDecoration(
                  color: colors.bgCard,
                  border: Border.all(color: colors.borderColor, width: 1),
                  borderRadius: BorderRadius.zero,
                ),
                child: Column(
                  children: [
                    Container(
                      color: colors.bgSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: weekHeaders.map((day) {
                          return Expanded(
                            child: Text(
                              day,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colors.textSecondary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // 6-row 42-cell Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 42,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1.0,
                      ),
                      itemBuilder: (context, index) {
                        final cellDate = dayCells[index];
                        final isoDate = DateUtilsExt.formatIsoDate(cellDate);
                        final isCurrentMonth = cellDate.month == _displayedMonth.month;
                        final record = recordsMap[isoDate];
                        final bool hasRecord = record != null && !record.isDeleted;

                        Color? dotColor;
                        if (hasRecord) {
                          final remaining = record.remainingAllowance;
                          if (remaining < 0) {
                            dotColor = colors.colorDanger;
                          } else if (record.startingMoney > 0 && remaining >= 0) {
                            dotColor = colors.colorSuccess;
                          } else {
                            dotColor = colors.textMuted;
                          }
                        }

                        return InkWell(
                          key: Key('calendar_day_cell_$isoDate'),
                          onTap: () => DailyModal.show(context, isoDate),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isCurrentMonth ? colors.bgCard : colors.bgSecondary,
                              border: Border.all(
                                color: colors.borderColor,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.zero,
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    '${cellDate.day}',
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontFamily,
                                      fontSize: 13,
                                      fontWeight: isCurrentMonth
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isCurrentMonth
                                          ? colors.textPrimary
                                          : colors.textMuted,
                                    ),
                                  ),
                                ),
                                if (dotColor != null)
                                  Positioned(
                                    bottom: 4,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Container(
                                        key: Key('cell_dot_$isoDate'),
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: dotColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
