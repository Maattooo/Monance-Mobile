import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monance_mobile/core/theme/app_theme.dart';
import 'package:monance_mobile/core/utils/currency_formatter.dart';
import 'package:monance_mobile/core/utils/date_utils_ext.dart';
import 'package:monance_mobile/core/widgets/brutalist_confirm_dialog.dart';
import 'package:monance_mobile/core/widgets/brutalist_toast.dart';

void main() {
  group('1. Theme & 0px Radius Verification (AppTheme)', () {
    test('Zero occurrences of BorderRadius.circular in app_theme.dart', () {
      final file = File('lib/core/theme/app_theme.dart');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content.contains('BorderRadius.circular'), isFalse,
          reason: 'app_theme.dart must not contain any BorderRadius.circular');
    });

    test('Dark theme and Light theme configure SpaceGrotesk font family', () {
      expect(AppTheme.darkTheme.fontFamily, equals('SpaceGrotesk'));
      expect(AppTheme.lightTheme.fontFamily, equals('SpaceGrotesk'));
    });

    test('Dark theme exact hex values for background and card surfaces', () {
      expect(AppTheme.darkTheme.scaffoldBackgroundColor,
          equals(const Color(0xFF111111)));
      expect(AppTheme.darkTheme.cardColor, equals(const Color(0xFF1A1A1A)));
    });

    test('Light theme exact hex values for background and card surfaces', () {
      expect(AppTheme.lightTheme.scaffoldBackgroundColor,
          equals(const Color(0xFFF5F5F5)));
      expect(AppTheme.lightTheme.cardColor, equals(const Color(0xFFFFFFFF)));
    });

    test('All 14 color tokens defined correctly for Dark palette', () {
      const dark = AppColors.dark;
      expect(dark.bgPrimary, equals(const Color(0xFF111111)));
      expect(dark.bgSecondary, equals(const Color(0xFF1C1C1C)));
      expect(dark.bgCard, equals(const Color(0xFF1A1A1A)));
      expect(dark.bgCardHover, equals(const Color(0xFF242424)));
      expect(dark.borderColor, equals(const Color(0xFF333333)));
      expect(dark.borderFocus, equals(const Color(0xFF888888)));
      expect(dark.borderStrong, equals(const Color(0xFF555555)));
      expect(dark.textPrimary, equals(const Color(0xFFF2F2F2)));
      expect(dark.textSecondary, equals(const Color(0xFFA0A0A0)));
      expect(dark.textMuted, equals(const Color(0xFF6B6B6B)));
      expect(dark.colorSuccess, equals(const Color(0xFF10B981)));
      expect(dark.colorDanger, equals(const Color(0xFFEF4444)));
      expect(dark.colorWarning, equals(const Color(0xFFF59E0B)));
      expect(dark.colorInfo, equals(const Color(0xFF3B82F6)));
    });

    test('All 14 color tokens defined correctly for Light palette', () {
      const light = AppColors.light;
      expect(light.bgPrimary, equals(const Color(0xFFF5F5F5)));
      expect(light.bgSecondary, equals(const Color(0xFFE9E9E9)));
      expect(light.bgCard, equals(const Color(0xFFFFFFFF)));
      expect(light.bgCardHover, equals(const Color(0xFFF0F0F0)));
      expect(light.borderColor, equals(const Color(0xFFD0D0D0)));
      expect(light.borderFocus, equals(const Color(0xFF555555)));
      expect(light.borderStrong, equals(const Color(0xFF999999)));
      expect(light.textPrimary, equals(const Color(0xFF141414)));
      expect(light.textSecondary, equals(const Color(0xFF404040)));
      expect(light.textMuted, equals(const Color(0xFF6B6B6B)));
      expect(light.colorSuccess, equals(const Color(0xFF059669)));
      expect(light.colorDanger, equals(const Color(0xFFDC2626)));
      expect(light.colorWarning, equals(const Color(0xFFD97706)));
      expect(light.colorInfo, equals(const Color(0xFF2563EB)));
    });

    test('Strict 0px radius across all Dark theme components', () {
      final theme = AppTheme.darkTheme;

      // Card
      final cardShape = theme.cardTheme.shape as RoundedRectangleBorder;
      expect(cardShape.borderRadius, equals(BorderRadius.zero));

      // Dialog
      final dialogShape = theme.dialogTheme.shape as RoundedRectangleBorder;
      expect(dialogShape.borderRadius, equals(BorderRadius.zero));

      // BottomSheet
      final bottomSheetShape =
          theme.bottomSheetTheme.shape as RoundedRectangleBorder;
      expect(bottomSheetShape.borderRadius, equals(BorderRadius.zero));

      // SnackBar
      final snackBarShape = theme.snackBarTheme.shape as RoundedRectangleBorder;
      expect(snackBarShape.borderRadius, equals(BorderRadius.zero));

      // Checkbox
      final checkboxShape = theme.checkboxTheme.shape as RoundedRectangleBorder;
      expect(checkboxShape.borderRadius, equals(BorderRadius.zero));

      // InputDecoration borders
      final inputBorder =
          theme.inputDecorationTheme.border as OutlineInputBorder;
      expect(inputBorder.borderRadius, equals(BorderRadius.zero));

      final inputEnabledBorder =
          theme.inputDecorationTheme.enabledBorder as OutlineInputBorder;
      expect(inputEnabledBorder.borderRadius, equals(BorderRadius.zero));

      final inputFocusedBorder =
          theme.inputDecorationTheme.focusedBorder as OutlineInputBorder;
      expect(inputFocusedBorder.borderRadius, equals(BorderRadius.zero));
    });

    test('Strict 0px radius across all Light theme components', () {
      final theme = AppTheme.lightTheme;

      // Card
      final cardShape = theme.cardTheme.shape as RoundedRectangleBorder;
      expect(cardShape.borderRadius, equals(BorderRadius.zero));

      // Dialog
      final dialogShape = theme.dialogTheme.shape as RoundedRectangleBorder;
      expect(dialogShape.borderRadius, equals(BorderRadius.zero));

      // BottomSheet
      final bottomSheetShape =
          theme.bottomSheetTheme.shape as RoundedRectangleBorder;
      expect(bottomSheetShape.borderRadius, equals(BorderRadius.zero));

      // SnackBar
      final snackBarShape = theme.snackBarTheme.shape as RoundedRectangleBorder;
      expect(snackBarShape.borderRadius, equals(BorderRadius.zero));

      // Checkbox
      final checkboxShape = theme.checkboxTheme.shape as RoundedRectangleBorder;
      expect(checkboxShape.borderRadius, equals(BorderRadius.zero));

      // InputDecoration borders
      final inputBorder =
          theme.inputDecorationTheme.border as OutlineInputBorder;
      expect(inputBorder.borderRadius, equals(BorderRadius.zero));

      final inputEnabledBorder =
          theme.inputDecorationTheme.enabledBorder as OutlineInputBorder;
      expect(inputEnabledBorder.borderRadius, equals(BorderRadius.zero));

      final inputFocusedBorder =
          theme.inputDecorationTheme.focusedBorder as OutlineInputBorder;
      expect(inputFocusedBorder.borderRadius, equals(BorderRadius.zero));
    });
  });

  group('2. Privacy Mode Masking & Date Helpers Verification', () {
    test('CurrencyFormatter.formatFromCents with privacyMode false & true', () {
      expect(
        CurrencyFormatter.formatFromCents(125050, '₱', privacyMode: false),
        equals('₱1,250.50'),
      );
      expect(
        CurrencyFormatter.formatFromCents(125050, '₱', privacyMode: true),
        equals('₱ ***.**'),
      );
      expect(
        CurrencyFormatter.formatFromCents(125050, '\$', privacyMode: true),
        equals('\$ ***.**'),
      );
    });

    test('CurrencyFormatter.formatPercent with privacyMode false & true', () {
      expect(
        CurrencyFormatter.formatPercent(75.4, privacyMode: false),
        equals('75.4%'),
      );
      expect(
        CurrencyFormatter.formatPercent(75.4, privacyMode: true),
        equals('*** %'),
      );
    });

    test('CurrencyFormatter.maskIfPrivate with privacyMode true & false', () {
      expect(
        CurrencyFormatter.maskIfPrivate('12 allowance days', privacyMode: true),
        equals('***'),
      );
      expect(
        CurrencyFormatter.maskIfPrivate('12 allowance days', privacyMode: false),
        equals('12 allowance days'),
      );
    });

    test('CurrencyFormatter existing methods work unchanged', () {
      expect(CurrencyFormatter.pesosToCents(50.25), equals(5025));
      expect(CurrencyFormatter.centsToPesos(5025), equals(50.25));
      expect(CurrencyFormatter.formatFromCents(125050), equals('₱1,250.50'));
      expect(CurrencyFormatter.formatMaskedCurrency('₱'), equals('₱ ***.**'));
    });

    test('DateUtilsExt.formatMonthYear formats YYYY-MM and ALL correctly', () {
      expect(DateUtilsExt.formatMonthYear('2026-10'), equals('October 2026'));
      expect(DateUtilsExt.formatMonthYear('ALL'), equals('All Time'));
      expect(DateUtilsExt.formatMonthYear('all'), equals('All Time'));
    });

    test('DateUtilsExt.formatDisplayDate formats YYYY-MM-DD correctly', () {
      expect(
        DateUtilsExt.formatDisplayDate('2026-10-30'),
        equals('Oct 30, 2026'),
      );
    });

    test('DateUtilsExt existing methods preserved', () {
      expect(DateUtilsExt.isLeapYear(2024), isTrue);
      expect(DateUtilsExt.isLeapYear(2026), isFalse);
      expect(DateUtilsExt.daysInMonth(2026, 2), equals(28));
      expect(DateUtilsExt.daysInMonth(2024, 2), equals(29));
      expect(DateUtilsExt.tomorrowIsoDate('2026-10-31'), equals('2026-11-01'));
    });
  });

  group('3. Widget Tests for BrutalistConfirmDialog & BrutalistToast', () {
    testWidgets(
        'BrutalistConfirmDialog renders title, message, and handles cancel/confirm',
        (WidgetTester tester) async {
      bool? dialogResult;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  dialogResult = await BrutalistConfirmDialog.show(
                    context: context,
                    title: 'Delete Expense',
                    message: 'Are you sure you want to delete this expense?',
                    confirmText: 'Delete',
                    cancelText: 'Cancel',
                    isDanger: true,
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open Dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify title and message are rendered
      expect(find.text('Delete Expense'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this expense?'),
          findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(dialogResult, isFalse);

      // Reopen Dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Tap Confirm ('Delete')
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(dialogResult, isTrue);
    });

    testWidgets('BrutalistToast renders message with 0px border radius SnackBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  BrutalistToast.show(
                    context,
                    'Settings saved successfully',
                    type: BrutalistToastType.success,
                  );
                },
                child: const Text('Show Toast'),
              ),
            ),
          ),
        ),
      );

      // Trigger Toast
      await tester.tap(find.text('Show Toast'));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 750)); // Advance animation

      // Verify SnackBar renders message text
      expect(find.text('Settings saved successfully'), findsOneWidget);

      // Verify SnackBar has a RoundedRectangleBorder with 0px radius
      final snackBarFinder = find.byType(SnackBar);
      expect(snackBarFinder, findsOneWidget);

      final SnackBar snackBar = tester.widget<SnackBar>(snackBarFinder);
      expect(snackBar.shape, isA<RoundedRectangleBorder>());
      final shape = snackBar.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, equals(BorderRadius.zero));
    });
  });
}

