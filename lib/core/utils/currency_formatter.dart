import 'package:intl/intl.dart';

String formatCurrency(
  num amount, [
  dynamic symbolOrPrivacy = '₱',
  bool? privacyMode,
]) {
  String symbol = '₱';
  bool privacy = false;
  if (symbolOrPrivacy is String) {
    symbol = symbolOrPrivacy;
  } else if (symbolOrPrivacy is bool) {
    privacy = symbolOrPrivacy;
  }
  if (privacyMode != null) {
    privacy = privacyMode;
  }
  return CurrencyFormatter.formatCurrency(amount, symbol, privacyMode: privacy);
}

class _FormatCurrency {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #call) {
      final pos = invocation.positionalArguments;
      final named = invocation.namedArguments;
      final amount = pos[0] as num;
      String symbol = '₱';
      bool privacyMode = false;

      if (pos.length > 1) {
        if (pos[1] is String) {
          symbol = pos[1] as String;
        } else if (pos[1] is bool) {
          privacyMode = pos[1] as bool;
        }
      }
      if (pos.length > 2 && pos[2] is bool) {
        privacyMode = pos[2] as bool;
      }

      if (named.containsKey(#symbol)) {
        symbol = named[#symbol] as String;
      }
      if (named.containsKey(#privacyMode)) {
        privacyMode = named[#privacyMode] as bool;
      }

      if (privacyMode) {
        return CurrencyFormatter.formatMaskedCurrency(symbol);
      }
      return CurrencyFormatter._rawFormatCurrency(amount, symbol);
    }
    return super.noSuchMethod(invocation);
  }
}

class _FormatFromCents {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #call) {
      final pos = invocation.positionalArguments;
      final named = invocation.namedArguments;
      final centavos = pos[0] as int;
      String symbol = '₱';
      bool privacyMode = false;

      if (pos.length > 1) {
        if (pos[1] is String) {
          symbol = pos[1] as String;
        } else if (pos[1] is bool) {
          privacyMode = pos[1] as bool;
        }
      }
      if (pos.length > 2 && pos[2] is bool) {
        privacyMode = pos[2] as bool;
      }

      if (named.containsKey(#symbol)) {
        symbol = named[#symbol] as String;
      }
      if (named.containsKey(#privacyMode)) {
        privacyMode = named[#privacyMode] as bool;
      }

      if (privacyMode) {
        return CurrencyFormatter.formatMaskedCurrency(symbol);
      }
      final pesos = centavos / 100.0;
      return CurrencyFormatter.formatCurrency(pesos, symbol);
    }
    return super.noSuchMethod(invocation);
  }
}

class _FormatCompactFromCents {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #call) {
      final pos = invocation.positionalArguments;
      final named = invocation.namedArguments;
      final centavos = pos[0] as int;
      String symbol = '₱';
      bool privacyMode = false;

      if (pos.length > 1) {
        if (pos[1] is String) {
          symbol = pos[1] as String;
        } else if (pos[1] is bool) {
          privacyMode = pos[1] as bool;
        }
      }
      if (pos.length > 2 && pos[2] is bool) {
        privacyMode = pos[2] as bool;
      }

      if (named.containsKey(#symbol)) {
        symbol = named[#symbol] as String;
      }
      if (named.containsKey(#privacyMode)) {
        privacyMode = named[#privacyMode] as bool;
      }

      if (privacyMode) {
        return '$symbol ***';
      }
      return CurrencyFormatter._rawFormatCompactFromCents(centavos, symbol);
    }
    return super.noSuchMethod(invocation);
  }
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

  /// Converts amount to formatted string: ₱1,250.50 or masked: ₱ ***.**
  static final dynamic formatCurrency = _FormatCurrency();

  /// Converts centavos (integer) to formatted string: ₱1,250.50 or masked: ₱ ***.**
  static final dynamic formatFromCents = _FormatFromCents();

  /// Converts centavos (integer) to compact formatted string: ₱1,250 or masked: ₱ ***
  static final dynamic formatCompactFromCents = _FormatCompactFromCents();

  /// Formats a masked monetary string: $symbol ***.**
  static String formatMaskedCurrency([String symbol = '₱']) {
    return '$symbol ***.**';
  }

  /// Formats percentage: 75.4% or masked: *** %
  static String formatPercent(
    num value, {
    bool privacyMode = false,
    int decimals = 1,
  }) {
    if (privacyMode) {
      return '*** %';
    }
    return '${value.toStringAsFixed(decimals)}%';
  }

  /// Returns '***' if privacyMode is true, otherwise returns the original text.
  static String maskIfPrivate(String text, {bool privacyMode = false}) {
    if (privacyMode) {
      return '***';
    }
    return text;
  }

  static String _rawFormatCurrency(num amount, [String symbol = '₱']) {
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

  static String _rawFormatCompactFromCents(int centavos, [String symbol = '₱']) {
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
