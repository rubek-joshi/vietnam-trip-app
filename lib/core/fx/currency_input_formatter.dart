import 'package:flutter/services.dart';
import 'package:vietnam_handbook/core/fx/fx_rates.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  const CurrencyInputFormatter(this.code);

  final CurrencyCode code;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = _significant(newValue.text);
    var significantBeforeCursor = _significantCount(
      newValue.text,
      newValue.selection.end,
    );

    // Backspacing a grouping comma would otherwise be a no-op; drop the
    // digit before the separator so deletion still makes progress.
    if (newValue.text.length < oldValue.text.length &&
        digits == _significant(oldValue.text) &&
        significantBeforeCursor > 0) {
      digits =
          digits.substring(0, significantBeforeCursor - 1) +
          digits.substring(significantBeforeCursor);
      significantBeforeCursor -= 1;
    }

    final masked = CurrencyFormatter.maskInput(digits, code);
    final offset = _offsetForSignificantCount(
      masked,
      significantBeforeCursor,
    ).clamp(0, masked.length);

    return TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

  static String _significant(String text) {
    final buf = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final ch = text[i];
      if (ch == '.' || (ch.compareTo('0') >= 0 && ch.compareTo('9') <= 0)) {
        buf.write(ch);
      }
    }
    return buf.toString();
  }

  static int _significantCount(String text, int cursor) {
    final end = cursor.clamp(0, text.length);
    var count = 0;
    for (var i = 0; i < end; i++) {
      final ch = text[i];
      if (ch == '.' || (ch.compareTo('0') >= 0 && ch.compareTo('9') <= 0)) {
        count++;
      }
    }
    return count;
  }

  static int _offsetForSignificantCount(String masked, int count) {
    if (count <= 0) return 0;
    var seen = 0;
    for (var i = 0; i < masked.length; i++) {
      final ch = masked[i];
      if (ch == '.' || (ch.compareTo('0') >= 0 && ch.compareTo('9') <= 0)) {
        seen++;
        if (seen == count) return i + 1;
      }
    }
    return masked.length;
  }
}
