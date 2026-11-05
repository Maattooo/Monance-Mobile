import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_utils_ext.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/settings_provider.dart';

class AnalyticsView extends ConsumerWidget {
  const AnalyticsView({super.key});

  Color _resolveHexColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      }
    } catch (_) {}
    return Color(int.parse('FF64748B', radix: 16));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final settings = ref.watch(settingsProvider);
    final analyticsData = ref.watch(analyticsProvider);
    final selectedFilter = ref.watch(selectedMonthFilterProvider);
    final availableMonths = ref.watch(availableMonthsProvider);

    final isEmpty = analyticsData.totalExpensesCents == 0 ||
        analyticsData.categoryBreakdown.isEmpty;
    final topCategory = analyticsData.topCategory;
    final hasTopCategory = topCategory != null && !isEmpty;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Integrated Header: Title + Subtitle on Left, Period Dropdown on Right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SPENDING ANALYTICS',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasTopCategory
                              ? 'Top Category: ${topCategory.category} (${topCategory.percentage.toStringAsFixed(0)}%)'
                              : 'No expenses recorded',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.bgCard,
                      border: Border.all(color: colors.borderColor, width: 1),
                      borderRadius: BorderRadius.zero,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        key: const Key('analytics_month_filter_dropdown'),
                        value: selectedFilter,
                        dropdownColor: colors.bgCard,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: 'ALL',
                            child: Text(
                              'All Time',
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          ...availableMonths.map((month) {
                            return DropdownMenuItem<String>(
                              value: month,
                              child: Text(
                                DateUtilsExt.formatMonthYear(month),
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  color: colors.textPrimary,
                                ),
                              ),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(selectedMonthFilterProvider.notifier).state = val;
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Total Expenses Card with MoM Badge
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.bgCard,
                  border: Border.all(color: colors.borderColor, width: 1),
                  borderRadius: BorderRadius.zero,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL EXPENSES TRACKED',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: colors.textSecondary,
                          ),
                        ),
                        _buildMomBadge(analyticsData, selectedFilter, colors),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.formatFromCents(
                        analyticsData.totalExpensesCents,
                        settings.currencySymbol,
                        privacyMode: settings.privacyMode,
                      ),
                      key: const Key('total_expenses_text'),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: colors.bgCard,
                    border: Border.all(color: colors.borderColor, width: 1),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Center(
                    child: Text(
                      'No expenses recorded for this period.',
                      key: const Key('analytics_empty_state_text'),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                )
              else ...[
                // Custom Donut Chart
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.bgCard,
                    border: Border.all(color: colors.borderColor, width: 1),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Category Distribution',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(200, 200),
                              painter: _DonutChartPainter(
                                items: analyticsData.categoryBreakdown,
                                strokeWidth: 24,
                                resolveColor: _resolveHexColor,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  settings.privacyMode
                                      ? '*** %'
                                      : '${analyticsData.topCategory?.percentage.toStringAsFixed(0) ?? "0"}%',
                                  key: const Key('top_category_percentage_text'),
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  (analyticsData.topCategory?.category ?? 'None').toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Sorted Category Breakdown List
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.bgCard,
                    border: Border.all(color: colors.borderColor, width: 1),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category Breakdown',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: analyticsData.categoryBreakdown.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = analyticsData.categoryBreakdown[index];
                          final catColor = _resolveHexColor(item.colorHex);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    color: catColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.category.toUpperCase(),
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.formatFromCents(
                                      item.amountCents,
                                      settings.currencySymbol,
                                      privacyMode: settings.privacyMode,
                                    ),
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontFamily,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    settings.privacyMode
                                        ? '(*** %)'
                                        : '(${item.percentage.toStringAsFixed(0)}%)',
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontFamily,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              // Horizontal Progress Bar
                              Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: colors.bgSecondary,
                                  borderRadius: BorderRadius.zero,
                                ),
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: (item.percentage / 100.0).clamp(0.0, 1.0),
                                  child: Container(
                                    color: catColor,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMomBadge(
    AnalyticsData data,
    String selectedFilter,
    AppColors colors,
  ) {
    if (selectedFilter == 'ALL' || !data.momComparison.hasPreviousData) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.bgSecondary,
          border: Border.all(color: colors.borderColor, width: 1),
          borderRadius: BorderRadius.zero,
        ),
        child: Text(
          'No prev data',
          key: const Key('mom_badge_text'),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 11,
            color: colors.textMuted,
          ),
        ),
      );
    }

    final change = data.momComparison.percentageChange;
    final isIncrease = change > 0;
    final isDecrease = change < 0;

    final badgeColor = isIncrease
        ? colors.colorDanger
        : isDecrease
            ? colors.colorSuccess
            : colors.textSecondary;

    final badgeText = isIncrease
        ? '▲ ${change.toStringAsFixed(1)}%'
        : isDecrease
            ? '▼ ${change.abs().toStringAsFixed(1)}%'
            : '0.0%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        border: Border.all(color: badgeColor, width: 1),
        borderRadius: BorderRadius.zero,
      ),
      child: Text(
        badgeText,
        key: const Key('mom_badge_text'),
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: badgeColor,
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<CategoryBreakdownItem> items;
  final double strokeWidth;
  final Color Function(String hex) resolveColor;

  const _DonutChartPainter({
    required this.items,
    required this.strokeWidth,
    required this.resolveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;

    double startAngle = -pi / 2;

    for (final item in items) {
      final sweepAngle = (item.percentage / 100.0) * 2 * pi;
      if (sweepAngle <= 0) continue;

      final paint = Paint()
        ..color = resolveColor(item.colorHex)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.square;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.items != items || oldDelegate.strokeWidth != strokeWidth;
  }
}

