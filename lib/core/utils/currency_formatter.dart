import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _pesoFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  static final NumberFormat _compactFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 0,
  );

  /// Converts centavos (integer) to formatted PHP string: ₱1,250.50
  static String formatFromCents(int centavos) {
    final pesos = centavos / 100.0;
    return _pesoFormat.format(pesos);
  }

  /// Converts centavos (integer) to compact formatted PHP string: ₱1,250
  static String formatCompactFromCents(int centavos) {
    final pesos = centavos / 100.0;
    if (pesos == 0) return '₱0';
    return _compactFormat.format(pesos);
  }

  /// Converts double pesos to centavos integer (e.g., 50.25 -> 5025)
  static int pesosToCents(double pesos) {
    return (pesos * 100).round();
  }

  /// Converts centavos integer to double pesos (e.g., 5025 -> 50.25)
  static double centsToPesos(int cents) {
    return cents / 100.0;
  }
}
