import 'package:intl/intl.dart';

String formatCurrency(num amount, [String symbol = '₱']) {
  return CurrencyFormatter.formatCurrency(amount, symbol);
}

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

  /// Converts amount (in main currency unit, e.g. Pesos) to formatted string: ₱1,250.50
  static String formatCurrency(num amount, [String symbol = '₱']) {
    if (symbol == '₱') {
      return _pesoFormat.format(amount);
    }
    final format = NumberFormat.currency(
      locale: 'en_PH',
      symbol: symbol,
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  /// Converts centavos (integer) to formatted string: ₱1,250.50
  static String formatFromCents(int centavos, [String symbol = '₱']) {
    final pesos = centavos / 100.0;
    return formatCurrency(pesos, symbol);
  }

  /// Converts centavos (integer) to compact formatted string: ₱1,250
  static String formatCompactFromCents(int centavos, [String symbol = '₱']) {
    final pesos = centavos / 100.0;
    if (pesos == 0) return '${symbol}0';
    if (symbol == '₱') {
      return _compactFormat.format(pesos);
    }
    final format = NumberFormat.currency(
      locale: 'en_PH',
      symbol: symbol,
      decimalDigits: 0,
    );
    return format.format(pesos);
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
