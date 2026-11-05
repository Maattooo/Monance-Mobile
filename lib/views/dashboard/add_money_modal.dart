import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/settings_provider.dart';

class AddMoneyModal extends ConsumerStatefulWidget {
  const AddMoneyModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      builder: (ctx) => const AddMoneyModal(),
    );
  }

  @override
  ConsumerState<AddMoneyModal> createState() => _AddMoneyModalState();
}

class _AddMoneyModalState extends ConsumerState<AddMoneyModal> {
  final TextEditingController _amountController = TextEditingController();
  String _mode = 'add'; // 'add' or 'set'
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? _parseAmount() {
    final text = _amountController.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  String? _validate(double? parsed) {
    if (parsed == null) {
      return 'Enter a valid numeric amount.';
    }
    if (parsed <= 0) {
      return 'Amount must be greater than zero.';
    }
    if (parsed > 9999999) {
      return 'Amount exceeds the maximum allowed value.';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    final parsed = _parseAmount();
    final error = _validate(parsed);
    if (error != null) {
      setState(() {
        _errorMessage = error;
      });
      return;
    }

    final enteredCents = CurrencyFormatter.pesosToCents(parsed!);
    final settings = ref.read(settingsProvider);
    final int newBalanceCents = _mode == 'add'
        ? settings.currentBalance + enteredCents
        : enteredCents;

    await ref
        .read(settingsProvider.notifier)
        .updateCurrentBalance(newBalanceCents);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final settings = ref.watch(settingsProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final parsed = _parseAmount();
    final bool hasValidAmount = parsed != null && parsed > 0 && parsed <= 9999999;
    final int enteredCents = hasValidAmount
        ? CurrencyFormatter.pesosToCents(parsed)
        : 0;
    final int previewCents = _mode == 'add'
        ? settings.currentBalance + enteredCents
        : (hasValidAmount ? enteredCents : settings.currentBalance);

    return Container(
      color: colors.bgCard,
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Manage Wallet Balance',
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
              const SizedBox(height: 16),
              // Mode Segmented Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('mode_add_button'),
                      onPressed: () {
                        setState(() {
                          _mode = 'add';
                          _errorMessage = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            _mode == 'add' ? colors.textPrimary : Colors.transparent,
                        foregroundColor:
                            _mode == 'add' ? colors.bgPrimary : colors.textPrimary,
                        side: BorderSide(
                          color: _mode == 'add'
                              ? colors.textPrimary
                              : colors.borderColor,
                          width: 1,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Add Money',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('mode_set_button'),
                      onPressed: () {
                        setState(() {
                          _mode = 'set';
                          _errorMessage = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            _mode == 'set' ? colors.textPrimary : Colors.transparent,
                        foregroundColor:
                            _mode == 'set' ? colors.bgPrimary : colors.textPrimary,
                        side: BorderSide(
                          color: _mode == 'set'
                              ? colors.textPrimary
                              : colors.borderColor,
                          width: 1,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Set Balance',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Amount (${settings.currencySymbol})',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                key: const Key('add_money_amount_input'),
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
                decoration: InputDecoration(
                  prefixText: '${settings.currencySymbol} ',
                  prefixStyle: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                  hintText: '0.00',
                  fillColor: colors.bgSecondary,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: colors.borderColor, width: 1),
                  ),
                ),
                onChanged: (_) {
                  setState(() {
                    _errorMessage = null;
                  });
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  key: const Key('add_money_error_text'),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.colorDanger,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              // Live Preview Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.bgSecondary,
                  border: Border.all(color: colors.borderColor, width: 1),
                  borderRadius: BorderRadius.zero,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Balance Preview:',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatFromCents(
                        previewCents,
                        settings.currencySymbol,
                      ),
                      key: const Key('new_balance_preview'),
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
              const SizedBox(height: 24),
              ElevatedButton(
                key: const Key('add_money_submit_button'),
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.textPrimary,
                  foregroundColor: colors.bgPrimary,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  _mode == 'add' ? 'Add to Balance' : 'Set Balance',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

