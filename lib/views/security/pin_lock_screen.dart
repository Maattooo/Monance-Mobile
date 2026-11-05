import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/security_provider.dart';

class PinLockScreen extends ConsumerStatefulWidget {
  const PinLockScreen({super.key});

  @override
  ConsumerState<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends ConsumerState<PinLockScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify(String pin) async {
    if (pin.length < 4 || pin.length > 6) {
      setState(() {
        _errorMessage = 'PIN must be 4–6 digits';
      });
      return;
    }

    final success = await ref.read(securityProvider.notifier).verifyPin(pin);
    if (!mounted) return;

    if (!success) {
      setState(() {
        _errorMessage = 'Incorrect PIN';
      });
      _pinController.clear();
    } else {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final securityState = ref.watch(securityProvider);

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: colors.textPrimary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Monance Locked',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your 4–6 digit PIN to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 14,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    key: const Key('pin_input_field'),
                    controller: _pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    autofocus: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 26,
                      letterSpacing: 8,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: '••••',
                      counterText: '',
                      fillColor: colors.bgSecondary,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: colors.borderColor, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: colors.borderFocus, width: 1.5),
                      ),
                    ),
                    onSubmitted: _handleVerify,
                    onChanged: (_) {
                      if (_errorMessage != null) {
                        setState(() => _errorMessage = null);
                      }
                    },
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      key: const Key('pin_error_text'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.colorDanger,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    key: const Key('pin_unlock_button'),
                    onPressed: () => _handleVerify(_pinController.text),
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: colors.textPrimary,
                      foregroundColor: colors.bgPrimary,
                    ),
                    child: const Text(
                      'Unlock',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (securityState.isBiometricsEnabled) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      key: const Key('biometric_unlock_button'),
                      onPressed: () => ref
                          .read(securityProvider.notifier)
                          .authenticateWithBiometrics(),
                      style: OutlinedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        side: BorderSide(color: colors.borderColor, width: 1),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: colors.textPrimary,
                      ),
                      icon: const Icon(Icons.fingerprint),
                      label: const Text(
                        'Biometric Unlock',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

