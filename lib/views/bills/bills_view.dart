import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/brutalist_confirm_dialog.dart';
import '../../providers/bills_provider.dart';
import '../../providers/settings_provider.dart';

class BillsView extends ConsumerWidget {
  final DateTime Function()? clock;
  final DateTime? now;

  const BillsView({
    super.key,
    this.clock,
    this.now,
  });

  Color _getStatusColor(String status, AppColors colors) {
    if (status == 'Paid') {
      return colors.colorSuccess;
    } else if (status.startsWith('Overdue')) {
      return colors.colorDanger;
    } else if (status.startsWith('Due Today')) {
      return colors.colorWarning;
    } else if (status.startsWith('Due in')) {
      return colors.colorInfo;
    }
    return colors.textSecondary;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentNow = now ?? (clock != null ? clock!() : DateTime.now());
    final colors = context.appColors;
    final settings = ref.watch(settingsProvider);
    final bills = ref.watch(billsProvider);

    final unpaidBills = bills.where((b) => !b.isPaid).toList();
    final totalCents = bills.fold(0, (sum, b) => sum + b.amount);
    final remainingCents = unpaidBills.fold(0, (sum, b) => sum + b.amount);

    final headerText = (bills.isNotEmpty && unpaidBills.isEmpty)
        ? 'All bills paid!'
        : '${unpaidBills.length} unpaid · ${CurrencyFormatter.formatFromCents(remainingCents, settings.currencySymbol, settings.privacyMode)}';

    final sortedBills = [...bills]..sort((a, b) => a.dueDay.compareTo(b.dueDay));

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monthly Bills',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            headerText,
                            key: const Key('bills_header_summary_text'),
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: unpaidBills.isEmpty && bills.isNotEmpty
                                  ? colors.colorSuccess
                                  : colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      key: const Key('reset_bills_button'),
                      onPressed: () async {
                        final confirmed = await BrutalistConfirmDialog.show(
                          context: context,
                          title: 'Reset Bills',
                          message: 'Reset all bills to unpaid for this month?',
                          confirmText: 'Reset Bills',
                        );
                        if (confirmed) {
                          await ref.read(billsProvider.notifier).resetAllBills();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.borderColor, width: 1),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text(
                        'Reset Bills',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 2-Column Summary Grid: Total Bills and Remaining
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
                            'Total Bills',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.formatFromCents(
                              totalCents,
                              settings.currencySymbol,
                              privacyMode: settings.privacyMode,
                            ),
                            key: const Key('total_bills_summary_text'),
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 18,
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
                            'Remaining',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.formatFromCents(
                              remainingCents,
                              settings.currencySymbol,
                              privacyMode: settings.privacyMode,
                            ),
                            key: const Key('remaining_bills_summary_text'),
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: remainingCents > 0
                                  ? colors.colorWarning
                                  : colors.colorSuccess,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Recurring Monthly Bills List (Sorted by dueDay ascending)
              if (sortedBills.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: colors.bgCard,
                    border: Border.all(color: colors.borderColor, width: 1),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Center(
                    child: Text(
                      'No recurring bills configured.\nAdd monthly bills in Settings.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedBills.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final bill = sortedBills[index];
                    final statusText = BillsNotifier.getBillStatus(bill, currentNow);
                    final statusColor = _getStatusColor(statusText, colors);

                    return Container(
                      key: Key('bill_row_${bill.id}'),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: colors.bgCard,
                        border: Border.all(color: colors.borderColor, width: 1),
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Row(
                        children: [
                          // Square Checkbox
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              key: Key('bill_checkbox_${bill.id}'),
                              value: bill.isPaid,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              onChanged: (val) {
                                ref.read(billsProvider.notifier).toggleBillPaid(bill.id);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bill.title,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    decoration:
                                        bill.isPaid ? TextDecoration.lineThrough : null,
                                    color: bill.isPaid
                                        ? colors.textMuted
                                        : colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  statusText,
                                  key: Key('bill_status_${bill.id}'),
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatFromCents(
                              bill.amount,
                              settings.currencySymbol,
                              privacyMode: settings.privacyMode,
                            ),
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: bill.isPaid
                                  ? colors.textMuted
                                  : colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
