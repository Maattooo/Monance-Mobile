import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_utils_ext.dart';
import '../../core/widgets/brutalist_confirm_dialog.dart';
import '../../providers/goal_calculation_provider.dart';
import '../../providers/records_provider.dart';
import '../../providers/settings_provider.dart';
import 'add_money_modal.dart';
import 'goal_history_modal.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GoalWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class GoalWidget extends ConsumerWidget {
  const GoalWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final settings = ref.watch(settingsProvider);
    final derivedWalletBalance = ref.watch(derivedWalletBalanceProvider);
    final metrics = ref.watch(goalCalculationProvider);
    final goalHistoryAsync = ref.watch(goalHistoryProvider);
    final historyCount = goalHistoryAsync.value?.length ?? 0;

    final isArchiveReady = metrics.displayRemaining <= 0 && metrics.displayGoal > 0;
    final isNoGoal = settings.goalAmount == 0;
    final todayIso = DateUtilsExt.formatIsoDate(DateTime.now());
    final isFutureGoal = settings.goalStartDate != null &&
        settings.goalStartDate!.compareTo(todayIso) > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Goal Progress Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.bgCard,
            border: Border.all(color: colors.borderColor, width: 1),
            borderRadius: BorderRadius.zero,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Goal Progress',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        settings.goalStartDate != null
                            ? (isFutureGoal
                                ? 'Starts ${DateUtilsExt.formatDisplayDate(settings.goalStartDate!)}'
                                : 'Started ${DateUtilsExt.formatDisplayDate(settings.goalStartDate!)}')
                            : 'No start date',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (isNoGoal)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: colors.bgSecondary,
                        border: Border.all(color: colors.borderColor, width: 1),
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Text(
                        'No Goal Set',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colors.textSecondary,
                        ),
                      ),
                    )
                  else if (isArchiveReady)
                    ElevatedButton(
                      key: const Key('complete_and_archive_button'),
                      onPressed: () async {
                        final confirmed = await BrutalistConfirmDialog.show(
                          context: context,
                          title: 'Complete & Archive Goal',
                          message:
                              'Congratulations on reaching your goal! Archive it now and add saved funds to your wallet?',
                          confirmText: 'Archive',
                        );
                        if (confirmed) {
                          await ref.read(settingsProvider.notifier).archiveGoal(
                                todayIsoDate: DateUtilsExt.formatIsoDate(DateTime.now()),
                                totalSavingsCents: metrics.totalSavings,
                              );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.colorSuccess,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: const Text(
                        'Complete & Archive',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else if (isFutureGoal)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: colors.bgSecondary,
                        border: Border.all(color: colors.colorWarning, width: 1),
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Text(
                        'Scheduled',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colors.colorWarning,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: colors.bgSecondary,
                        border: Border.all(color: colors.colorSuccess, width: 1),
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Text(
                        'Tracking Active',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colors.colorSuccess,
                        ),
                      ),
                    ),
                ],
              ),
              if (isFutureGoal) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.bgSecondary,
                    border: Border.all(color: colors.colorWarning, width: 1),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, size: 16, color: colors.colorWarning),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Goal is scheduled to start on ${DateUtilsExt.formatDisplayDate(settings.goalStartDate!)}. Daily records prior to this date are excluded from your goal.',
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 12,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            key: const Key('count_all_days_button'),
                            onPressed: () async {
                              await ref
                                  .read(settingsProvider.notifier)
                                  .updateGoalStartDate(null);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: colors.borderColor),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: Text(
                              'COUNT ALL DAYS',
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            key: const Key('start_goal_today_button'),
                            onPressed: () async {
                              await ref
                                  .read(settingsProvider.notifier)
                                  .updateGoalStartDate(todayIso);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentEmerald,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: const Text(
                              'START TODAY',
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Current Wallet Balance Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.bgCard,
            border: Border.all(color: colors.borderColor, width: 1),
            borderRadius: BorderRadius.zero,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Wallet Balance',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatFromCents(
                      derivedWalletBalance,
                      settings.currencySymbol,
                      privacyMode: settings.privacyMode,
                    ),
                    key: const Key('wallet_balance_text'),
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                key: const Key('add_money_button'),
                onPressed: () => AddMoneyModal.show(context),
                style: OutlinedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  side: BorderSide(color: colors.borderColor, width: 1),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  foregroundColor: colors.textPrimary,
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  '+ Add',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 3. Savings Goal & Total Saved Row
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.bgCard,
                  border: Border.all(color: colors.borderColor, width: 1),
                  borderRadius: BorderRadius.zero,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Savings Goal',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatCurrency(
                        metrics.displayGoal,
                        settings.currencySymbol,
                        settings.privacyMode,
                      ),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.bgCard,
                  border: Border.all(color: colors.borderColor, width: 1),
                  borderRadius: BorderRadius.zero,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Saved',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatCurrency(
                        metrics.displaySavings,
                        settings.currencySymbol,
                        settings.privacyMode,
                      ),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.colorSuccess,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 4. Semi-Circle Progress Gauge
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: colors.bgCard,
            border: Border.all(color: colors.borderColor, width: 1),
            borderRadius: BorderRadius.zero,
          ),
          child: Column(
            children: [
              CustomPaint(
                size: const Size(220, 110),
                painter: _ProgressArcPainter(
                  progressPercent: metrics.progressPercent,
                  trackColor: colors.bgSecondary,
                  progressColor: isArchiveReady ? colors.colorSuccess : colors.textPrimary,
                  strokeWidth: 14,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                settings.privacyMode
                    ? '*** %'
                    : '${metrics.progressPercent.toStringAsFixed(1)}% Completed',
                key: const Key('progress_percent_text'),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${CurrencyFormatter.formatCurrency(metrics.displayRemaining, settings.currencySymbol, settings.privacyMode)} to go',
                key: const Key('display_remaining_text'),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 5. 3-Column Stats Grid
        Row(
          children: [
            Expanded(
              child: Container(
                height: 90,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.bgCard,
                  border: Border.all(color: colors.borderColor, width: 1),
                  borderRadius: BorderRadius.zero,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Avg. Daily Savings',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.formatCurrency(
                        metrics.averageDailySavings,
                        settings.currencySymbol,
                        settings.privacyMode,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 90,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.bgCard,
                  border: Border.all(color: colors.borderColor, width: 1),
                  borderRadius: BorderRadius.zero,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Est. Days Remaining',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.maskIfPrivate(
                        metrics.estimatedDaysText,
                        privacyMode: settings.privacyMode,
                      ),
                      key: const Key('est_days_remaining_text'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 90,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.bgCard,
                  border: Border.all(color: colors.borderColor, width: 1),
                  borderRadius: BorderRadius.zero,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Burn Rate (Pacing)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            CurrencyFormatter.formatPercent(
                              metrics.burnRatePercent,
                              privacyMode: settings.privacyMode,
                            ),
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            CurrencyFormatter.maskIfPrivate(
                              metrics.pacingStatus,
                              privacyMode: settings.privacyMode,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _getPacingColor(metrics.pacingStatus, colors),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 6. Smart Budget Tip Card
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
                children: [
                  Icon(Icons.lightbulb_outline, size: 16, color: colors.colorWarning),
                  const SizedBox(width: 8),
                  Text(
                    'Smart Budget Tip',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                metrics.smartBudgetTip,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  color: colors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 7. View Past Goals Button
        OutlinedButton(
          key: const Key('view_past_goals_button'),
          onPressed: () => GoalHistoryModal.show(context),
          style: OutlinedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            side: BorderSide(color: colors.borderColor, width: 1),
            padding: const EdgeInsets.symmetric(vertical: 14),
            foregroundColor: colors.textPrimary,
          ),
          child: Text(
            'View Past Goals ($historyCount)',
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Color _getPacingColor(String status, AppColors colors) {
    switch (status) {
      case 'Overspending':
        return colors.colorDanger;
      case 'High Burn':
        return colors.colorWarning;
      case 'On Track':
        return colors.colorSuccess;
      default:
        return colors.textMuted;
    }
  }
}

class _ProgressArcPainter extends CustomPainter {
  final double progressPercent;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  const _ProgressArcPainter({
    required this.progressPercent,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - strokeWidth;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    // Draw background 180° arc (from pi to 2*pi)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      trackPaint,
    );

    // Draw progress arc
    final sweepAngle = (progressPercent.clamp(0.0, 100.0) / 100.0) * pi;
    if (sweepAngle > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        pi,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressArcPainter oldDelegate) {
    return oldDelegate.progressPercent != progressPercent ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
