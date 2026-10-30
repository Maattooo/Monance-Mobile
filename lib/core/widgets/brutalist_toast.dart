import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum BrutalistToastType {
  info,
  success,
  warning,
  danger,
}

class BrutalistToast {
  BrutalistToast._();

  static void show(
    BuildContext context,
    String message, {
    BrutalistToastType type = BrutalistToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final colors = AppTheme.colors(context);
    final accentColor = switch (type) {
      BrutalistToastType.success => colors.colorSuccess,
      BrutalistToastType.danger => colors.colorDanger,
      BrutalistToastType.warning => colors.colorWarning,
      BrutalistToastType.info => colors.colorInfo,
    };

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: colors.bgCard,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: accentColor,
            width: 1,
          ),
        ),
        content: Row(
          children: [
            Container(
              width: 4,
              height: 20,
              color: accentColor,
              margin: const EdgeInsets.only(right: 12),
            ),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void info(BuildContext context, String message) =>
      show(context, message, type: BrutalistToastType.info);

  static void success(BuildContext context, String message) =>
      show(context, message, type: BrutalistToastType.success);

  static void warning(BuildContext context, String message) =>
      show(context, message, type: BrutalistToastType.warning);

  static void danger(BuildContext context, String message) =>
      show(context, message, type: BrutalistToastType.danger);

  static void error(BuildContext context, String message) =>
      show(context, message, type: BrutalistToastType.danger);
}

