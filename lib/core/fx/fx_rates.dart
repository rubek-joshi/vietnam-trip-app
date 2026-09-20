import 'package:equatable/equatable.dart';

enum CurrencyCode { usd, npr, vnd }

class FxRates extends Equatable {
  const FxRates({required this.usdToNpr, required this.usdToVnd});

  /// 1 USD = this many NPR
  final double usdToNpr;

  /// 1 USD = this many VND
  final double usdToVnd;

  static const FxRates defaults = FxRates(usdToNpr: 153.50, usdToVnd: 25960);

  double get nprToVnd => usdToVnd / usdToNpr;

  double convert({
    required double amount,
    required CurrencyCode from,
    required CurrencyCode to,
  }) {
    if (from == to) return amount;
    final inUsd = toUsd(amount, from);
    return fromUsd(inUsd, to);
  }

  double toUsd(double amount, CurrencyCode from) {
    switch (from) {
      case CurrencyCode.usd:
        return amount;
      case CurrencyCode.npr:
        return amount / usdToNpr;
      case CurrencyCode.vnd:
        return amount / usdToVnd;
    }
  }

  double fromUsd(double usd, CurrencyCode to) {
    switch (to) {
      case CurrencyCode.usd:
        return usd;
      case CurrencyCode.npr:
        return usd * usdToNpr;
      case CurrencyCode.vnd:
        return usd * usdToVnd;
    }
  }

  double toNpr(double amount, CurrencyCode from) =>
      convert(amount: amount, from: from, to: CurrencyCode.npr);

  FxRates copyWith({double? usdToNpr, double? usdToVnd}) {
    return FxRates(
      usdToNpr: usdToNpr ?? this.usdToNpr,
      usdToVnd: usdToVnd ?? this.usdToVnd,
    );
  }

  Map<String, dynamic> toJson() => {'usdToNpr': usdToNpr, 'usdToVnd': usdToVnd};

  factory FxRates.fromJson(Map<dynamic, dynamic> json) {
    return FxRates(
      usdToNpr: (json['usdToNpr'] as num?)?.toDouble() ?? defaults.usdToNpr,
      usdToVnd: (json['usdToVnd'] as num?)?.toDouble() ?? defaults.usdToVnd,
    );
  }

  @override
  List<Object?> get props => [usdToNpr, usdToVnd];
}

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(double amount, CurrencyCode code, {int? decimals}) {
    final d = decimals ?? _defaultDecimals(code);
    return '${_symbol(code)}${_groupedNumber(amount, code, d)}';
  }

  /// Grouped digits without a currency symbol (for inputs and rate labels).
  static String grouped(double amount, CurrencyCode code, {int? decimals}) {
    final d = decimals ?? _defaultDecimals(code);
    return _groupedNumber(amount, code, d);
  }

  static int _defaultDecimals(CurrencyCode code) => switch (code) {
    CurrencyCode.usd => 2,
    CurrencyCode.npr => 2,
    CurrencyCode.vnd => 0,
  };

  static String _symbol(CurrencyCode code) => switch (code) {
    CurrencyCode.usd => r'$',
    CurrencyCode.npr => 'NPR ',
    CurrencyCode.vnd => '₫',
  };

  static String _groupedNumber(double amount, CurrencyCode code, int decimals) {
    final fixed = amount.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final intPart = _groupInteger(parts[0], indian: code == CurrencyCode.npr);
    if (decimals == 0 || parts.length == 1) return intPart;
    return '$intPart.${parts[1]}';
  }

  /// Live input mask. Preserves a trailing decimal and typed fraction digits.
  /// NPR uses Indian grouping; USD/VND use western thousands. VND has no decimal.
  static String maskInput(String raw, CurrencyCode code) {
    final allowDecimal = code != CurrencyCode.vnd;
    final sanitized = _sanitizeInput(
      raw,
      allowDecimal: allowDecimal,
      maxFractionDigits: 2,
    );
    if (sanitized.isEmpty) return '';

    final dot = sanitized.indexOf('.');
    final hasDot = dot >= 0;
    var intDigits = hasDot ? sanitized.substring(0, dot) : sanitized;
    final fraction = hasDot ? sanitized.substring(dot + 1) : '';
    intDigits = _stripLeadingZeros(intDigits);
    if (intDigits.isEmpty) intDigits = '0';

    final grouped = _groupInteger(intDigits, indian: code == CurrencyCode.npr);
    if (!allowDecimal || !hasDot) return grouped;
    if (fraction.isEmpty) return '$grouped.';
    return '$grouped.$fraction';
  }

  static String _sanitizeInput(
    String raw, {
    required bool allowDecimal,
    required int maxFractionDigits,
  }) {
    final buf = StringBuffer();
    var seenDot = false;
    var fractionDigits = 0;
    for (var i = 0; i < raw.length; i++) {
      final ch = raw[i];
      if (ch.compareTo('0') >= 0 && ch.compareTo('9') <= 0) {
        if (seenDot) {
          if (fractionDigits >= maxFractionDigits) continue;
          fractionDigits++;
        }
        buf.write(ch);
      } else if (ch == '.') {
        if (!allowDecimal) break;
        if (seenDot) continue;
        seenDot = true;
        buf.write(ch);
      }
    }
    return buf.toString();
  }

  static String _stripLeadingZeros(String digits) {
    return digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
  }

  /// Western grouping (`1,234,567`) for USD/VND; Indian (`12,34,567`) for NPR.
  static String _groupInteger(String s, {required bool indian}) {
    final negative = s.startsWith('-');
    final digits = negative ? s.substring(1) : s;
    if (digits.length <= 3) {
      return negative ? '-$digits' : digits;
    }

    final buf = StringBuffer();
    if (indian) {
      final last3 = digits.length - 3;
      for (var i = 0; i < last3; i++) {
        if (i > 0 && (last3 - i).isEven) buf.write(',');
        buf.write(digits[i]);
      }
      buf
        ..write(',')
        ..write(digits.substring(last3));
    } else {
      for (var i = 0; i < digits.length; i++) {
        final fromEnd = digits.length - i;
        if (i > 0 && fromEnd % 3 == 0) buf.write(',');
        buf.write(digits[i]);
      }
    }
    return negative ? '-$buf' : buf.toString();
  }
}
