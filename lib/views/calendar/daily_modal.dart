import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_utils_ext.dart';
import '../../core/widgets/brutalist_confirm_dialog.dart';
import '../../models/daily_record_model.dart';
import '../../models/expense_model.dart';
import '../../providers/records_provider.dart';
import '../../providers/settings_provider.dart';

class DailyModal extends ConsumerStatefulWidget {
  final String date; // YYYY-MM-DD

  const DailyModal({
    super.key,
    required this.date,
  });

  static Future<void> show(BuildContext context, String date) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      builder: (ctx) => DailyModal(date: date),
    );
  }

  @override
  ConsumerState<DailyModal> createState() => _DailyModalState();
}

class _DailyModalState extends ConsumerState<DailyModal> {
  int _activeTab = 0; // 0: Ledger, 1: Add/Edit Expense
  bool _showSpent = false; // Toggle between remaining and total spent

  // Ledger Controllers
  late TextEditingController _dayLabelController;
  late TextEditingController _startingMoneyController;

  // Add/Edit Expense Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _deductFrom = 'allowance'; // 'allowance' | 'balance'
  String _selectedCategory = 'Other';
  ExpenseModel? _editingExpense;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _dayLabelController = TextEditingController();
    _startingMoneyController = TextEditingController();
  }

  @override
  void dispose() {
    _dayLabelController.dispose();
    _startingMoneyController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _syncControllersWithRecord(DailyRecordModel record) {
    if (_dayLabelController.text != record.title) {
      _dayLabelController.text = record.title;
    }
    final moneyStr = CurrencyFormatter.centsToPesos(record.startingMoney).toStringAsFixed(2);
    if (_startingMoneyController.text != moneyStr) {
      _startingMoneyController.text = moneyStr;
    }
  }

  Color _resolveCategoryColor(String catName, BuildContext context) {
    final settings = ref.read(settingsProvider);
    final cat = settings.categories.where((c) => c.name == catName).firstOrNull;
    if (cat != null) {
      try {
        final clean = cat.colorHex.replaceAll('#', '');
        if (clean.length == 6) {
          return Color(int.parse('FF$clean', radix: 16));
        }
      } catch (_) {}
    }
    return Color(int.parse('FF64748B', radix: 16));
  }

  void _startEditExpense(ExpenseModel expense) {
    setState(() {
      _editingExpense = expense;
      _titleController.text = expense.title;
      _amountController.text = CurrencyFormatter.centsToPesos(expense.amount).toStringAsFixed(2);
      _deductFrom = expense.deductFrom == 'balance' ? 'balance' : 'allowance';
      _selectedCategory = expense.category;
      _formError = null;
      _activeTab = 1;
    });
  }

  void _resetExpenseForm() {
    setState(() {
      _editingExpense = null;
      _titleController.clear();
      _amountController.clear();
      _deductFrom = 'allowance';
      _selectedCategory = 'Other';
      _formError = null;
    });
  }

  Future<void> _handleSaveExpense() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || title.length > 100) {
      setState(() => _formError = 'Title must be 1–100 characters.');
      return;
    }

    final parsedAmount = double.tryParse(_amountController.text.trim());
    if (parsedAmount == null || parsedAmount <= 0) {
      setState(() => _formError = 'Enter a valid amount greater than zero.');
      return;
    }

    final cents = CurrencyFormatter.pesosToCents(parsedAmount);

    if (_editingExpense != null) {
      await ref.read(recordsProvider.notifier).updateExpense(
            date: widget.date,
            expense: _editingExpense!.copyWith(
              title: title,
              amount: cents,
              category: _selectedCategory,
              deductFrom: _deductFrom,
            ),
          );
    } else {
      await ref.read(recordsProvider.notifier).addExpense(
            date: widget.date,
            amount: cents,
            title: title,
            category: _selectedCategory,
            deductFrom: _deductFrom,
          );
    }

    _resetExpenseForm();
    setState(() {
      _activeTab = 0;
    });
  }

  String _formatWeekday(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${DateFormat('EEEE').format(dt).toUpperCase()},';
    } catch (_) {
      return '';
    }
  }

  String _formatFullDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('MMMM d, y').format(dt).toUpperCase();
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final settings = ref.watch(settingsProvider);
    final recordsMap = ref.watch(recordsProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final record = recordsMap[widget.date];
    final bool isInitialized = record != null && !record.isDeleted;

    if (isInitialized) {
      _syncControllersWithRecord(record);
    }

    return Container(
      color: colors.bgCard,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row: Weekday & Date on Left; Actions on Right
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatWeekday(widget.date),
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: colors.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          _formatFullDate(widget.date),
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: colors.textPrimary,
                          ),
                        ),
                        SizedBox(
                          height: 0,
                          width: 0,
                          child: OverflowBox(
                            child: Text(
                              DateUtilsExt.formatDisplayDate(widget.date),
                              style: const TextStyle(fontSize: 0.1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isInitialized) ...[
                        OutlinedButton(
                          key: const Key('clear_day_button'),
                          onPressed: () async {
                            final confirmed = await BrutalistConfirmDialog.show(
                              context: context,
                              title: 'Clear Day',
                              message: 'Clear all records and expenses for this day?',
                              confirmText: 'Clear Day',
                              isDanger: true,
                            );
                            if (confirmed && mounted) {
                              await ref.read(recordsProvider.notifier).clearDay(widget.date);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colors.borderColor, width: 1),
                            foregroundColor: colors.colorDanger,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: const Size(60, 28),
                          ),
                          child: const Text(
                            'CLEAR DAY',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      IconButton(
                        icon: Icon(Icons.close, color: colors.textSecondary, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (isInitialized) ...[
                // Subheader Row: Remaining Badge on Left; LEDGER | ADD Tabs on Right
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRemainingBadge(record, colors, settings),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton(
                          key: const Key('tab_ledger_button'),
                          onPressed: () => setState(() => _activeTab = 0),
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                _activeTab == 0 ? colors.textPrimary : Colors.transparent,
                            foregroundColor:
                                _activeTab == 0 ? colors.bgPrimary : colors.textPrimary,
                            side: BorderSide(
                              color: colors.borderColor,
                              width: 1,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: const Size(60, 28),
                          ),
                          child: const Text(
                            'LEDGER',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        OutlinedButton(
                          key: const Key('tab_add_expense_button'),
                          onPressed: () => setState(() => _activeTab = 1),
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                _activeTab == 1 ? colors.textPrimary : Colors.transparent,
                            foregroundColor:
                                _activeTab == 1 ? colors.bgPrimary : colors.textPrimary,
                            side: BorderSide(
                              color: colors.borderColor,
                              width: 1,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: const Size(54, 28),
                          ),
                          child: Text(
                            _editingExpense != null ? 'EDIT' : 'ADD',
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: colors.borderColor, height: 1, thickness: 1),
                const SizedBox(height: 16),
              ],

              if (!isInitialized) ...[
                // Uninitialized State: Two Big Brutalist Action Cards
                Text(
                  'Choose day type to start tracking:',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  key: const Key('school_work_card'),
                  onTap: () async {
                    await ref.read(recordsProvider.notifier).setRecord(
                          DailyRecordModel(
                            date: widget.date,
                            title: 'school',
                            startingMoney: settings.defaultAllowance,
                            updatedAt: DateTime.now().millisecondsSinceEpoch,
                            isDeleted: false,
                          ),
                        );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.bgSecondary,
                      border: Border.all(color: colors.borderColor, width: 1),
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.school_outlined, size: 28, color: colors.textPrimary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'School / Work (+${CurrencyFormatter.formatFromCents(settings.defaultAllowance, settings.currencySymbol, settings.privacyMode)})',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Track daily allowance and routine expenses',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 12,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  key: const Key('rest_day_card'),
                  onTap: () async {
                    await ref.read(recordsProvider.notifier).setRecord(
                          DailyRecordModel(
                            date: widget.date,
                            title: 'rest',
                            startingMoney: 0,
                            updatedAt: DateTime.now().millisecondsSinceEpoch,
                            isDeleted: false,
                          ),
                        );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.bgSecondary,
                      border: Border.all(color: colors.borderColor, width: 1),
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.weekend_outlined, size: 28, color: colors.textPrimary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rest Day (${CurrencyFormatter.formatFromCents(0, settings.currencySymbol, settings.privacyMode)})',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Zero allowance day, all expenses deduct from wallet',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 12,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Tab Content
                if (_activeTab == 0)
                  _buildLedgerTab(record, colors, settings)
                else
                  _buildAddExpenseTab(colors, settings),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRemainingBadge(
    DailyRecordModel record,
    AppColors colors,
    dynamic settings,
  ) {
    final remaining = record.remainingAllowance;
    final totalSpent = record.totalExpenses;

    final Color badgeColor;
    final String amountText;
    final String labelText;

    if (_showSpent) {
      amountText = CurrencyFormatter.formatFromCents(
        totalSpent,
        settings.currencySymbol,
        privacyMode: settings.privacyMode,
      );
      labelText = ' spent';
      badgeColor = totalSpent > 0 ? colors.colorInfo : colors.textMuted;
    } else {
      amountText = CurrencyFormatter.formatFromCents(
        remaining,
        settings.currencySymbol,
        privacyMode: settings.privacyMode,
      );
      labelText = ' remaining';
      if (remaining < 0) {
        badgeColor = colors.colorDanger;
      } else if (record.startingMoney > 0 && remaining >= 0) {
        badgeColor = colors.colorSuccess;
      } else {
        badgeColor = colors.textMuted;
      }
    }

    return InkWell(
      key: const Key('toggle_remaining_spent_button'),
      onTap: () {
        setState(() {
          _showSpent = !_showSpent;
        });
      },
      child: Container(
        key: const Key('remaining_badge'),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.bgSecondary,
          border: Border.all(color: badgeColor, width: 1),
          borderRadius: BorderRadius.zero,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              amountText,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
            ),
            Text(
              labelText,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: badgeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLedgerTab(
    DailyRecordModel record,
    AppColors colors,
    dynamic settings,
  ) {
    final isOverspent = record.remainingAllowance < 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Editable Day Label and Starting Money Row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day Label',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    key: const Key('day_label_input'),
                    controller: _dayLabelController,
                    decoration: InputDecoration(
                      fillColor: colors.bgSecondary,
                      filled: true,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: colors.borderColor, width: 1),
                      ),
                    ),
                    onSubmitted: (val) {
                      ref.read(recordsProvider.notifier).setRecord(
                            record.copyWith(
                              title: val.trim().isNotEmpty ? val.trim() : 'school',
                            ),
                          );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Starting Money (${settings.currencySymbol})',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    key: const Key('starting_money_input'),
                    controller: _startingMoneyController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      fillColor: colors.bgSecondary,
                      filled: true,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: colors.borderColor, width: 1),
                      ),
                    ),
                    onSubmitted: (val) {
                      final parsed = double.tryParse(val.trim());
                      if (parsed != null && parsed >= 0) {
                        ref
                            .read(recordsProvider.notifier)
                            .updateStartingMoney(widget.date, CurrencyFormatter.pesosToCents(parsed));
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Overspent warning banner
        if (isOverspent) ...[
          Container(
            key: const Key('overspent_warning'),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.bgSecondary,
              border: Border.all(color: colors.colorDanger, width: 1),
              borderRadius: BorderRadius.zero,
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 16, color: colors.colorDanger),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Overspent by ${CurrencyFormatter.formatFromCents(-record.remainingAllowance, settings.currencySymbol, settings.privacyMode)}!',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.colorDanger,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Expense List
        Text(
          'Expenses (${record.expenses.length})',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        if (record.expenses.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'No expenses logged for this day.',
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
            itemCount: record.expenses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final exp = record.expenses[index];
              final catColor = _resolveCategoryColor(exp.category, context);
              final isWallet = exp.deductFrom == 'balance';

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.bgSecondary,
                  border: Border.all(color: colors.borderColor, width: 1),
                  borderRadius: BorderRadius.zero,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Row 1: Bar, Title, Amount
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          color: catColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            exp.title,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          CurrencyFormatter.formatFromCents(
                            exp.amount,
                            settings.currencySymbol,
                            privacyMode: settings.privacyMode,
                          ),
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Row 2: Category Badge, Allowance/Wallet Badge, Actions (Edit, Delete)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.bgPrimary,
                            border: Border.all(color: catColor, width: 1),
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Text(
                            exp.category,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: catColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.bgPrimary,
                            border: Border.all(color: colors.borderColor, width: 1),
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Text(
                            isWallet ? 'Wallet' : 'Allowance',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 10,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.edit_outlined, size: 16, color: colors.textSecondary),
                          onPressed: () => _startEditExpense(exp),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 14),
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 16, color: colors.colorDanger),
                          onPressed: () => ref
                              .read(recordsProvider.notifier)
                              .deleteExpense(widget.date, exp.id),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildAddExpenseTab(AppColors colors, dynamic settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Title
        Text(
          _editingExpense != null ? 'EDIT EXPENSE' : 'ADD EXPENSE',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Deduct Toggle (Allowance vs Wallet)
        Row(
          children: [
            Text(
              'DEDUCT: ',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: OutlinedButton(
                key: const Key('deduct_allowance_button'),
                onPressed: () => setState(() => _deductFrom = 'allowance'),
                style: OutlinedButton.styleFrom(
                  backgroundColor:
                      _deductFrom == 'allowance' ? colors.textPrimary : Colors.transparent,
                  foregroundColor:
                      _deductFrom == 'allowance' ? colors.bgPrimary : colors.textPrimary,
                  side: BorderSide(
                    color: _deductFrom == 'allowance'
                        ? colors.textPrimary
                        : colors.borderColor,
                    width: 1,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text(
                  'ALLOWANCE',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: OutlinedButton(
                key: const Key('deduct_wallet_button'),
                onPressed: () => setState(() => _deductFrom = 'balance'),
                style: OutlinedButton.styleFrom(
                  backgroundColor:
                      _deductFrom == 'balance' ? colors.textPrimary : Colors.transparent,
                  foregroundColor:
                      _deductFrom == 'balance' ? colors.bgPrimary : colors.textPrimary,
                  side: BorderSide(
                    color: _deductFrom == 'balance' ? colors.textPrimary : colors.borderColor,
                    width: 1,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text(
                  'WALLET',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Two-column Title and Amount row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXPENSE TITLE',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    key: const Key('expense_title_input'),
                    controller: _titleController,
                    maxLength: 100,
                    decoration: InputDecoration(
                      hintText: 'e.g. Lunch',
                      counterText: '',
                      fillColor: colors.bgSecondary,
                      filled: true,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: colors.borderColor, width: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AMOUNT',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    key: const Key('expense_amount_input'),
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      fillColor: colors.bgSecondary,
                      filled: true,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: colors.borderColor, width: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Category Pills
        Text(
          'CATEGORY',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: settings.categories.map<Widget>((cat) {
            final isSelected = _selectedCategory == cat.name;
            return InkWell(
              onTap: () => setState(() => _selectedCategory = cat.name),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? colors.textPrimary : colors.bgSecondary,
                  border: Border.all(
                    color: isSelected ? colors.textPrimary : colors.borderColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.zero,
                ),
                child: Text(
                  cat.name.toUpperCase(),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: isSelected ? colors.bgPrimary : colors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        if (_formError != null) ...[
          const SizedBox(height: 12),
          Text(
            _formError!,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.colorDanger,
            ),
          ),
        ],
        const SizedBox(height: 16),

        // Submit & Cancel Buttons
        Row(
          children: [
            if (_editingExpense != null) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _resetExpenseForm();
                    setState(() => _activeTab = 0);
                  },
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: ElevatedButton(
                key: const Key('submit_expense_button'),
                onPressed: _handleSaveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.textPrimary,
                  foregroundColor: colors.bgPrimary,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  _editingExpense != null ? 'SAVE EXPENSE' : 'ADD EXPENSE',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
