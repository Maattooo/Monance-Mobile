import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/brutalist_confirm_dialog.dart';
import '../../models/goal_history_model.dart';
import '../../providers/settings_provider.dart';

class GoalHistoryModal extends ConsumerStatefulWidget {
  const GoalHistoryModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      builder: (ctx) => const GoalHistoryModal(),
    );
  }

  @override
  ConsumerState<GoalHistoryModal> createState() => _GoalHistoryModalState();
}

class _GoalHistoryModalState extends ConsumerState<GoalHistoryModal> {
  Future<void> _handleUndoRecent() async {
    final confirmed = await BrutalistConfirmDialog.show(
      context: context,
      title: 'Undo Recent Goal',
      message: 'Restore the most recent archived goal and revert balance?',
      confirmText: 'Undo',
      isDanger: true,
    );

    if (confirmed && mounted) {
      await ref.read(settingsProvider.notifier).undoRecentGoal();
      ref.invalidate(goalHistoryProvider);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _showEditDialog(GoalHistoryModel item) async {
    final settings = ref.read(settingsProvider);
    final amountController = TextEditingController(
      text: CurrencyFormatter.centsToPesos(item.amount).toStringAsFixed(2),
    );
    final savedController = TextEditingController(
      text: CurrencyFormatter.centsToPesos(item.saved).toStringAsFixed(2),
    );
    final startDateController = TextEditingController(text: item.startDate ?? '');
    final endDateController = TextEditingController(text: item.endDate);

    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final colors = ctx.appColors;
        return Dialog(
          backgroundColor: colors.bgCard,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Edit Historical Goal',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Goal Target (${settings.currencySymbol})',
                      fillColor: colors.bgSecondary,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: savedController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Saved Amount (${settings.currencySymbol})',
                      fillColor: colors.bgSecondary,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: startDateController,
                    decoration: InputDecoration(
                      labelText: 'Start Date (YYYY-MM-DD)',
                      fillColor: colors.bgSecondary,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: endDateController,
                    decoration: InputDecoration(
                      labelText: 'End Date (YYYY-MM-DD)',
                      fillColor: colors.bgSecondary,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: OutlinedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.textPrimary,
                          foregroundColor: colors.bgPrimary,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (updated == true && mounted) {
      final parsedAmount = double.tryParse(amountController.text.trim());
      final parsedSaved = double.tryParse(savedController.text.trim());
      final startStr = startDateController.text.trim();
      final endStr = endDateController.text.trim();

      await ref.read(settingsProvider.notifier).editGoalHistory(
            item.id,
            amount: parsedAmount != null ? CurrencyFormatter.pesosToCents(parsedAmount) : null,
            saved: parsedSaved != null ? CurrencyFormatter.pesosToCents(parsedSaved) : null,
            startDate: startStr.isNotEmpty ? startStr : null,
            endDate: endStr.isNotEmpty ? endStr : null,
          );
      ref.invalidate(goalHistoryProvider);
    }

    amountController.dispose();
    savedController.dispose();
    startDateController.dispose();
    endDateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final settings = ref.watch(settingsProvider);
    final historyAsync = ref.watch(goalHistoryProvider);

    return Container(
      color: colors.bgCard,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Past Savings Goals',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            historyAsync.when(
              data: (historyList) {
                return Column(
                  children: [
                    if (historyList.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          key: const Key('undo_most_recent_goal_button'),
                          onPressed: _handleUndoRecent,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colors.colorWarning, width: 1),
                            foregroundColor: colors.colorWarning,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          icon: const Icon(Icons.undo, size: 16),
                          label: const Text(
                            'Undo Most Recent',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: historyAsync.when(
                data: (historyList) {
                  if (historyList.isEmpty) {
                    return Center(
                      child: Text(
                        'No past goals recorded.',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: colors.textSecondary,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: historyList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = historyList[index];
                      final amountStr = CurrencyFormatter.formatFromCents(
                        item.amount,
                        settings.currencySymbol,
                        privacyMode: settings.privacyMode,
                      );
                      final savedStr = CurrencyFormatter.formatFromCents(
                        item.saved,
                        settings.currencySymbol,
                        privacyMode: settings.privacyMode,
                      );

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.bgSecondary,
                          border: Border.all(color: colors.borderColor, width: 1),
                          borderRadius: BorderRadius.zero,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Target: $amountStr',
                                        style: TextStyle(
                                          fontFamily: AppTheme.fontFamily,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '• Saved: $savedStr',
                                        style: TextStyle(
                                          fontFamily: AppTheme.fontFamily,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: colors.colorSuccess,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.startDate ?? "No start"} → ${item.endDate}',
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontFamily,
                                      fontSize: 12,
                                      color: colors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              key: Key('edit_goal_history_${item.id}'),
                              icon: Icon(Icons.edit_outlined, size: 18, color: colors.textSecondary),
                              onPressed: () => _showEditDialog(item),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    'Error: $e',
                    style: TextStyle(color: colors.colorDanger),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
