import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/brutalist_confirm_dialog.dart';
import '../../core/widgets/brutalist_toast.dart';
import '../../providers/bills_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/security_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/backup_restore_service.dart';

class SettingsPanelView extends ConsumerStatefulWidget {
  const SettingsPanelView({super.key});

  @override
  ConsumerState<SettingsPanelView> createState() => _SettingsPanelViewState();
}

class _SettingsPanelViewState extends ConsumerState<SettingsPanelView> {
  // Accordion 1 Controllers
  final TextEditingController _goalAmountController = TextEditingController();
  final TextEditingController _walletBalanceController = TextEditingController();
  final TextEditingController _allowanceController = TextEditingController();

  // Accordion 2 Controllers (Bills)
  final TextEditingController _billTitleController = TextEditingController();
  final TextEditingController _billAmountController = TextEditingController();
  final TextEditingController _billDueDayController = TextEditingController();

  // Accordion 3 Controllers (Categories)
  final TextEditingController _categoryNameController = TextEditingController();
  String _selectedCategoryColorHex = '#3B82F6';

  // Accordion 4 Controllers (Security PIN)
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _pinConfirmController = TextEditingController();

  final List<String> _presetCategoryColors = [
    '#EAB308',
    '#3B82F6',
    '#6366F1',
    '#EF4444',
    '#A855F7',
    '#06B6D4',
    '#10B981',
    '#F97316',
    '#64748B',
  ];

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _syncSettingsControllers(settings);
  }

  void _syncSettingsControllers(dynamic settings) {
    _goalAmountController.text =
        CurrencyFormatter.centsToPesos(settings.goalAmount).toStringAsFixed(2);
    _walletBalanceController.text =
        CurrencyFormatter.centsToPesos(settings.currentBalance).toStringAsFixed(2);
    _allowanceController.text =
        CurrencyFormatter.centsToPesos(settings.defaultAllowance).toStringAsFixed(2);
  }

  @override
  void dispose() {
    _goalAmountController.dispose();
    _walletBalanceController.dispose();
    _allowanceController.dispose();
    _billTitleController.dispose();
    _billAmountController.dispose();
    _billDueDayController.dispose();
    _categoryNameController.dispose();
    _pinController.dispose();
    _pinConfirmController.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final settings = ref.watch(settingsProvider);
    final bills = ref.watch(billsProvider);
    final securityState = ref.watch(securityProvider);
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Accordion 1 — Goal & Wallet Settings
              _buildAccordionItem(
                title: 'Goal & Wallet Settings',
                colors: colors,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Target Savings Goal (${settings.currencySymbol})',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      key: const Key('settings_goal_amount_input'),
                      controller: _goalAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        isDense: true,
                        fillColor: colors.bgSecondary,
                        filled: true,
                      ),
                      onSubmitted: (val) {
                        final parsed = double.tryParse(val.trim());
                        if (parsed != null && parsed >= 0) {
                          ref
                              .read(settingsProvider.notifier)
                              .updateGoalAmount(CurrencyFormatter.pesosToCents(parsed));
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Goal Start Date',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            settings.goalStartDate ?? 'None set',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        OutlinedButton(
                          key: const Key('set_goal_start_date_button'),
                          onPressed: () async {
                            final now = DateTime.now();
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: now,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                            );
                            if (picked != null) {
                              final iso =
                                  '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                              await ref
                                  .read(settingsProvider.notifier)
                                  .updateGoalStartDate(iso);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: const Text('Pick Date'),
                        ),
                        if (settings.goalStartDate != null) ...[
                          const SizedBox(width: 6),
                          IconButton(
                            icon: Icon(Icons.clear, size: 18, color: colors.colorDanger),
                            onPressed: () {
                              ref.read(settingsProvider.notifier).updateGoalStartDate(null);
                            },
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Current Wallet Balance (${settings.currencySymbol})',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      key: const Key('settings_wallet_balance_input'),
                      controller: _walletBalanceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        isDense: true,
                        fillColor: colors.bgSecondary,
                        filled: true,
                      ),
                      onSubmitted: (val) {
                        final parsed = double.tryParse(val.trim());
                        if (parsed != null && parsed >= 0) {
                          ref
                              .read(settingsProvider.notifier)
                              .updateCurrentBalance(CurrencyFormatter.pesosToCents(parsed));
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Default Daily Allowance (${settings.currencySymbol})',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      key: const Key('settings_allowance_input'),
                      controller: _allowanceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        isDense: true,
                        fillColor: colors.bgSecondary,
                        filled: true,
                      ),
                      onSubmitted: (val) {
                        final parsed = double.tryParse(val.trim());
                        if (parsed != null && parsed >= 0) {
                          ref
                              .read(settingsProvider.notifier)
                              .updateAllowance(CurrencyFormatter.pesosToCents(parsed));
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Currency',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      key: const Key('settings_currency_dropdown'),
                      initialValue: '${settings.currencyCode} ${settings.currencySymbol}',
                      dropdownColor: colors.bgCard,
                      decoration: InputDecoration(
                        isDense: true,
                        fillColor: colors.bgSecondary,
                        filled: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'PHP ₱', child: Text('PHP ₱')),
                        DropdownMenuItem(value: 'USD \$', child: Text('USD \$')),
                        DropdownMenuItem(value: 'EUR €', child: Text('EUR €')),
                        DropdownMenuItem(value: 'GBP £', child: Text('GBP £')),
                        DropdownMenuItem(value: 'JPY ¥', child: Text('JPY ¥')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          final parts = val.split(' ');
                          if (parts.length >= 2) {
                            ref
                                .read(settingsProvider.notifier)
                                .updateCurrency(parts[0], parts[1]);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Accordion 2 — Manage Monthly Bills
              _buildAccordionItem(
                title: 'Manage Monthly Bills',
                colors: colors,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Notification toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bill Reminder Notifications',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 13,
                            color: colors.textPrimary,
                          ),
                        ),
                        Switch(
                          key: const Key('bill_notifications_toggle'),
                          value: settings.billNotificationsEnabled,
                          onChanged: (val) {
                            ref
                                .read(settingsProvider.notifier)
                                .toggleBillNotifications(val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Current Bills (${bills.length})',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...bills.map((bill) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${bill.title} — ${CurrencyFormatter.formatFromCents(bill.amount, settings.currencySymbol)} (Day ${bill.dueDay})',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 13,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            IconButton(
                              key: Key('delete_bill_${bill.id}'),
                              icon: Icon(Icons.delete_outline, size: 16, color: colors.colorDanger),
                              onPressed: () {
                                ref.read(billsProvider.notifier).deleteBill(bill.id);
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    Text(
                      'Add Recurring Bill',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      key: const Key('add_bill_title_input'),
                      controller: _billTitleController,
                      maxLength: 40,
                      decoration: InputDecoration(
                        hintText: 'Bill Title (max 40 chars)',
                        counterText: '',
                        isDense: true,
                        fillColor: colors.bgSecondary,
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            key: const Key('add_bill_amount_input'),
                            controller: _billAmountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: 'Amount',
                              isDense: true,
                              fillColor: colors.bgSecondary,
                              filled: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            key: const Key('add_bill_due_day_input'),
                            controller: _billDueDayController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Due Day (1–31)',
                              isDense: true,
                              fillColor: colors.bgSecondary,
                              filled: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      key: const Key('add_bill_submit_button'),
                      onPressed: () async {
                        final title = _billTitleController.text.trim();
                        final parsedAmount = double.tryParse(_billAmountController.text.trim());
                        final parsedDay = int.tryParse(_billDueDayController.text.trim());

                        if (title.isEmpty || title.length > 40) {
                          BrutalistToast.error(context, 'Title must be 1–40 characters');
                          return;
                        }
                        if (parsedAmount == null || parsedAmount <= 0) {
                          BrutalistToast.error(context, 'Amount must be greater than zero');
                          return;
                        }
                        if (parsedDay == null || parsedDay < 1 || parsedDay > 31) {
                          BrutalistToast.error(context, 'Due day must be between 1 and 31');
                          return;
                        }

                        await ref.read(billsProvider.notifier).addBill(
                              title: title,
                              amount: CurrencyFormatter.pesosToCents(parsedAmount),
                              dueDay: parsedDay,
                            );

                        _billTitleController.clear();
                        _billAmountController.clear();
                        _billDueDayController.clear();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.textPrimary,
                        foregroundColor: colors.bgPrimary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: const Text('Add Bill'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Accordion 3 — Manage Expense Categories
              _buildAccordionItem(
                title: 'Manage Expense Categories',
                colors: colors,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Categories (${settings.categories.length}/25)',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...settings.categories.map((cat) {
                      final catColor = _resolveHexColor(cat.colorHex);
                      final canDelete = settings.categories.length > 1;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              color: catColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                cat.name,
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 13,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            IconButton(
                              key: Key('delete_category_${cat.name}'),
                              icon: Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: canDelete ? colors.colorDanger : colors.textMuted,
                              ),
                              onPressed: canDelete
                                  ? () async {
                                      await ref
                                          .read(settingsProvider.notifier)
                                          .deleteCategory(cat.name);
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    Text(
                      'Add Custom Category',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      key: const Key('new_category_name_input'),
                      controller: _categoryNameController,
                      decoration: InputDecoration(
                        hintText: 'Category Name (max 30 chars)',
                        isDense: true,
                        fillColor: colors.bgSecondary,
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Color Presets
                    Wrap(
                      spacing: 6,
                      children: _presetCategoryColors.map((hex) {
                        final isSelected = _selectedCategoryColorHex == hex;
                        final c = _resolveHexColor(hex);
                        return InkWell(
                          onTap: () => setState(() => _selectedCategoryColorHex = hex),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: c,
                              border: Border.all(
                                color: isSelected ? colors.textPrimary : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      key: const Key('add_category_button'),
                      onPressed: () async {
                        final name = _categoryNameController.text.trim();
                        if (name.isEmpty) {
                          BrutalistToast.error(context, 'Category name cannot be empty');
                          return;
                        }
                        if (name.length > 30) {
                          BrutalistToast.error(
                              context, 'Category name must be 1–30 characters');
                          return;
                        }
                        if (settings.categories.length >= 25) {
                          BrutalistToast.error(
                              context, 'Maximum of 25 categories reached');
                          return;
                        }
                        if (settings.categories
                            .any((c) => c.name.toLowerCase() == name.toLowerCase())) {
                          BrutalistToast.error(context, 'Category already exists');
                          return;
                        }

                        final success = await ref
                            .read(settingsProvider.notifier)
                            .addCategory(name, _selectedCategoryColorHex);
                        if (success) {
                          _categoryNameController.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.textPrimary,
                        foregroundColor: colors.bgPrimary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: const Text('Add Category'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Accordion 4 — Security & Offline Backup
              _buildAccordionItem(
                title: 'Security & Offline Backup',
                colors: colors,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'PIN & Biometrics',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!securityState.isPinEnabled) ...[
                      Text(
                        'Set 4–6 Digit Local PIN',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        key: const Key('setup_pin_input'),
                        controller: _pinController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 6,
                        decoration: InputDecoration(
                          hintText: 'Enter 4–6 digit PIN',
                          counterText: '',
                          isDense: true,
                          fillColor: colors.bgSecondary,
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        key: const Key('setup_pin_confirm_input'),
                        controller: _pinConfirmController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 6,
                        decoration: InputDecoration(
                          hintText: 'Confirm PIN',
                          counterText: '',
                          isDense: true,
                          fillColor: colors.bgSecondary,
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        key: const Key('enable_pin_button'),
                        onPressed: () async {
                          final pin = _pinController.text.trim();
                          final confirm = _pinConfirmController.text.trim();

                          if (pin.length < 4 || pin.length > 6) {
                            BrutalistToast.error(
                                context, 'PIN must be 4–6 digits');
                            return;
                          }
                          if (pin != confirm) {
                            BrutalistToast.error(context, 'PINs do not match');
                            return;
                          }

                          final success = await ref
                              .read(securityProvider.notifier)
                              .setupPin(pin);
                          if (!context.mounted) return;
                          if (success) {
                            _pinController.clear();
                            _pinConfirmController.clear();
                            BrutalistToast.success(
                                context, 'PIN enabled successfully');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.textPrimary,
                          foregroundColor: colors.bgPrimary,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: const Text('Enable PIN'),
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Local PIN Lock is ACTIVE',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colors.colorSuccess,
                            ),
                          ),
                          OutlinedButton(
                            key: const Key('disable_pin_button'),
                            onPressed: () async {
                              final confirmed = await BrutalistConfirmDialog.show(
                                context: context,
                                title: 'Disable PIN',
                                message:
                                    'Are you sure you want to disable PIN lock protection?',
                                confirmText: 'Disable PIN',
                                isDanger: true,
                              );
                              if (confirmed) {
                                await ref
                                    .read(securityProvider.notifier)
                                    .disablePin();
                                if (context.mounted) {
                                  BrutalistToast.info(context, 'PIN disabled');
                                }
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: colors.colorDanger, width: 1),
                              foregroundColor: colors.colorDanger,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: const Text('Disable PIN'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Biometric Unlock',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 13,
                              color: colors.textPrimary,
                            ),
                          ),
                          Switch(
                            key: const Key('biometrics_toggle'),
                            value: securityState.isBiometricsEnabled,
                            onChanged: (val) {
                              ref
                                  .read(securityProvider.notifier)
                                  .toggleBiometrics(val);
                            },
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Offline JSON Backup & Restore',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            key: const Key('export_backup_button'),
                            onPressed: () async {
                              try {
                                final success =
                                    await BackupRestoreService.exportBackupToFile(db);
                                if (!context.mounted) return;
                                if (success) {
                                  BrutalistToast.success(
                                      context, 'Backup exported successfully');
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  BrutalistToast.error(
                                      context, 'Export failed: $e');
                                }
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: colors.borderColor, width: 1),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Export Backup (JSON)'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            key: const Key('restore_backup_button'),
                            onPressed: () async {
                              final confirmed = await BrutalistConfirmDialog.show(
                                context: context,
                                title: 'Restore Backup',
                                message:
                                    'Restoring will replace all current data. This action cannot be undone.',
                                confirmText: 'Restore',
                                isDanger: true,
                              );

                              if (!confirmed) return;
                              if (!context.mounted) return;

                              try {
                                final success =
                                    await BackupRestoreService.restoreBackupFromFilePicker(db);
                                if (!context.mounted) return;
                                if (success) {
                                  await BackupRestoreService.refreshProviders(ref);
                                  if (context.mounted) {
                                    BrutalistToast.success(
                                        context, 'Backup restored successfully');
                                  }
                                } else {
                                  if (context.mounted) {
                                    BrutalistToast.error(
                                        context, 'Restore cancelled or failed');
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  BrutalistToast.error(
                                      context, 'Restore failed: $e');
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.colorDanger,
                              foregroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Restore Backup (JSON)'),
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
      ),
    );
  }

  Widget _buildAccordionItem({
    required String title,
    required Widget child,
    required AppColors colors,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.bgCard,
        border: Border.all(color: colors.borderColor, width: 1),
        borderRadius: BorderRadius.zero,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          collapsedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [child],
        ),
      ),
    );
  }
}
