import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color bgPrimary;
  final Color bgSecondary;
  final Color bgCard;
  final Color bgCardHover;
  final Color borderColor;
  final Color borderFocus;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color colorSuccess;
  final Color colorDanger;
  final Color colorWarning;
  final Color colorInfo;

  const AppColors({
    required this.bgPrimary,
    required this.bgSecondary,
    required this.bgCard,
    required this.bgCardHover,
    required this.borderColor,
    required this.borderFocus,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.colorSuccess,
    required this.colorDanger,
    required this.colorWarning,
    required this.colorInfo,
  });

  static const dark = AppColors(
    bgPrimary: Color(0xFF111111),
    bgSecondary: Color(0xFF1C1C1C),
    bgCard: Color(0xFF1A1A1A),
    bgCardHover: Color(0xFF242424),
    borderColor: Color(0xFF333333),
    borderFocus: Color(0xFF888888),
    borderStrong: Color(0xFF555555),
    textPrimary: Color(0xFFF2F2F2),
    textSecondary: Color(0xFFA0A0A0),
    textMuted: Color(0xFF6B6B6B),
    colorSuccess: Color(0xFF10B981),
    colorDanger: Color(0xFFEF4444),
    colorWarning: Color(0xFFF59E0B),
    colorInfo: Color(0xFF3B82F6),
  );

  static const light = AppColors(
    bgPrimary: Color(0xFFF5F5F5),
    bgSecondary: Color(0xFFE9E9E9),
    bgCard: Color(0xFFFFFFFF),
    bgCardHover: Color(0xFFF0F0F0),
    borderColor: Color(0xFFD0D0D0),
    borderFocus: Color(0xFF555555),
    borderStrong: Color(0xFF999999),
    textPrimary: Color(0xFF141414),
    textSecondary: Color(0xFF404040),
    textMuted: Color(0xFF6B6B6B),
    colorSuccess: Color(0xFF059669),
    colorDanger: Color(0xFFDC2626),
    colorWarning: Color(0xFFD97706),
    colorInfo: Color(0xFF2563EB),
  );

  @override
  AppColors copyWith({
    Color? bgPrimary,
    Color? bgSecondary,
    Color? bgCard,
    Color? bgCardHover,
    Color? borderColor,
    Color? borderFocus,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? colorSuccess,
    Color? colorDanger,
    Color? colorWarning,
    Color? colorInfo,
  }) {
    return AppColors(
      bgPrimary: bgPrimary ?? this.bgPrimary,
      bgSecondary: bgSecondary ?? this.bgSecondary,
      bgCard: bgCard ?? this.bgCard,
      bgCardHover: bgCardHover ?? this.bgCardHover,
      borderColor: borderColor ?? this.borderColor,
      borderFocus: borderFocus ?? this.borderFocus,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      colorSuccess: colorSuccess ?? this.colorSuccess,
      colorDanger: colorDanger ?? this.colorDanger,
      colorWarning: colorWarning ?? this.colorWarning,
      colorInfo: colorInfo ?? this.colorInfo,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bgPrimary: Color.lerp(bgPrimary, other.bgPrimary, t)!,
      bgSecondary: Color.lerp(bgSecondary, other.bgSecondary, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      bgCardHover: Color.lerp(bgCardHover, other.bgCardHover, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      colorSuccess: Color.lerp(colorSuccess, other.colorSuccess, t)!,
      colorDanger: Color.lerp(colorDanger, other.colorDanger, t)!,
      colorWarning: Color.lerp(colorWarning, other.colorWarning, t)!,
      colorInfo: Color.lerp(colorInfo, other.colorInfo, t)!,
    );
  }
}

class AppTheme {
  static const String fontFamily = 'SpaceGrotesk';

  // Dark Palette Tokens
  static const Color darkBgPrimary = Color(0xFF111111);
  static const Color darkBgSecondary = Color(0xFF1C1C1C);
  static const Color darkBgCard = Color(0xFF1A1A1A);
  static const Color darkBgCardHover = Color(0xFF242424);
  static const Color darkBorderColor = Color(0xFF333333);
  static const Color darkBorderFocus = Color(0xFF888888);
  static const Color darkBorderStrong = Color(0xFF555555);
  static const Color darkTextPrimary = Color(0xFFF2F2F2);
  static const Color darkTextSecondary = Color(0xFFA0A0A0);
  static const Color darkTextMuted = Color(0xFF6B6B6B);
  static const Color darkColorSuccess = Color(0xFF10B981);
  static const Color darkColorDanger = Color(0xFFEF4444);
  static const Color darkColorWarning = Color(0xFFF59E0B);
  static const Color darkColorInfo = Color(0xFF3B82F6);

  // Light Palette Tokens
  static const Color lightBgPrimary = Color(0xFFF5F5F5);
  static const Color lightBgSecondary = Color(0xFFE9E9E9);
  static const Color lightBgCard = Color(0xFFFFFFFF);
  static const Color lightBgCardHover = Color(0xFFF0F0F0);
  static const Color lightBorderColor = Color(0xFFD0D0D0);
  static const Color lightBorderFocus = Color(0xFF555555);
  static const Color lightBorderStrong = Color(0xFF999999);
  static const Color lightTextPrimary = Color(0xFF141414);
  static const Color lightTextSecondary = Color(0xFF404040);
  static const Color lightTextMuted = Color(0xFF6B6B6B);
  static const Color lightColorSuccess = Color(0xFF059669);
  static const Color lightColorDanger = Color(0xFFDC2626);
  static const Color lightColorWarning = Color(0xFFD97706);
  static const Color lightColorInfo = Color(0xFF2563EB);

  // Backward-compatibility aliases
  static const Color darkBg = darkBgPrimary;
  static const Color darkCard = darkBgCard;
  static const Color darkBorder = darkBorderColor;
  static const Color darkAccent = Color(0xFFFFFFFF);
  static const Color lightBg = lightBgPrimary;
  static const Color lightCard = lightBgCard;
  static const Color lightBorder = lightBorderColor;
  static const Color lightAccent = Color(0xFF141414);
  static const Color greenAccent = darkColorSuccess;
  static const Color redAccent = darkColorDanger;
  static const Color blueAccent = darkColorInfo;

  static const AppColors darkColors = AppColors.dark;
  static const AppColors lightColors = AppColors.light;

  static AppColors colors(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppColors>();
    if (ext != null) return ext;
    return theme.brightness == Brightness.dark ? darkColors : lightColors;
  }

  static AppColors colorsOf(bool isDark) {
    return isDark ? darkColors : lightColors;
  }

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: darkBgPrimary,
    cardColor: darkBgCard,
    textTheme: const TextTheme().apply(
      fontFamily: fontFamily,
      bodyColor: darkTextPrimary,
      displayColor: darkTextPrimary,
    ),
    colorScheme: const ColorScheme.dark(
      surface: darkBgCard,
      primary: darkTextPrimary,
      onPrimary: darkBgPrimary,
      onSurface: darkTextPrimary,
      outline: darkBorderColor,
      error: darkColorDanger,
    ),
    extensions: const [darkColors],
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBgPrimary,
      foregroundColor: darkTextPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: darkTextPrimary,
      ),
    ),
    cardTheme: const CardThemeData(
      color: darkBgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: darkBorderColor, width: 1),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: darkBgSecondary,
      hintStyle: TextStyle(
        fontFamily: fontFamily,
        color: darkTextMuted,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: darkBorderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: darkBorderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: darkBorderFocus, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: darkColorDanger, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: darkColorDanger, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkTextPrimary,
        foregroundColor: darkBgPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkTextPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        side: const BorderSide(color: darkBorderStrong, width: 1),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: darkBgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: darkBorderColor, width: 1),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: darkBgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: darkBgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: darkBorderColor, width: 1),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      side: const BorderSide(color: darkBorderColor, width: 1),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return darkTextPrimary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(darkBgPrimary),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: lightBgPrimary,
    cardColor: lightBgCard,
    textTheme: const TextTheme().apply(
      fontFamily: fontFamily,
      bodyColor: lightTextPrimary,
      displayColor: lightTextPrimary,
    ),
    colorScheme: const ColorScheme.light(
      surface: lightBgCard,
      primary: lightTextPrimary,
      onPrimary: lightBgPrimary,
      onSurface: lightTextPrimary,
      outline: lightBorderColor,
      error: lightColorDanger,
    ),
    extensions: const [lightColors],
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBgPrimary,
      foregroundColor: lightTextPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: lightTextPrimary,
      ),
    ),
    cardTheme: const CardThemeData(
      color: lightBgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: lightBorderColor, width: 1),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: lightBgSecondary,
      hintStyle: TextStyle(
        fontFamily: fontFamily,
        color: lightTextMuted,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: lightBorderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: lightBorderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: lightBorderFocus, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: lightColorDanger, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: lightColorDanger, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightTextPrimary,
        foregroundColor: lightBgPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lightTextPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        side: const BorderSide(color: lightBorderStrong, width: 1),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: lightBgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: lightBorderColor, width: 1),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: lightBgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: lightBgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: lightBorderColor, width: 1),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      side: const BorderSide(color: lightBorderColor, width: 1),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return lightTextPrimary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(lightBgPrimary),
    ),
  );
}

extension ThemeDataFontExtension on ThemeData {
  String? get fontFamily =>
      textTheme.bodyMedium?.fontFamily ??
      textTheme.titleMedium?.fontFamily ??
      AppTheme.fontFamily;
}

extension AppThemeContextExtension on BuildContext {
  AppColors get appColors => AppTheme.colors(this);
}
